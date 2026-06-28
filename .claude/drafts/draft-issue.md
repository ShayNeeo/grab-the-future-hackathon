---
title: "[Feature] Telegram bot scam alert notifications"
kind: issue
template: fallback
labels: [enhancement]
---

## Summary

Add a Telegram bot that sends scam alerts to registered users whenever an incoming SMS is detected as fraudulent. The bot runs as a separate service on port 8086, and the main backend calls it when a scam is detected via the new `/detect-scam` endpoint.

## Motivation

Elderly users' family members or caregivers may not always be near the phone. By forwarding scam alerts to Telegram, guardians can monitor threats in real-time from anywhere.

## Requirements

### Telegram Bot Service (port 8086)
- Standalone Python service using `python-telegram-bot`
- `/start` command registers user's `chat_id` to a local JSON file
- `POST /notify` internal endpoint — receives scam details, sends formatted message to all registered users
- `GET /health` for monitoring
- Graceful error handling (user blocked bot, network failures, etc.)

### Main Backend Changes (port 8085)
- New `POST /detect-scam` endpoint accepting `{sender, body}`
- Calls Gemini AI to analyze the SMS
- If risk_level is medium/high/critical, calls Telegram bot's `/notify`
- Returns analysis response to caller

### Flutter App Changes
- Update `SmsDetectionService.processSms()` to call `/detect-scam` instead of `/analyze`

### Telegram Message Format
```
⚠️ CẢNH BÁO LỪA ĐẢO

📱 Từ: +84901234567
📝 Nội dung: "Bạn đã trúng thưởng..."
🔴 Mức độ: HIGH
🤖 Phân tích: Tin nhắn này có dấu hiệu lừa đảo...

— Justful Scam Shield
```

## Affected files

- `scamshield_api/app/routers/analyze.py` — new `/detect-scam` endpoint
- `scamshield_api/app/config.py` — add `telegram_bot_url` setting
- `scamshield_api/main.py` — no changes needed (router already included)
- `telegram_bot/` — new directory with bot service
- `lib/src/services/sms_detection_service.dart` — call `/detect-scam`

## Acceptance criteria

- [ ] User can send `/start` to the Telegram bot and get a welcome message
- [ ] When a scam SMS arrives, all registered Telegram users receive an alert
- [ ] Telegram alert contains sender, message preview, risk level, and AI analysis
- [ ] Bot service runs independently on port 8086
- [ ] Main backend on 8085 calls bot service when scam detected
- [ ] Flutter app calls `/detect-scam` instead of `/analyze` for SMS detection
