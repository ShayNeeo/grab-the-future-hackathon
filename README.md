# Justful — AI Scam Shield for Elderly Users

> **Grab the Future Hackathon** · Bảo vệ người cao tuổi khỏi lừa đảo bằng AI

Justful is a Flutter mobile app paired with a FastAPI backend that protects elderly Vietnamese users from scams in real time. It analyzes messages, images, voice input, and SMS using Google Gemini 2.5 Flash, returning structured risk assessments in plain Vietnamese.

---

## Table of Contents

- [Problem Statement](#problem-statement)
- [Solution Overview](#solution-overview)
- [Features](#features)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Backend Setup](#backend-setup)
  - [Flutter App Setup](#flutter-app-setup)
- [User Guide](#user-guide)
- [Project Structure](#project-structure)
- [Screens](#screens)
- [API Reference](#api-reference)
- [AI Agent System](#ai-agent-system)
- [Design System](#design-system)
- [Building for Production](#building-for-production)
- [Attribution & Licensing](#attribution--licensing)

---

## Problem Statement

Vietnam has one of the fastest-growing elderly populations in Southeast Asia, yet older adults are disproportionately targeted by scammers — through fake investment schemes, impersonation calls (pretending to be police, banks, or relatives), lottery fraud, and romance scams. Most existing cybersecurity tools assume technical literacy and require reading small text or navigating complex interfaces, leaving elderly users unprotected.

**The core problem**: Elderly Vietnamese users cannot reliably tell the difference between a legitimate message and a sophisticated scam, and they have no accessible, real-time tool to help them verify before they act.

---

## Solution Overview

Justful is an accessibility-first AI assistant designed specifically for elderly Vietnamese users. It acts as a "digital guardian" that:

1. **Listens or reads** — accepts voice narration, typed text, photos of messages/contracts, or SMS forwarded from the background
2. **Analyzes in real time** — sends input to a Gemini 2.5 Flash model guided by a 4-agent prompt chain (Intake → Red Flag → Pressure → Contract)
3. **Explains plainly** — returns a risk verdict (AN TOÀN / medium / high / critical) with a friendly Vietnamese explanation and concrete next steps, sized for large-print readability
4. **Protects proactively** — a 48-hour cooling-off timer blocks impulsive financial decisions; family members can be alerted automatically

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

## User Guide

### App Flow Overview

```
Launch
  │
  ▼
Splash Screen (3 s)
  │
  ▼
Onboarding  ──── tap "Bắt đầu" ────►  Home Dashboard
                                            │
                          ┌─────────────────┼───────────────────┐
                          ▼                 ▼                   ▼
                     Trợ lý AI        Gia đình             (other features
                     (Chat)           (Family)              via Home CTA)
                          │
               ┌──────────┴──────────┐
               ▼                     ▼
          Voice Mode            Text Mode
               │                     │
               └──────────┬──────────┘
                          ▼
                    AI Streams Response
                          │
               ┌──────────┴──────────┐
               ▼                     ▼
       Follow-up questions?     Final Result Card
       (tap chip to answer)     (inline in chat)
               │                     │
               └──────────┬──────────┘
                          ▼
                   Cooling-Off Timer
                   (optional, 48 h)
```

---

### 1. Splash & Onboarding

- The splash screen displays for ~3 seconds and auto-navigates to the onboarding screen.
- Onboarding introduces the app purpose; tap **Bắt đầu** to proceed to the Home Dashboard.

---

### 2. Home Dashboard

The home screen (bottom nav → **Trang chủ**) shows:

- **Stats** — total checks done, safe results, and SMS scam alerts detected.
- **Recent analyses** — last few chat sessions with their risk level.
- **SMS alerts** — suspicious messages auto-detected in the background.
- **Kiểm tra ngay** button — quick shortcut to the AI chat.

---

### 3. AI Chat — Analyzing a Suspicious Message

Navigate via the bottom nav → **Trợ lý AI** or tap **Kiểm tra ngay** on the Home Dashboard.

#### Voice Mode (default)

1. Tap the large round microphone button in the center of the screen.
2. Read the suspicious message aloud, or describe the situation.
3. The button changes color while recording; release or tap again to stop.
4. The AI streams its analysis with a live thinking indicator.
5. The **result card appears inline** in the chat (no navigation away).

#### Text Mode

1. Tap the **Văn bản** toggle at the top to switch to text mode.
2. Type or paste the suspicious message in the input bar.
3. Optionally attach an image (📎 icon) — pick from gallery or take a photo.
4. Tap **Send**. The AI analyzes and replies inline.

#### Agentic Loop (follow-up questions)

- If the AI needs more context, it shows tappable question chips below its reply (e.g., "Họ có yêu cầu chuyển tiền không?").
- Tap a chip to send that answer automatically; the AI re-analyzes and produces a final verdict.

---

### 4. Reading the Inline Result Card

The result card appears directly inside the chat bubble after analysis completes:

| Banner color | Risk level | Meaning |
| --- | --- | --- |
| Green | AN TOÀN | No clear scam signs detected |
| Amber | RỦI RO TRUNG BÌNH | Some suspicious signals — stay alert |
| Orange | RỦI RO CAO | Strong scam indicators — do not act yet |
| Red | RỦI RO RẤT CAO | Critical — stop all contact immediately |

Below the banner: **Dấu hiệu nguy hiểm** lists each detected red flag with a short explanation. If no flags are found, a green "no flags" notice is shown instead.

---

### 5. Cooling-Off Timer

- Accessible from the Home Dashboard or via **⏱️ Bật chế độ suy nghĩ Xh** (shown after a high/critical result).
- Starts a 48-hour countdown that serves as a pause before making any financial decision (signing, transferring money).
- The timer persists across app restarts and is shown on the Home Dashboard until it expires.

---

### 6. Contract / Document Analysis

- From the Home Dashboard, tap **Phân tích hợp đồng**.
- Take a photo of the contract or document, or pick from gallery.
- The AI scans for risky clauses, vague profit definitions, missing contacts, fake seals, and sign-now pressure.

---

### 7. Family Guardian

Navigate via the bottom nav → **Gia đình**:

- Add a family member's phone number or contact.
- When a medium/high/critical risk SMS is detected, the family member receives an automatic alert.
- Family members can also view the alert history.

---

### 8. SMS Auto-Detection (Background)

- On first launch, the app requests SMS permission.
- Once granted, incoming SMS messages are automatically forwarded to the backend `/detect-scam` endpoint.
- If the result is medium or above, a notification is shown and the alert is logged on the Home Dashboard.
- No user action is needed — this runs silently in the background.

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

---

## Attribution & Licensing

### Dependency files

| File | Purpose |
| --- | --- |
| `pubspec.yaml` / `pubspec.lock` | Flutter package dependencies |
| `scamshield_api/requirements.txt` | Python backend dependencies |
| `scamshield_api/.env.example` | Environment variable template (copy to `.env` and fill in keys) |

### Third-party packages

All Flutter packages are listed in `pubspec.yaml` and sourced from [pub.dev](https://pub.dev) under their respective open-source licenses. All Python packages are listed in `requirements.txt` and sourced from [PyPI](https://pypi.org).

Key dependencies include:

- **Flutter / Dart** — BSD 3-Clause
- **Riverpod** — MIT
- **Dio** — MIT
- **Google Fonts** — Apache 2.0 (Plus Jakarta Sans font — SIL Open Font License)
- **FastAPI** — MIT
- **Pydantic** — MIT
- **OpenAI Python SDK** — MIT (used to call Google Gemini via OpenAI-compatible endpoint)
- **Google Gemini 3.1 Flash Lite** — accessed via Google AI Studio API; subject to [Google Generative AI Terms of Service](https://ai.google.dev/terms)

### AI-generated code disclosure

Portions of this codebase were written with assistance from **Claude (Anthropic)** as an AI coding assistant. All AI-generated code has been reviewed, tested, and integrated by the team. Use of AI assistance complies with the hackathon rules.
