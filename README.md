# Smart Calc — AI-Powered Scientific Calculator

Cross-platform (Android + iOS) scientific calculator that combines a full
scientific keypad with **GPT-4o Vision** for solving math problems from
photos. Bilingual UI (Arabic RTL + English).

This is the **Phase 1 / MVP** scaffold from
[`AI_Scientific_Calculator_Prompt.md`](AI_Scientific_Calculator_Prompt.md).

## Repo layout

```
.
├── app/        Flutter app (Dart, Material 3, Riverpod)
└── backend/    Node + Express proxy for the OpenAI API
```

The app **never** talks to OpenAI directly — every AI call goes through the
backend so the API key stays off the device.

## Features in this MVP

- Scientific calculator with `sin/cos/tan`, `√`, `π`, `e`, `^`, parentheses
- Angle modes: degrees / radians / gradians (toggleable)
- AI image solver: camera or gallery → LaTeX equation → quick or detailed
  step-by-step solution rendered as LaTeX
- Function grapher (`fl_chart`) with arbitrary `f(x)` input
- Unit converter: length, weight, time, angle, speed
- Local persistent history (Hive) with pin / delete
- Settings: light / dark / system theme, language toggle (ar / en)
- Full Arabic RTL support
- Backend proxy with rate limiting, CORS allowlist, helmet

## Running the app

```bash
cd app
flutter pub get
flutter run --dart-define=BACKEND_URL=https://your-proxy.example.com
```

Without `BACKEND_URL`, the calculator, grapher, converter, and history work,
but the **AI Solver tab** will show a banner saying the backend isn't
configured (it never tries to contact OpenAI directly).

### Tests
```bash
cd app
flutter test
```

## Running the backend

```bash
cd backend
cp .env.example .env
# edit .env and set OPENAI_API_KEY (PORT defaults to 5000)
npm install
npm start          # production — http://localhost:5000
npm run dev        # auto-reload
```

The proxy exposes:

- `GET  /health` → `{ ok: true }`
- `POST /solve`  → body `{ imageBase64, mode: "quick"|"detailed", lang: "en"|"ar" }`
  - returns `{ latex, answer, steps[] }`

## Build artifacts

```bash
# Android APK
cd app && flutter build apk --release \
  --dart-define=BACKEND_URL=https://your-proxy.example.com

# iOS (run on macOS only)
cd app && flutter build ios --release \
  --dart-define=BACKEND_URL=https://your-proxy.example.com
```

## What's next (Phase 2+)

Per the original prompt — symbolic calculus, matrix ops, equation solver,
PDF export, cloud history sync, more languages. The architecture (clean
separation under `app/lib/features/<feature>/{data,domain,presentation}`)
is set up to keep adding features without churn.
