# Justful — AI Scam Shield for Elderly Users

> **Grab the Future Hackathon** · Bảo vệ người cao tuổi khỏi lừa đảo bằng AI

Justful is a Flutter mobile app paired with a FastAPI backend that protects elderly Vietnamese users from scams in real time. It analyzes messages, images, voice input, and SMS using Google Gemini 2.5 Flash, returning structured risk assessments in plain Vietnamese.

---

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Backend Setup](#backend-setup)
  - [Flutter App Setup](#flutter-app-setup)
- [Project Structure](#project-structure)
- [Screens](#screens)
- [API Reference](#api-reference)
- [AI Agent System](#ai-agent-system)
- [Design System](#design-system)
- [Building for Production](#building-for-production)

---

## Features

| Feature | Description |
|---------|-------------|
| **AI Chat Analysis** | Voice or text input → Gemini AI → structured scam risk report |
| **SMS Auto-Detection** | Background SMS listener flags suspicious messages automatically |
| **Document / Contract Review** | Photo a contract → AI scans for risky clauses |
| **Family Guardian** | Family members receive alerts when a risk is detected |
| **Agentic Loop** | AI asks follow-up questions to gather more context before final verdict |

---

## Architecture

```
┌─────────────────────────────────────┐
│          Flutter App (Android)       │
│                                      │
│  ChatScreen ──► ChatProvider         │
│  HomeDashboard   (Riverpod)          │
│  SmsDetectionService                 │
│           │                          │
│           ▼  HTTP / WebSocket        │
└───────────┼──────────────────────────┘
            │
┌───────────▼──────────────────────────┐
│        FastAPI Backend               │
│  POST /analyze   (streaming)         │
│  POST /chat      (streaming)         │
│  POST /contract                      │
│  POST /detect-scam                   │
│           │                          │
│           ▼                          │
│    Google Gemini 2.5 Flash           │
└──────────────────────────────────────┘
```

**State management**: Flutter Riverpod  
**HTTP client**: Dio with streaming response support  
**AI model**: `gemini-2.5-flash` via Google's OpenAI-compatible endpoint  
**Persistence**: SharedPreferences (alerts, chat history)

---

## Getting Started

### Prerequisites

| Tool | Version |
|------|---------|
| Flutter | ≥ 3.16.0 |
| Dart | ≥ 3.2.0 |
| Python | ≥ 3.11 |
| Android SDK | API 23+ |

### Backend Setup

```bash
cd scamshield_api

# Install dependencies
pip install -r requirements.txt

# Set environment variables
export GEMMA_API_KEY="your_google_ai_api_key"
export API_BASE_URL="http://localhost:8000"   # optional

# Run the server
uvicorn app.main:app --reload --port 8000
```

The API will be available at `http://localhost:8000`. Interactive docs at `http://localhost:8000/docs`.

### Flutter App Setup

```bash
# Install dependencies
flutter pub get

# Point the app at your backend (edit if self-hosting)
# lib/core/constants/app_constants.dart → apiBaseUrl

# Run on a connected Android device
flutter run

# Or build a release APK (arm64 recommended for modern phones)
flutter build apk --release --split-per-abi
# Output: build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

#### Required Android Permissions

Declared in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECEIVE_SMS"/>
<uses-permission android:name="android.permission.READ_SMS"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

---

## Project Structure

```
grab-the-future-hackathon/
├── lib/
│   ├── app/
│   │   ├── app.dart                  # MaterialApp, routes, theme
│   │   └── routes.dart               # Named route constants
│   ├── core/
│   │   ├── constants/app_constants.dart
│   │   └── theme/
│   │       ├── app_colors.dart
│   │       ├── app_text_styles.dart
│   │       └── app_theme.dart
│   ├── src/
│   │   ├── models/
│   │   │   ├── analysis_request.dart
│   │   │   ├── analysis_response.dart  # AI response schema
│   │   │   ├── chat_history_item.dart  # Persisted chat analyses
│   │   │   └── sms_alert.dart
│   │   ├── providers/
│   │   │   ├── chat_provider.dart      # Chat state + streaming
│   │   │   └── cooling_off_provider.dart
│   │   └── services/
│   │       ├── justful_api.dart        # HTTP/WebSocket client
│   │       └── sms_detection_service.dart
│   └── ui/
│       ├── screens/                    # One file per screen
│       └── widgets/                    # Shared widgets
│
├── scamshield_api/
│   ├── app/
│   │   ├── main.py                   # FastAPI entry point
│   │   ├── config.py                 # Settings (API keys)
│   │   ├── agents/
│   │   │   └── prompts.py            # System prompt (4 AI agents)
│   │   ├── models/
│   │   │   └── schemas.py            # Pydantic request/response models
│   │   └── routers/
│   │       ├── analyze.py            # /analyze, /chat, /contract, /detect-scam
│   │       └── live_monitor.py       # WebSocket live call monitoring
│   └── requirements.txt
│
├── pubspec.yaml
└── README.md
```

---

## Screens

| Route | Screen | Purpose |
|-------|--------|---------|
| `/` | Splash / Onboarding | First-launch welcome flow |
| `/home` | Home Dashboard | Stats, recent alerts, quick-check CTA |
| `/chat` | AI Chat | Voice/text input → streaming AI analysis |
| `/scam-result` | Scam Result Card | Full risk report after analysis completes |
| `/cooling-off` | Cooling-Off Timer | 48-hour pause before financial decision |
| `/contract-analysis` | Contract Analysis | Photo → AI contract risk review |
| `/family` | Family Guardian | Manage family alert contacts |
| `/live-monitor` | Live Monitor | Real-time call scam detection |
| `/settings` | Settings | App preferences |

---

## API Reference

### `POST /analyze`
Stream-analyze user text + optional image.

**Request**
```json
{
  "text": "Tin nhắn nghi ngờ...",
  "image_base64": "base64string | null",
  "history": [
    { "role": "user", "content": "..." },
    { "role": "assistant", "content": "..." }
  ]
}
```

**Response** — `text/plain` stream of JSON chunks:
```
<thought>AI reasoning here...</thought>
{"risk_level":"high","case_type":"investment_scam",...}
```

---

### `POST /chat`
Stream a conversational follow-up (no image support).

**Request**
```json
{ "text": "...", "history": [...] }
```

**Response** — same streaming format as `/analyze`.

---

### `POST /contract`
Non-streaming contract/document image analysis.

**Request**
```json
{ "image_base64": "base64string" }
```

**Response** — `AnalysisResponse` JSON object (see schema below).

---

### `POST /detect-scam`
Analyze an SMS message (called by the background SMS listener).

**Request**
```json
{ "sender": "NHANHANG-SHB", "body": "Tài khoản của bạn..." }
```

**Response** — `AnalysisResponse` JSON object. High/critical results also fire a Telegram notification.

---

### `AnalysisResponse` Schema

```json
{
  "risk_level": "critical | high | medium | low",
  "case_type": "investment_scam | lottery_scam | romance_scam | phishing | ...",
  "stage": "Nhận lời mời | Đang tư vấn | Chuẩn bị ký | Đã chuyển tiền | Chưa rõ",
  "red_flags": [
    { "type": "time_pressure | gift_bait | deposit | impersonation | investment | isolation | authority", "detail": "..." }
  ],
  "manipulation_tactics": ["urgency", "scarcity", "fear", "..."],
  "next_actions": ["Không chuyển tiền", "Hỏi người thân", "..."],
  "cooling_off": true,
  "cooling_off_hours": 48,
  "explanation": "Giải thích thân thiện bằng tiếng Việt...",
  "suggested_reply": "Gợi ý trả lời an toàn...",
  "follow_up_questions": ["Họ đã yêu cầu bạn chuyển tiền chưa?", "..."]
}
```

> `cooling_off` is always `true` when `risk_level` is `critical` or `high`.

---

## AI Agent System

The system prompt (`scamshield_api/app/agents/prompts.py`) chains four specialized agents into a single Gemini call:

```
User Input
    │
    ▼
[1] Intake Agent        — Who, what, stage, pressure level
    │
    ▼
[2] Red Flag Agent      — time_pressure, gift_bait, deposit,
                          impersonation, investment fraud (>15%/month),
                          isolation, fake authority
    │
    ▼
[3] Pressure Agent      — urgency, scarcity, social_proof,
                          reciprocity, liking, fear tactics
    │
    ▼
[4] Contract Agent      — penalty clauses, vague profit definitions,
                          missing contacts, fake seals, sign-now pressure
    │
    ▼
Structured JSON Output (Vietnamese)
```

**Security**: All user input is wrapped in `[USER SUBMITTED CONTENT START/END]` delimiters to prevent prompt injection.

**Agentic loop**: When `follow_up_questions` is non-empty, the app displays them as tappable chips. The user's answer is appended to the conversation history and re-submitted, giving the AI more context before the final verdict.

---

## Design System

Accessibility-first design language targeting elderly Vietnamese users:

| Token | Value | Notes |
|-------|-------|-------|
| Primary color | `#1AADBB` (Shield Teal) | Brand identity |
| Min font size | 16 px | Body text minimum |
| Body font size | 18 px | All content |
| Touch target min | 56 px | Buttons & interactive areas |
| Card border radius | 20 px | — |
| Button border radius | 16 px | — |
| Font | Plus Jakarta Sans | Modern, Vietnamese diacritic support |
| Spacing scale | 8 / 16 / 24 / 32 / 48 px | 8 px grid |
| Cooling-off period | 48 hours | Legal safe period |

---

## Building for Production

```bash
# ARM64 — recommended for modern Android phones (~19 MB)
flutter build apk --release --split-per-abi

# Universal APK — all ABIs, no Play Store needed (~52 MB)
flutter build apk --release
```

> Debug builds bundle the Dart VM + all ABIs (~150 MB). Always use `--release` for device testing.

---

## Team

Built for the **Grab the Future Hackathon**.  
Repository: [ShayNeeo/grab-the-future-hackathon](https://github.com/ShayNeeo/grab-the-future-hackathon)
