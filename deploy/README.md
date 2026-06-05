# NUMINA — VPS Deployment

Quick guide to host the backend on a fresh Ubuntu VPS, isolated under
its own non-root user `numina` so it doesn't interfere with anything
else running on the box.

## Prerequisites
- Ubuntu VPS with root SSH access
- Public IP (we use the auto-domain via [nip.io](https://nip.io) — no
  DNS setup needed)
- Your `OPENAI_API_KEY`

## Step-by-step

### 1. Upload the backend code (from your local machine)

```powershell
cd c:\Users\2021\Desktop\AI_SC
scp -r backend root@168.231.125.67:/home/numina/backend
```

> **Note**: the `numina` user doesn't exist yet — that's fine. Root can
> write to `/home/numina/` because the path is created on the fly. The
> setup script chowns everything to `numina` afterwards.

### 2. Upload the setup script

```powershell
scp deploy/setup-vps.sh root@168.231.125.67:/root/setup-vps.sh
```

### 3. Create the `.env` on the VPS

```powershell
ssh root@168.231.125.67
```

On the VPS:

```bash
mkdir -p /home/numina/backend
nano /home/numina/backend/.env
```

Paste:

```
OPENAI_API_KEY=sk-...your-key-here...
PORT=3000
CORS_ORIGINS=*
RATE_LIMIT_WINDOW_MS=60000
RATE_LIMIT_MAX=20
OPENAI_MODEL=gpt-4o
```

Save with `Ctrl+O`, `Enter`, `Ctrl+X`.

### 4. Run the setup script (as root)

```bash
bash /root/setup-vps.sh
```

It takes ~3-5 minutes and at the end will print a `200 OK` from
`https://168.231.125.67.nip.io/health`.

### 5. Verify from anywhere

```bash
curl https://168.231.125.67.nip.io/health
# → {"ok":true}
```

## Routine ops

All ops run via `sudo -u numina ...` (or by SSHing in as `numina`):

| Task | Command |
|---|---|
| SSH as the app user | `ssh numina@168.231.125.67` |
| Tail backend logs | `sudo -u numina pm2 logs numina-backend` |
| Restart backend | `sudo -u numina pm2 restart numina-backend` |
| Edit env, then restart | `nano /home/numina/backend/.env && sudo -u numina pm2 restart numina-backend --update-env` |
| Reload Nginx (root) | `systemctl reload nginx` |
| Renew HTTPS cert | `certbot renew` (also runs automatically) |

The `numina` user has no sudo and no password — only SSH-key access
copied from root. Other projects on the VPS aren't affected.
