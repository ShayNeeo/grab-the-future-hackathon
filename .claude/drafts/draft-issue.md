---
title: "[Task] Consolidate duplicate Flutter trees and populate the missing src/ data layer"
kind: issue
template: fallback
labels: [task, refactor]
---

## Summary

The repo currently contains **two parallel Flutter codebases**: the root-level `lib/` project (package `scamshield`) and `scamshield_app/lib/` (package `scamshield_app`). They duplicate screen and provider logic under different package names and carry different dependency sets (`google_fonts`/`lottie` in the root; `riverpod`/`dio`/`image_picker` in the sub-folder). Additionally, `lib/src/README.dart` describes a planned data layer (`models/`, `services/`, `repositories/`, `providers/`) that has never been created — meaning the app has no path from UI to the backend API. This task merges both trees into a single, canonical structure and fills the `src/` layer.

## Business Goal / Why

ScamShield is a 12-hour hackathon sprint. Having two Flutter projects doubles the maintenance surface, causes import-path confusion, and makes the FastAPI integration unreachable from the real app (the root project has no `ScamShieldApi` client). Consolidating now — before the data layer is wired — avoids a hard refactor mid-sprint when screens are already connected to providers.

## Actor

Developers / maintainers — no end-user-facing behaviour changes; all screens remain identical after the move.

## Current State (verified against code)

| Location | What exists | Problem |
|---|---|---|
| `lib/` (root) | `app/`, `core/`, `ui/screens/` (8 screens), `ui/widgets/` (5 widgets) | No `src/` layer; cannot call the API |
| `lib/src/README.dart` | Documents planned `models/`, `services/`, `repositories/`, `providers/` | Placeholder only — zero implementation files |
| `scamshield_app/lib/` | `core/api/` (Dio client, models), `core/providers/` (Riverpod), `features/` (3 screens) | Different package name; screens duplicated; will never be shipped |
| `scamshield_api/` | FastAPI backend — `main.py`, `app/{agents,models,routers}/` | Correct; no changes needed |

## Proposed Target Structure

```
grab-the-future-hackathon/
├── lib/                            ← single Flutter source of truth
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart
│   │   └── routes.dart
│   ├── core/
│   │   ├── constants/app_constants.dart
│   │   └── theme/
│   │       ├── app_colors.dart
│   │       ├── app_text_styles.dart
│   │       └── app_theme.dart
│   ├── ui/
│   │   ├── screens/               ← 8 screens (unchanged)
│   │   └── widgets/               ← 5 widgets (unchanged)
│   └── src/
│       ├── models/
│       │   ├── analysis_request.dart
│       │   └── analysis_response.dart
│       ├── services/
│       │   └── scamshield_api.dart
│       ├── repositories/          ← empty, reserved for Phase 2
│       └── providers/
│           ├── chat_provider.dart
│           └── cooling_off_provider.dart
├── scamshield_api/                 ← FastAPI backend (no changes)
├── pubspec.yaml                    ← merge deps from scamshield_app/
└── .gitignore
```

## Implementation Steps

1. **Merge `pubspec.yaml` dependencies** — add `flutter_riverpod`, `dio`, `image_picker`, `share_plus`, `shared_preferences` to the root `pubspec.yaml`; run `flutter pub get`.
2. **Create `lib/src/models/`** — move `analysis_request.dart` and `analysis_response.dart` from `scamshield_app/lib/core/api/models/`; update imports to `package:scamshield/src/models/...`.
3. **Create `lib/src/services/scamshield_api.dart`** — move the Dio client from `scamshield_app/lib/core/api/scamshield_api.dart`; update `baseUrl` reference to use `AppConstants.apiBaseUrl`.
4. **Create `lib/src/providers/`** — move `chat_provider.dart` and `cooling_off_provider.dart` from `scamshield_app/lib/core/providers/`; fix all `package:scamshield_app/...` imports.
5. **Delete `scamshield_app/`** — the entire directory is now superseded.
6. **Delete `lib/src/README.dart`** — replaced by real files.
7. **Wire providers into screens** — wrap `MaterialApp` in `ProviderScope` in `lib/main.dart`; connect `ChatScreen` and `CoolingOffTimerScreen` to the moved providers.
8. **Run `flutter analyze`** — confirm zero errors.

## Acceptance Criteria

- [ ] Only one `pubspec.yaml` at the repo root; `scamshield_app/` directory does not exist.
- [ ] `lib/src/models/`, `lib/src/services/`, `lib/src/providers/` all contain real implementation files (not README stubs).
- [ ] All imports use `package:scamshield/...` — no `package:scamshield_app/...` references remain.
- [ ] `flutter analyze` reports **No issues found**.
- [ ] `uvicorn main:app --reload` in `scamshield_api/` still starts without errors.
- [ ] `HomeDashboardScreen`, `ChatScreen`, and `CoolingOffTimerScreen` render without red-screen errors on a simulator.

## Out of Scope

- Changing any screen UI or business logic.
- Adding new screens (`FamilyGuardianScreen`, `ContractAnalysisScreen` remain as stub placeholders).
- Backend (`scamshield_api/`) changes.
- Adding tests.

## Dependencies / Blockers

- None known. All source files already exist in either `lib/` or `scamshield_app/lib/`.

## References

- [`lib/src/README.dart`](lib/src/README.dart) — original data-layer spec
- [`scamshield_app/lib/core/api/scamshield_api.dart`](scamshield_app/lib/core/api/scamshield_api.dart) — Dio client to migrate
- [`scamshield_app/lib/core/providers/chat_provider.dart`](scamshield_app/lib/core/providers/chat_provider.dart) — provider to migrate
- [`scamshield_api/app/routers/analyze.py`](scamshield_api/app/routers/analyze.py) — backend contract (unchanged)
