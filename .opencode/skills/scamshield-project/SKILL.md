# Skill: ScamShield Project Context

## When to Use

Use this skill when working on the ScamShield (Lá Chắn Lừa Đảo) Flutter project — an AI-powered scam detection app for elderly Vietnamese users. Covers project structure, design system, build pipeline, and deployment.

## Project Overview

- **App:** ScamShield — agentic AI chatbot that analyzes suspicious messages, images, voice notes, and contracts to detect scams
- **Platform:** Flutter 3.44.4 / Dart 3.12.2 / Material 3
- **Target audience:** Elderly users (60–80) in Vietnam + their adult children as family guardians
- **Repo:** `https://github.com/ShayNeeo/grab-the-future-hackathon`

## Project Structure

```
lib/
├── main.dart                    # Entry point
├── app/
│   ├── app.dart                 # MaterialApp config
│   └── routes.dart              # All route definitions
├── core/
│   ├── constants/
│   │   └── app_constants.dart   # Spacing, font sizes, radius values
│   └── theme/
│       ├── app_colors.dart      # Teal palette + alert spectrum
│       ├── app_text_styles.dart # Nunito typography (18sp min body)
│       └── app_theme.dart       # Material 3 ThemeData
├── ui/
│   ├── screens/                 # 8 screens
│   │   ├── splash_onboarding_screen.dart
│   │   ├── home_dashboard_screen.dart
│   │   ├── chat_screen.dart
│   │   ├── scam_result_card_screen.dart
│   │   ├── cooling_off_timer_screen.dart
│   │   ├── contract_analysis_screen.dart
│   │   ├── family_guardian_screen.dart
│   │   └── settings_screen.dart
│   └── widgets/                 # Reusable components
│       ├── bottom_nav_shell.dart
│       ├── risk_badge.dart
│       ├── shield_button.dart
│       ├── shield_logo.dart
│       └── stat_card.dart
└── src/
    └── README.dart              # Placeholder for teammates
```

## Design System Rules (Non-Negotiable)

These are enforced on every screen:

1. **Font size:** Never below 16sp. Body text 18sp minimum. Font: Nunito (rounded, legible).
2. **Touch targets:** 56dp minimum height for all tappable elements.
3. **Colors:**
   - Primary: `#006D72` (shield-teal), Light: `#1A9DAA`, Bg: `#E8F5F6`
   - Alerts: Red `#C0392B`, Orange `#E67E22`, Amber `#F1C40F`, Green `#27AE60`
   - Text: `#1A2D3A` (dark navy, NOT pure black), Secondary: `#5C7A88`
   - Surface: `#FFFFFF`, Light bg: `#F4F9FA`
4. **Border radius:** Cards 20dp, Buttons 16dp, Chat bubbles 18dp, Inputs 14dp
5. **Spacing:** Multiples of 8 (xs:8, sm:16, md:24, lg:32, xl:48)
6. **No gesture-only actions:** Always provide visible button alternative.
7. **Loading states:** Named spinner ("Đang phân tích..."), never bare spinner.
8. **Vietnamese copy:** Plain language, no English jargon visible to end user.

## Android Build Configuration

### build.gradle.kts (android/app/)
- R8 minification: `isMinifyEnabled = true`
- Resource shrinking: `isShrinkResources = true`
- Core library desugaring: required for `flutter_local_notifications`
- ProGuard rules in `android/app/proguard-rules.pro`
- DO NOT use `ndk.abiFilters` — conflicts with `--split-per-abi`

### Key Dependencies
- `google_fonts: ^6.1.0` (Nunito)
- `lottie: ^3.0.0` (animations)
- `flutter_local_notifications: ^17.0.0` (cooling-off timer)
- `intl: ^0.19.0` (Vietnamese formatting)

## CI/CD Pipeline

### Workflow: `.github/workflows/build-arm64.yml`

**Triggers:**
- Push to `main` → build + artifact
- Tag `v*` → build + artifact + GitHub Release with APK

**Build steps:**
1. Java 17 (Temurin) + Flutter 3.44.4 (stable, cached)
2. `flutter pub get`
3. `flutter build apk --release --target-platform android-arm64 --split-per-abi --obfuscate --split-debug-info=build/debug-info --tree-shake-icons`
4. Verify arm64-v8a APK exists + report size to step summary
5. Upload as artifact (30 day retention)
6. On tag: create GitHub Release with raw APK attached

**Output:** `app-arm64-v8a-release.apk` (~17.6 MB)

### Gotchas Encountered
| Issue | Fix |
|-------|-----|
| `groovy.xml.QName` not found | Flutter version too old for AGP 9.0.1 — use 3.44.4 |
| `ndk abiFilters` conflicts with `--split-per-abi` | Remove ndk filter, rely on `--target-platform` |
| `flutter_local_notifications` requires desugaring | Add `isCoreLibraryDesugaringEnabled = true` + `desugar_jdk_libs:2.1.4` |
| `--strip` is not a valid Flutter CLI flag | Don't use it; `--split-debug-info` handles debug extraction |

### Release Process
```bash
git tag -a v1.0.0 -m "v1.0.0 — description"
git push origin v1.0.0
# CI auto-builds and creates GitHub Release with APK
```

## Screen Navigation Map

```
Splash → Onboarding (3 slides) → Home Dashboard
                                      ├── Chat (AI assistant)
                                      │    └── Scam Result Card
                                      │         └── Cooling-Off Timer
                                      │         └── Contract Analysis
                                      ├── Family Guardian
                                      └── Settings
```

## Widget Patterns

- **All buttons:** `ShieldButton` with 56dp min height, 16dp radius
- **Risk indicators:** `RiskBadge` / `RiskBanner` with traffic-light colors
- **Bottom nav:** `BottomNavShell` wrapping screen content (3 tabs: Home, Chat, Family)
- **Cards:** White bg, 20dp radius, subtle shadow for elevation
- **Chat bubbles:** AI = left-aligned white, User = right-aligned teal

## Working with This Codebase

- Always use `package:scamshield/...` absolute imports (not relative `../`)
- Theme tokens in `core/theme/` — never hardcode hex colors in screens
- Shared widgets in `ui/widgets/` — extract reusable components
- `src/` is reserved for teammates (models, services, repos, providers)
- Run `flutter pub get` before building
- Test on 390×844dp (iPhone 14) canvas size
