---
title: "[Fix] Update AI models to gemini-3.1-flash-lite and gemini-3-flash-live"
kind: issue
template: fallback
labels: [bug]
---

## Summary

The backend is using outdated AI models. Update the default analyze/chat model to `gemini-3.1-flash-lite` and the live monitor model to `gemini-3-flash-live`.

## Changes

- `scamshield_api/app/routers/analyze.py`: Change model from `gemini-2.5-flash` to `gemini-3.1-flash-lite`
- `scamshield_api/app/routers/live_monitor.py`: Change model from `gemini-2.0-flash-live-001` to `gemini-3-flash-live`

## Acceptance criteria

- [ ] `/analyze`, `/chat`, `/contract`, `/detect-scam` endpoints use `gemini-3.1-flash-lite`
- [ ] `/live-monitor` WebSocket uses `gemini-3-flash-live`
