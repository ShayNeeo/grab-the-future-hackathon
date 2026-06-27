---
title: "[Fix] Critical bugs in SMS interception service"
kind: issue
template: fallback
labels: [bug]
---

## Summary

Code review of the SMS interception feature (`sms_detection_service.dart`) surfaced 9 bugs ranging from critical (background notifications silently never fire) to security (cleartext HTTP transmitting private SMS content) to low (unbounded storage growth). All are fixed in the same commit.

## Bugs fixed

### Critical
- **Background notifications never fired** — `backGroundMessageHandler` runs in a separate Dart isolate. `FlutterLocalNotificationsPlugin` was only initialized in the foreground isolate; the background instance was always fresh/uninitialized. Fixed by calling `initialize()` inside `backGroundMessageHandler` before invoking `processSms`.

### High – Security
- **Cleartext HTTP transmitted private SMS content and API keys** — `android:usesCleartextTraffic="true"` was set app-wide; the default API URL is plain HTTP. Replaced with `android:networkSecurityConfig` scoped to only the API host (`grab.w9.nu`), keeping all other domains HTTPS-only.
- **Notification ID collision** — `DateTime.now().millisecond` (range 0–999) used as notification ID caused the second alert within the same second to silently replace the first. Changed to `DateTime.now().millisecondsSinceEpoch % 0x7FFFFFFF`.

### Medium
- **Stream errors leaked internal exception details** — `_stream_model` yielded `f"Error: {e}"` into the HTTP 200 stream; HTTP client exceptions can include auth headers and internal URLs. Now yields `{"__error__":true}` instead.
- **Concurrent sends not guarded** — removing `AsyncValue.loading()` left no guard against double-sends during streaming. Added `_isSending` bool to `ChatNotifier` (returns early on re-entry, resets in `finally`) and grayed-out / disabled the send button in `ChatScreen` while streaming.
- **Force-unwrap on nullable `response.data`** — `response.data!.stream` could crash if the server returned an empty body. Changed to a null-check with early return.
- **Prompt injection via delimiter bypass** — user-supplied SMS text was wrapped in `[USER SUBMITTED CONTENT START]…[USER SUBMITTED CONTENT END]` delimiters with no sanitization. An attacker could embed the closing token to escape the trust boundary. Now strips the token from user input before wrapping.

### Low
- **Alert list grew unboundedly** — `_saveAlert` performed a full read-modify-write of the SharedPreferences list on every SMS with no cap. Added a 100-entry cap and same-sender+body deduplication.
- **`print()` in production catch block** — replaced with `debugPrint()` so it respects debug/release mode and integrates with crash reporters.

## Affected files

- [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml)
- [android/app/src/main/res/xml/network_security_config.xml](android/app/src/main/res/xml/network_security_config.xml) *(new)*
- [lib/src/services/sms_detection_service.dart](lib/src/services/sms_detection_service.dart)
- [lib/src/providers/chat_provider.dart](lib/src/providers/chat_provider.dart)
- [lib/ui/screens/chat_screen.dart](lib/ui/screens/chat_screen.dart)
- [scamshield_api/app/routers/analyze.py](scamshield_api/app/routers/analyze.py)

## Acceptance criteria

- [ ] Receiving a scam SMS while the app is backgrounded shows a system notification.
- [ ] App no longer sets `usesCleartextTraffic=true` app-wide; other domains still require HTTPS.
- [ ] Two scam SMS arriving within the same second produce two distinct notifications.
- [ ] A stream error from the API shows a user-friendly error message; no internal details in the response.
- [ ] Tapping Send while a response is streaming does nothing (button is visually disabled).
- [ ] SMS containing `[USER SUBMITTED CONTENT END]` is sanitized and does not escape the analysis prompt.
- [ ] Alert list in SharedPreferences never exceeds 100 entries; duplicate sender+body is not stored twice.
