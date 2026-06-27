---
title: "[Task] Wire ScamResultCardScreen to receive real AnalysisResponse via route args"
kind: issue
template: fallback
labels: [task]
---

## Summary

`ScamResultCardScreen` currently displays hardcoded Vietnamese demo data (a holiday-contract scam with three fixed red flags) regardless of what the AI actually analyzed. The real `AnalysisResponse` is already returned from the `/analyze` endpoint and stored in `ChatMessage.response` inside `chatProvider`, but `ChatScreen._sendMessage()` never navigates away after the API call completes, so the result screen is unreachable from the chat flow at all. This task wires the three-layer gap: constructor → route → navigation trigger.

## Context

The agentic backend returns a structured `AnalysisResponse` (risk level, case type, stage, red flags, manipulation tactics, next actions, cooling-off flag, suggested reply, follow-up questions). The provider stores it in `ChatMessage.response` (see `lib/src/providers/chat_provider.dart:12`). The result screen exists and is well-designed, but it reads only from its own hardcoded literals instead of that response object.

## Affected files

| File | Current problem |
|---|---|
| [lib/ui/screens/scam_result_card_screen.dart](lib/ui/screens/scam_result_card_screen.dart) | No constructor params; all data is hardcoded literals (lines 59, 76–78, 86–88, 107–123, 159–163) |
| [lib/app/routes.dart](lib/app/routes.dart) | `scamResult` entry (line 29) constructs `ScamResultCardScreen()` with no args; named routes map can't pass typed objects |
| [lib/ui/screens/chat_screen.dart](lib/ui/screens/chat_screen.dart) | `_sendMessage()` (lines 39–49) calls `ref.read(p.chatProvider.notifier).send(...)` then returns — no navigation on success |

## Proposed behavior (step-by-step)

1. **Add `AnalysisResponse` parameter to `ScamResultCardScreen`.**
   Replace `const ScamResultCardScreen({super.key})` with:

   ```dart
   ScamResultCardScreen({super.key, required this.analysis});
   final AnalysisResponse analysis;
   ```

   Remove the `RiskBanner(level: RiskLevel.critical)` hardcode; replace with `RiskBanner(level: analysis.riskLevel)`. Replace the hardcoded case-type chip, stage text, `_RedFlagRow` list, and `_TacticPill` list with data from `analysis`.

2. **Switch the `/scam-result` route to `onGenerateRoute`.**
   The simple `routes` map (`Map<String, WidgetBuilder>`) has no access to `RouteSettings.arguments`, so it cannot pass a typed object. In `app.dart` where `MaterialApp` is configured, move the `scamResult` entry out of the `routes` map and handle it in `onGenerateRoute`:

   ```dart
   onGenerateRoute: (settings) {
     if (settings.name == AppRoutes.scamResult) {
       final analysis = settings.arguments as AnalysisResponse;
       return MaterialPageRoute(
         builder: (_) => ScamResultCardScreen(analysis: analysis),
         settings: settings,
       );
     }
     return null; // fall through to routes map
   },
   ```

   Remove the `scamResult` entry from `AppRoutes.routes`.

3. **Trigger navigation from `ChatScreen` after the API responds.**
   In `_ChatScreenState.build()`, add a `ref.listen` that fires when the provider transitions from loading → data:

   ```dart
   ref.listen<AsyncValue<List<p.ChatMessage>>>(p.chatProvider, (prev, next) {
     if (prev?.isLoading == true && next.hasValue) {
       final msgs = next.value!;
       final last = msgs.isNotEmpty ? msgs.last : null;
       if (last != null && last.response != null) {
         Navigator.pushNamed(
           context,
           AppRoutes.scamResult,
           arguments: last.response,
         );
       }
     }
   });
   ```

4. **Replace all hardcoded data in `ScamResultCardScreen` with real fields.**

   | Hardcoded value | Replace with |
   | --- | --- |
   | `RiskLevel.critical` (line 59) | `analysis.riskLevel` |
   | `'Hợp đồng kỳ nghỉ'` (line 76) | `analysis.caseType` |
   | `'Trước khi đặt cọc'` (line 87) | `analysis.stage` |
   | Three hardcoded `_RedFlagRow(...)` widgets | `analysis.redFlags.asMap().entries.map(...)` |
   | Three hardcoded `_TacticPill(...)` widgets | `analysis.manipulationTactics.map((t) => _TacticPill(label: t))` |

## Acceptance criteria

- [ ] Sending a message in `ChatScreen` and receiving an AI response automatically pushes `ScamResultCardScreen` onto the navigation stack.
- [ ] `ScamResultCardScreen` displays the actual `riskLevel`, `caseType`, `stage`, `redFlags`, and `manipulationTactics` from the API response — not hardcoded strings.
- [ ] Navigating to `/cooling-off` from the result screen still works (the `ShieldButton` at line 187 uses `Navigator.pushNamed(context, '/cooling-off')` — no change needed there).
- [ ] `flutter analyze` reports no new errors or warnings.
- [ ] If `analysis.redFlags` is empty, the red-flags section renders gracefully (empty state text or hidden section).

## Out of scope

- Showing `follow_up_questions` in the chat UI (separate task — agentic loop).
- Wiring `ContractAnalysisScreen` to `/contract` endpoint (separate task).
- Persisting analysis history across sessions.

## Dependencies / Blockers

- `AnalysisResponse` model is complete: `lib/src/models/analysis_response.dart` already has all required fields with `fromJson` deserialization.
- `RiskBanner` widget already accepts a `RiskLevel` parameter — no widget changes needed.
- Backend `/analyze` endpoint must be running (`uvicorn app.main:app --reload` in `scamshield_api/`).

## References

- [lib/ui/screens/scam_result_card_screen.dart](lib/ui/screens/scam_result_card_screen.dart) — target screen (hardcoded data)
- [lib/app/routes.dart](lib/app/routes.dart) — named routes map
- [lib/ui/screens/chat_screen.dart](lib/ui/screens/chat_screen.dart) — navigation trigger point
- [lib/src/models/analysis_response.dart](lib/src/models/analysis_response.dart) — data model to pass
- [lib/src/providers/chat_provider.dart](lib/src/providers/chat_provider.dart) — where `AnalysisResponse` is stored after API call
