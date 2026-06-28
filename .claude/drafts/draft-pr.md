---
title: "feat(api): add Telegram bot scam alert notifications"
base: main
head: feat/#41-telegram-scam-alerts
issue: 41
labels: [enhancement]
draft: false
---

## Summary

Add a Telegram bot that sends scam alerts to registered users whenever an incoming SMS is detected as fraudulent. The bot runs as a separate service on port 8086, and the main backend calls it when a scam is detected via the new `/detect-scam` endpoint. This allows family members and caregivers to monitor scam threats in real-time from anywhere.

Closes #41

## What Changed

- [ ] Flutter UI / screens
- [ ] Flutter state / providers
- [ ] Flutter routing / navigation
- [x] Backend (scamshield_api)
- [ ] Tests
- [ ] CI / config

## Changes

### Telegram Bot Service (`telegram_bot/`)
- Standalone FastAPI + python-telegram-bot service on port 8086
- `/start` command registers user's `chat_id` to a local JSON file
- `/stop` and `/status` commands for user management
- `POST /notify` endpoint sends formatted scam alerts to all registered users
- `GET /health` for monitoring
- Polling mode (no public domain/webhook needed)

### Main Backend (`scamshield_api/`)
- New `POST /detect-scam` endpoint accepting `{sender, body}`
- Analyzes SMS with Gemini AI
- If risk_level is medium/high/critical, calls Telegram bot's `/notify`
- Added `httpx` for async HTTP calls to bot service
- Added `telegram_bot_url` config setting

### Flutter App
- `SmsDetectionService.processSms()` now calls `/detect-scam` instead of `/analyze`
- Request body changed from `{text, history}` to `{sender, body}`
- Response is now direct JSON (not streamed)

## Verification

```bash
# Check bot health
curl http://localhost:8086/health

# Check main backend health
curl http://localhost:8085/health

# Test detect-scam endpoint
curl -X POST http://localhost:8085/detect-scam \
  -H "Content-Type: application/json" \
  -d '{"sender": "+84901234567", "body": "Ban da trung thuong 100 trieu"}'
```

## Breaking Changes

None — existing `/analyze` and `/chat` endpoints remain unchanged.

## Follow-Up

- Add group chat support for Telegram bot
- Add rate limiting on `/detect-scam` endpoint
- Add Telegram bot commands to check scam history
