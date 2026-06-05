# Smart Calc — Backend Proxy

Thin Node + Express proxy in front of the OpenAI Chat Completions API.
Its only job is to keep the OpenAI API key off the user's device.

## Run

```bash
cp .env.example .env
# edit .env: OPENAI_API_KEY=sk-...
npm install
npm start
```

## Endpoints

### `GET /health`
`200 → { "ok": true }`

### `POST /solve`
```json
{
  "imageBase64": "<jpeg/png base64, no data: prefix>",
  "mode": "quick" | "detailed",
  "lang": "en" | "ar"
}
```

Response:
```json
{
  "latex":  "x^2 + 3x - 4 = 0",
  "answer": "x = 1, x = -4",
  "steps":  [{ "description": "...", "latex": "..." }]
}
```

## Hardening

- `helmet` for default security headers
- `cors` — set `CORS_ORIGINS` to your app's web origins (or leave `*` for mobile-only)
- `express-rate-limit` — `RATE_LIMIT_MAX` requests per `RATE_LIMIT_WINDOW_MS`
- 12 MB body limit (base64 images get bulky)
- No image is logged or persisted; each request is one-shot
