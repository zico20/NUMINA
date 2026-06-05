<!--
SYNC IMPACT REPORT
==================
Version change: (uninitialized template) → 1.0.0
Rationale: Initial ratification. First concrete constitution replacing the
           placeholder template; MINOR/PATCH not applicable to a first adoption,
           so the baseline is 1.0.0.

Principles defined (all new):
  - I.   Calculator Correctness (NON-NEGOTIABLE)
  - II.  Offline-First Core
  - III. Secret Isolation via Backend Proxy (NON-NEGOTIABLE)
  - IV.  Bilingual & RTL-First UX
  - V.   Cross-Platform Single Codebase
  - VI.  Test Discipline

Added sections:
  - Additional Constraints (Tech Stack & Platform Baseline)
  - Development Workflow & Quality Gates
  - Governance

Removed sections: none (template placeholders replaced wholesale).

Templates / artifacts reviewed for consistency:
  - .specify/templates/plan-template.md ........ ✅ no change needed
        ("Constitution Check" uses a dynamic
        "[Gates determined based on constitution file]" placeholder that
        derives gates from this file at plan time.)
  - .specify/templates/spec-template.md ........ ✅ no change needed
  - .specify/templates/tasks-template.md ....... ✅ no change needed
  - .specify/templates/checklist-template.md ... ✅ no change needed
  - .specify/templates/commands/*.md ........... ✅ N/A (directory absent)
  - README.md .................................. ✅ consistent (no edit)

Deferred / TODO items: none. RATIFICATION_DATE set to the repository's first
commit date (2026-06-05), which is the project's adoption date.
-->

# Smart Calc Constitution

Smart Calc is a cross-platform (Android + iOS) AI-powered scientific calculator
that pairs a full scientific keypad with GPT-4o Vision photo solving, behind a
bilingual (Arabic RTL + English) interface. This constitution defines the
non-negotiable rules that every feature, change, and review must uphold.

## Core Principles

### I. Calculator Correctness (NON-NEGOTIABLE)

A calculator that returns a wrong answer is worse than no calculator. Every
mathematical operation MUST be deterministic and verifiable.

- All core math (arithmetic, trigonometry, logarithms, powers/roots,
  conversions, graphing) MUST be computed on-device by the math engine, never
  delegated to the AI model for the authoritative result.
- Angle mode (degrees / radians / gradians) MUST be explicit and respected by
  every trigonometric function; the active mode MUST be visible to the user.
- Floating-point edge cases (division by zero, domain errors, overflow,
  precision loss) MUST produce a defined, user-legible result — never a silent
  wrong number or an unhandled crash.
- Any new or changed computation MUST ship with unit tests asserting known
  correct values, including boundary and error cases.

**Rationale**: Trust is the product. Users (students, engineers) rely on exact
answers; a single visible miscalculation destroys credibility permanently.

### II. Offline-First Core

The calculator, grapher, unit converter, and history are core utilities and
MUST function with no network connection.

- Launching, calculating, graphing, converting, and reading/writing local
  history MUST NOT require the backend, the AI model, or any network call.
- Network-dependent features (AI photo solver) MUST degrade gracefully: when the
  backend is unconfigured or unreachable, the app MUST show a clear,
  non-blocking notice and keep all offline features fully usable.
- Persistent data (history, settings) MUST be stored locally and survive app
  restarts.

**Rationale**: A calculator must work in an exam hall, on a plane, or in poor
connectivity. AI is an enhancement, not a dependency for the core.

### III. Secret Isolation via Backend Proxy (NON-NEGOTIABLE)

The app MUST NEVER hold or transmit the OpenAI API key, and MUST NEVER call
OpenAI directly.

- Every AI request MUST route through the Smart Calc backend proxy; the device
  only ever talks to our own backend URL.
- API keys and other secrets MUST live only in backend environment
  configuration (e.g. `.env`) and MUST NOT be committed to the repository or
  embedded in the client build (including via `--dart-define`).
- The backend MUST enforce its protective controls — rate limiting, a CORS
  allowlist, and security headers (helmet) — on the AI endpoint.
- Input sent to the model (images, extracted equations) MUST be validated at the
  backend boundary before reaching the upstream API.

**Rationale**: A leaked key is an unbounded financial and security liability.
Centralizing AI access in the proxy is the only place these controls can be
enforced once for all clients.

### IV. Bilingual & RTL-First UX

Arabic and English are first-class equals; Arabic is the default and RTL is not
an afterthought.

- All user-facing strings MUST be externalized through the localization layer
  (`flutter_localizations` / `intl`) — no hardcoded display text.
- Every screen MUST render correctly in both RTL (Arabic) and LTR (English),
  including layout direction, numerals, and mixed-direction content (e.g. LaTeX
  inside Arabic text).
- Adding or changing a user-facing string MUST update both language catalogs in
  the same change; a feature with a missing translation is incomplete.

**Rationale**: The primary audience is Arabic-speaking. Treating RTL as a
bolt-on produces broken layouts and excludes the core user base.

### V. Cross-Platform Single Codebase

One Flutter codebase serves both Android and iOS with feature parity.

- Features MUST be implemented in shared Dart code by default; platform-specific
  code is permitted only where a capability genuinely differs (e.g. camera,
  file access) and MUST be isolated behind a common interface.
- A feature is "done" only when it works on both Android (API 26+) and
  iOS (13.0+); platform-only behavior MUST be called out explicitly and
  justified.
- New third-party dependencies MUST support both target platforms.

**Rationale**: Divergent platform code multiplies maintenance and creates parity
bugs. The whole point of Flutter here is one codebase, two platforms.

### VI. Test Discipline

Changes are verified by automated tests, not by manual hope.

- Core math, conversions, and parsing logic MUST have unit tests; the app test
  suite (`flutter test`) and backend tests (`npm test`) MUST pass before merge.
- Bug fixes MUST add a regression test that fails before the fix and passes
  after.
- Backend request handling (validation, error paths, proxy behavior) MUST be
  covered by tests that do not call the live OpenAI API.

**Rationale**: Correctness (Principle I) and secret isolation (Principle III)
are only credible if continuously and automatically checked.

## Additional Constraints: Tech Stack & Platform Baseline

The stack is fixed for consistency; deviations require an amendment.

- **Frontend**: Flutter (Dart, Material 3), Riverpod for state, `go_router`
  for routing.
- **Math & rendering**: `math_expressions` for computation, `flutter_math_fork`
  for LaTeX, `fl_chart` for graphing.
- **Local storage**: Hive (history) and `shared_preferences` (settings).
- **Backend**: Node.js (>=20) + Express, with `express-rate-limit`, `cors`,
  `helmet`, `dotenv`, `zod` for validation, and the `openai` SDK.
- **AI model**: OpenAI GPT-4o Vision, accessed only through the backend proxy.
- **Platform floors**: Android 8.0 (API 26) and iOS 13.0.

## Development Workflow & Quality Gates

- Work proceeds through the Spec Kit flow: constitution → specify → (clarify) →
  plan → tasks → implement, with feature branches per the repository's branch
  naming conventions.
- Every plan MUST pass the Constitution Check gate; any deviation MUST be
  recorded in the plan's Complexity Tracking with explicit justification.
- A change MUST NOT merge if it: returns an incorrect computation (I), breaks an
  offline core feature (II), exposes or risks a secret (III), ships a
  user-facing string without both translations (IV), breaks platform parity (V),
  or leaves the test suites failing (VI).
- Secrets MUST stay out of version control; `.env` and equivalents remain
  git-ignored.

## Governance

- This constitution supersedes other practices where they conflict. When a rule
  here and another document disagree, this document wins until amended.
- **Amendments** require: a written rationale, an update to the version per the
  policy below, propagation to any dependent templates/docs, and a recorded
  ratification/amendment date.
- **Versioning policy** (semantic):
  - **MAJOR**: a principle is removed or redefined in a backward-incompatible
    way, or governance rules change incompatibly.
  - **MINOR**: a new principle or section is added, or guidance is materially
    expanded.
  - **PATCH**: clarifications, wording, or typo fixes with no change in meaning.
- **Compliance review**: every spec, plan, and pull request MUST be checked
  against these principles. Complexity or deviation MUST be justified in writing;
  unjustified violations block merge.
- Runtime development guidance for agents lives in `CLAUDE.md` and the current
  plan; those MUST stay consistent with this constitution.

**Version**: 1.0.0 | **Ratified**: 2026-06-05 | **Last Amended**: 2026-06-05
