#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────────
#  NUMINA backend — one-shot VPS setup script (Ubuntu)
#
#  Run on a clean Ubuntu VPS as root:
#      sudo bash setup-vps.sh
#
#  What it does:
#    1. Installs Node.js 20 LTS, Nginx, Certbot, ufw, PM2
#    2. Creates a dedicated, non-privileged user `numina`
#    3. Copies root's SSH keys → numina (so you can SSH in as numina)
#    4. Sets up firewall (allow 22, 80, 443)
#    5. Configures Nginx as reverse proxy → 127.0.0.1:3000
#    6. Issues HTTPS cert for 168.231.125.67.nip.io via Let's Encrypt
#    7. Installs backend deps + starts PM2 as the `numina` user
#       (autostart on reboot via systemd)
#
#  Pre-requisites:
#    • Backend code uploaded to /home/numina/backend
#         scp -r backend root@168.231.125.67:/home/numina/backend
#      (root can scp there even before the user exists — the script
#       will chown afterwards.)
#    • /home/numina/backend/.env contains OPENAI_API_KEY=sk-...
# ────────────────────────────────────────────────────────────────────
set -euo pipefail

DOMAIN="168.231.125.67.nip.io"
APP_USER="numina"
APP_DIR="/home/${APP_USER}/backend"
PORT="3000"
EMAIL="admin@${DOMAIN}"

log() { printf "\n\033[1;32m▶ %s\033[0m\n" "$*"; }

if [[ $EUID -ne 0 ]]; then
   echo "Run as root: sudo bash $0"
   exit 1
fi

# ── 1. APT base setup ──────────────────────────────────────────────
log "Updating apt and installing base packages…"
apt update -y
apt install -y curl ca-certificates gnupg ufw nginx

# ── 2. Node.js 20 LTS ──────────────────────────────────────────────
if ! command -v node &>/dev/null || [[ $(node -v) != v20* ]]; then
  log "Installing Node.js 20 LTS…"
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
  apt install -y nodejs
fi
node -v
npm -v

# ── 3. PM2 (process manager + boot script) ─────────────────────────
log "Installing PM2 globally…"
npm install -g pm2

# ── 4. Create dedicated app user ───────────────────────────────────
if id "$APP_USER" &>/dev/null; then
  log "User '$APP_USER' already exists — skipping creation."
else
  log "Creating system user '$APP_USER'…"
  adduser --disabled-password --gecos "" "$APP_USER"
fi

# Copy root's SSH authorized_keys so you can ssh in as the new user.
ROOT_KEYS="/root/.ssh/authorized_keys"
USER_SSH="/home/${APP_USER}/.ssh"
if [[ -f "$ROOT_KEYS" ]]; then
  install -d -m 700 -o "$APP_USER" -g "$APP_USER" "$USER_SSH"
  install -m 600 -o "$APP_USER" -g "$APP_USER" "$ROOT_KEYS" "$USER_SSH/authorized_keys"
  log "Copied SSH keys to ${APP_USER}@$(hostname). You can now: ssh ${APP_USER}@${DOMAIN%.nip.io}"
fi

# ── 5. Firewall ────────────────────────────────────────────────────
log "Configuring firewall…"
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw --force enable

# ── 6. Backend code + .env presence checks ─────────────────────────
if [[ ! -d "$APP_DIR" ]]; then
  echo "❌ $APP_DIR does not exist."
  echo "   Upload the backend folder first (from your local machine):"
  echo "     scp -r backend/ root@168.231.125.67:/home/${APP_USER}/backend"
  exit 1
fi

if [[ ! -f "$APP_DIR/.env" ]]; then
  echo "❌ $APP_DIR/.env is missing. Create it on the VPS with:"
  echo "     OPENAI_API_KEY=sk-..."
  echo "     PORT=$PORT"
  exit 1
fi

# Make sure everything in the app dir belongs to the app user.
chown -R "$APP_USER":"$APP_USER" "/home/${APP_USER}"
chmod 600 "$APP_DIR/.env"

# ── 7. Backend dependencies + PM2 (run as the app user) ────────────
log "Installing backend npm deps + starting PM2 as '$APP_USER'…"
sudo -iu "$APP_USER" bash <<EOSU
set -euo pipefail
cd "$APP_DIR"
npm ci --omit=dev || npm install --omit=dev
pm2 delete numina-backend 2>/dev/null || true
pm2 start "src/server.js" --name numina-backend --update-env --time
pm2 save
EOSU

# Configure pm2 to autostart on boot for that user.
log "Wiring PM2 boot script for user '$APP_USER'…"
env PATH="$PATH:/usr/bin" pm2 startup systemd -u "$APP_USER" --hp "/home/${APP_USER}"

# ── 8. Nginx reverse proxy (HTTP first; HTTPS added after Certbot) ─
log "Writing Nginx site config…"
cat >/etc/nginx/sites-available/numina <<NGINX
server {
    listen 80;
    server_name ${DOMAIN};

    # Hard cap to match Express body limit (12 MB images).
    client_max_body_size 16m;

    location / {
        proxy_pass http://127.0.0.1:${PORT};
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 90s;
    }
}
NGINX
ln -sf /etc/nginx/sites-available/numina /etc/nginx/sites-enabled/numina
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl reload nginx

# ── 9. Certbot (HTTPS) ─────────────────────────────────────────────
log "Installing certbot + issuing HTTPS certificate…"
apt install -y certbot python3-certbot-nginx
certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos -m "$EMAIL" --redirect

# ── 10. Quick health check ─────────────────────────────────────────
log "Health check…"
sleep 2
curl -sS "https://${DOMAIN}/health" || echo "Health endpoint not responding — check 'sudo -u $APP_USER pm2 logs numina-backend'"

log "Done!"
echo
echo "  • App user:                  $APP_USER (no sudo, no password — SSH-key only)"
echo "  • Backend dir:               $APP_DIR"
echo "  • Tail logs:                 sudo -u $APP_USER pm2 logs numina-backend"
echo "  • Restart:                   sudo -u $APP_USER pm2 restart numina-backend"
echo "  • Reload Nginx:              systemctl reload nginx"
echo "  • Renew cert (auto-cron OK): certbot renew"
echo "  • Endpoint:                  https://${DOMAIN}/solve"
