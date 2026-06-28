# Justful API — ScamShield Backend

FastAPI backend that powers the Justful scam-detection app. Connects to Google Gemini 2.5 Flash via an OpenAI-compatible endpoint and returns structured JSON risk assessments in Vietnamese.

## Quick Start

```bash
# 1. Install dependencies
pip install -r requirements.txt

# 2. Configure environment
cp .env.example .env          # then fill in your key
# or export directly:
export GEMMA_API_KEY="your_google_ai_api_key"

# 3. Run
uvicorn app.main:app --reload --port 8000
```

- API: `http://localhost:8000`
- Swagger docs: `http://localhost:8000/docs`
- Redoc: `http://localhost:8000/redoc`

## Environment Variables

| Variable | Required | Description |
|---|---|---|
| `GEMMA_API_KEY` | Yes | Google AI Studio API key |
| `TELEGRAM_BOT_TOKEN` | No | Bot token for SMS scam alerts |
| `TELEGRAM_CHAT_ID` | No | Chat ID to receive Telegram alerts |

## Endpoints

### `POST /analyze`
Streaming analysis of text + optional image. Returns newline-delimited JSON chunks.

```bash
curl -X POST http://localhost:8000/analyze \
  -H "Content-Type: application/json" \
  -d '{"text": "Bạn đã trúng thưởng 500 triệu...", "history": []}'
```

### `POST /chat`
Streaming conversational follow-up (text only).

```bash
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"text": "Họ yêu cầu tôi đặt cọc 5 triệu", "history": [...]}'
```

### `POST /contract`
Non-streaming contract/document image analysis.

```bash
curl -X POST http://localhost:8000/contract \
  -H "Content-Type: application/json" \
  -d '{"image_base64": "<base64>"}'
```

### `POST /detect-scam`
Analyze an incoming SMS. High/critical results also fire a Telegram alert.

```bash
curl -X POST http://localhost:8000/detect-scam \
  -H "Content-Type: application/json" \
  -d '{"sender": "NHANHANG-SHB", "body": "Tài khoản bị khóa..."}'
```

### `WS /live-monitor/ws`
WebSocket endpoint for real-time call monitoring.

## Response Schema

All endpoints return an `AnalysisResponse`:

```json
{
  "risk_level": "critical | high | medium | low",
  "case_type": "string",
  "stage": "string",
  "red_flags": [{ "type": "string", "detail": "string" }],
  "manipulation_tactics": ["string"],
  "next_actions": ["string"],
  "cooling_off": true,
  "cooling_off_hours": 48,
  "explanation": "Vietnamese explanation for elderly user",
  "suggested_reply": "Safe reply suggestion",
  "follow_up_questions": ["string"]
}
```

## Project Layout

```
scamshield_api/
├── app/
│   ├── main.py           # FastAPI app, CORS, router registration
│   ├── config.py         # Pydantic settings (reads env vars)
│   ├── agents/
│   │   └── prompts.py    # 4-agent system prompt for Gemini
│   ├── models/
│   │   └── schemas.py    # Pydantic request/response models
│   └── routers/
│       ├── analyze.py    # /analyze /chat /contract /detect-scam
│       └── live_monitor.py  # WebSocket live call monitoring
├── requirements.txt
├── Procfile              # Heroku/Railway deployment
└── README.md
```

## Deployment

The `Procfile` is configured for Heroku / Railway:

```
web: uvicorn app.main:app --host 0.0.0.0 --port $PORT
```

Set `GEMMA_API_KEY` as an environment variable in your platform's dashboard.
