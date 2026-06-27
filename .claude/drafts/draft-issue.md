---
title: "[Feature] Show follow_up_questions in chat, user answers, and re-analyze (agentic loop)"
kind: issue
template: fallback
labels: [feature]
---

## Summary

Implement an agentic loop in the chat interface where follow-up questions from the AI analysis are displayed as suggestion chips. Tapping these chips or typing a response should trigger a re-analysis, providing the full chat history to the API for context.

## Context

When the `/analyze` endpoint returns `follow_up_questions`, they should be shown in the chat UI as suggestion chips below the AI message. The app should not immediately navigate to the `ScamResultCardScreen` if follow-up questions are present. Instead:
- Tapping a chip sends the question text as a new message.
- Sending a response (via chip tap or typing) triggers a new request to `/analyze` containing the conversation history.
- The loop continues until the AI response has no more `follow_up_questions`, at which point the app navigates to the result card.

## Affected files

- [lib/src/providers/chat_provider.dart](lib/src/providers/chat_provider.dart)
- [lib/ui/screens/chat_screen.dart](lib/ui/screens/chat_screen.dart)

## Proposed behavior

1. **Update `ChatMessage` model** to store and propagate `followUpQuestions`.
2. **Expose `history`** from `chatProvider` containing all prior user and assistant messages for contextual re-analysis.
3. **Render suggestion chips** below AI chat bubbles in `ChatScreen` if they contain follow-up questions.
4. **Conditionally navigate** to `ScamResultCardScreen` only when the latest analysis contains no more `follow_up_questions`.

## Acceptance criteria

- [ ] Vague messages (e.g. "Có người gọi điện cho tôi") trigger follow-up questions.
- [ ] Follow-up questions render as suggestion chips in the chat UI.
- [ ] Tapping a chip sends the message and runs a re-analysis.
- [ ] Full chat history is sent to the backend during the loop.
- [ ] If no follow-up questions remain, navigation to the result card is triggered.
