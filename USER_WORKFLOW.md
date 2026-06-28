# Justful — User Workflow

> End-to-end user journey for the Justful AI Scam Shield app.

---

## Table of Contents

- [High-Level Flow](#high-level-flow)
- [Flow 1 — First Launch](#flow-1--first-launch)
- [Flow 2 — Checking a Suspicious Message (Voice)](#flow-2--checking-a-suspicious-message-voice)
- [Flow 3 — Checking a Suspicious Message (Text + Image)](#flow-3--checking-a-suspicious-message-text--image)
- [Flow 4 — AI Agentic Loop (Follow-Up Questions)](#flow-4--ai-agentic-loop-follow-up-questions)
- [Flow 5 — Reading the Result Card](#flow-5--reading-the-result-card)
- [Flow 6 — Cooling-Off Timer](#flow-6--cooling-off-timer)
- [Flow 7 — Contract / Document Analysis](#flow-7--contract--document-analysis)
- [Flow 8 — Family Guardian](#flow-8--family-guardian)
- [Flow 9 — SMS Auto-Detection (Background)](#flow-9--sms-auto-detection-background)
- [Screen Map](#screen-map)

---

## High-Level Flow

```
┌─────────────┐
│   Launch    │
└──────┬──────┘
       │ auto (3 s)
       ▼
┌─────────────┐     tap "Bắt đầu"    ┌──────────────────┐
│  Onboarding │ ──────────────────►  │  Home Dashboard  │
└─────────────┘                      └────────┬─────────┘
                                              │
                       ┌──────────────────────┼──────────────────────┐
                       ▼                      ▼                      ▼
              ┌────────────────┐   ┌──────────────────┐   ┌──────────────────┐
              │  Trợ lý AI     │   │   Gia đình       │   │  CTAs on Home    │
              │  (Chat)        │   │   (Family)       │   │  (Contract, etc.)│
              └───────┬────────┘   └──────────────────┘   └──────────────────┘
                      │
           ┌──────────┴──────────┐
           ▼                     ▼
     Voice Mode             Text Mode
           │                     │
           └──────────┬──────────┘
                      ▼
             AI Streams Response
                      │
           ┌──────────┴──────────┐
           ▼                     ▼
   Follow-up questions?    Final Result Card
   (tap chip to answer)    (inline in chat)
           │                     │
           └──────────┬──────────┘
                      ▼
             Optional next steps:
             Cooling-Off Timer
             Share with family
```

---

## Flow 1 — First Launch

```
App opens
    │
    ▼
┌──────────────────────────────────────┐
│  Splash Screen                       │
│  • Justful logo animates in          │
│  • Auto-advances after 3 seconds     │
└──────────────────┬───────────────────┘
                   │ (auto)
                   ▼
┌──────────────────────────────────────┐
│  Onboarding Screen                   │
│  • Brief intro to Justful            │
│  • "Bắt đầu" CTA button             │
└──────────────────┬───────────────────┘
                   │ tap "Bắt đầu"
                   ▼
         Home Dashboard  ✓
```

**Permission prompts** shown on first launch (Android):
- SMS (`READ_SMS`, `RECEIVE_SMS`) — needed for background auto-detection
- Microphone (`RECORD_AUDIO`) — needed for voice input
- Camera — needed for document/contract photo

> Granting all permissions unlocks the full feature set. The app works without them but with reduced capability.

---

## Flow 2 — Checking a Suspicious Message (Voice)

This is the **primary use case**. Target user: elderly adult who received a suspicious call or message.

```
Home Dashboard
    │
    │ tap "Kiểm tra ngay" (or bottom nav → Trợ lý AI)
    ▼
┌──────────────────────────────────────┐
│  Chat Screen — Voice Mode (default)  │
│                                      │
│  "Chào bác, bác hãy nhấn nút tròn   │
│   to ở giữa màn hình..."             │
│                                      │
│         ╔══════════╗                 │
│         ║  🎙️ mic  ║  ◄── tap        │
│         ╚══════════╝                 │
└──────────────────┬───────────────────┘
                   │ tap microphone
                   ▼
          Recording in progress
          (mic button pulses)
                   │
                   │ tap again to stop  (or silence detected)
                   ▼
┌──────────────────────────────────────┐
│  AI Streaming                        │
│  • User voice transcript appears     │
│  • Thinking indicator shows status:  │
│    "AI đang tiếp nhận tin nhắn..."   │
│    "Đang đối chiếu dấu hiệu lừa đảo" │
│    "Đang kiểm tra chiến thuật tâm lý"│
└──────────────────┬───────────────────┘
                   │ stream completes
                   ▼
          Result Card (inline)  →  see Flow 5
```

---

## Flow 3 — Checking a Suspicious Message (Text + Image)

```
Chat Screen
    │
    │ tap "Văn bản" toggle (top of screen)
    ▼
┌──────────────────────────────────────┐
│  Chat Screen — Text Mode             │
│                                      │
│  ┌────────────────────────────────┐  │
│  │ Type or paste message here...  │  │
│  └────────────────────────────────┘  │
│   📎                          Send ► │
└──────────────────┬───────────────────┘
                   │
          ┌────────┴────────┐
          │ Text only        │ Text + Image
          │                  │
          │                  │ tap 📎 icon
          │                  ▼
          │         ┌─────────────────┐
          │         │ Pick source:    │
          │         │  📷 Camera      │
          │         │  🖼️ Gallery     │
          │         └────────┬────────┘
          │                  │ image selected
          └────────┬─────────┘
                   │ tap Send
                   ▼
          AI Streaming  →  Result Card (inline)
```

> **Image analysis** is most useful for photographing a suspicious contract, official-looking letter, or forwarded screenshot of a scam message.

---

## Flow 4 — AI Agentic Loop (Follow-Up Questions)

When the AI lacks enough context to make a confident verdict, it enters an agentic loop.

```
First AI reply received
    │
    │ response has follow_up_questions
    ▼
┌──────────────────────────────────────┐
│  Chat shows question chips:          │
│                                      │
│  ┌──────────────────────────────┐    │
│  │ Họ yêu cầu chuyển tiền chưa?│    │
│  └──────────────────────────────┘    │
│  ┌──────────────────────────────┐    │
│  │ Bác có biết người gửi không? │    │
│  └──────────────────────────────┘    │
└──────────────────┬───────────────────┘
                   │ tap a chip
                   ▼
          Chip text sent as user message
                   │
                   ▼
          AI re-analyzes with full context
                   │
           ┌───────┴───────┐
           ▼               ▼
   More questions?    Final verdict
   (repeat loop)      Result Card (inline)
```

> The loop ends when `follow_up_questions` is empty. Up to 2–3 rounds are typical for ambiguous situations.

---

## Flow 5 — Reading the Result Card

The result card appears **inline in the chat** after the final analysis. No separate screen navigation.

```
┌─────────────────────────────────────────┐
│  ╔═══════════════════════════════════╗  │
│  ║  ✅  AN TOÀN          (green)     ║  │
│  ╠═══════════════════════════════════╣  │
│  ║  ⚠️  RỦI RO TRUNG BÌNH (amber)   ║  │
│  ╠═══════════════════════════════════╣  │
│  ║  🔶  RỦI RO CAO       (orange)   ║  │
│  ╠═══════════════════════════════════╣  │
│  ║  🛑  RỦI RO RẤT CAO  (red)      ║  │
│  ╚═══════════════════════════════════╝  │
│                                         │
│  Dấu hiệu nguy hiểm phát hiện được     │
│  ─────────────────────────────────────  │
│  ① time_pressure  — "Chỉ còn hôm nay" │
│  ② deposit        — Yêu cầu đặt cọc   │
│                                         │
│  (or green "không phát hiện..." notice) │
└─────────────────────────────────────────┘
```

**What each risk level means:**

| Level | Banner | Meaning | Recommended action |
| --- | --- | --- | --- |
| `low` | Green — AN TOÀN | No clear scam signs | Normal caution |
| `medium` | Amber — RỦI RO TRUNG BÌNH | Some suspicious signals | Ask a family member |
| `high` | Orange — RỦI RO CAO | Strong scam indicators | Do NOT act, use cooling-off |
| `critical` | Red — RỦI RO RẤT CAO | Definite scam attempt | Block immediately, alert family |

After the result card, the chat may also show:
- **Gợi ý trả lời** — a safe suggested reply to send (low/medium only)
- **Khuyên dùng an toàn** — "Block this number, do not reply" (high/critical)

---

## Flow 6 — Cooling-Off Timer

Designed to prevent impulsive financial decisions (signing contracts, transferring money).

```
Any high / critical result card
    │
    │ tap "⏱️ Bật chế độ suy nghĩ 48h"
    ▼
┌──────────────────────────────────────┐
│  Cooling-Off Timer Screen            │
│                                      │
│        48:00:00  (countdown)         │
│    ████████████░░░░░░  progress ring │
│                                      │
│  "Đừng ký hoặc chuyển tiền          │
│   cho đến khi hết thời gian này"    │
│                                      │
│  [Chia sẻ với gia đình]             │
│  [Huỷ bộ đếm]                       │
└──────────────────┬───────────────────┘
                   │ timer expires or user cancels
                   ▼
          Home Dashboard
          (timer badge disappears)
```

**Key behaviors:**
- Timer persists across app restarts (stored in SharedPreferences).
- Displayed as a badge on the Home Dashboard while active.
- Share button lets the user forward the warning to a family member.

---

## Flow 7 — Contract / Document Analysis

```
Home Dashboard
    │
    │ tap "Phân tích hợp đồng" CTA
    ▼
┌──────────────────────────────────────┐
│  Contract Analysis Screen            │
│                                      │
│  [📷 Chụp ảnh hợp đồng]             │
│  [🖼️ Chọn từ thư viện]              │
└──────────────────┬───────────────────┘
                   │ image selected
                   ▼
          POST /contract  (non-streaming)
          AI scans for:
          • Penalty clauses
          • Vague profit definitions
          • Missing contact info
          • Fake seals / signatures
          • Sign-now pressure
                   │
                   ▼
          Risk result displayed on screen
          (same risk level / red flags format)
```

---

## Flow 8 — Family Guardian

```
Bottom nav → Gia đình
    │
    ▼
┌──────────────────────────────────────┐
│  Family Guardian Screen              │
│                                      │
│  "Gia đình của tôi"                  │
│  "Người thân sẽ nhận cảnh báo..."   │
│                                      │
│  [+ Thêm thành viên gia đình]       │
│                                      │
│  ┌────────────────────────────────┐  │
│  │ 👤 Nguyễn Văn A  (Con trai)   │  │
│  │    📞 0901 234 567             │  │
│  └────────────────────────────────┘  │
└──────────────────────────────────────┘

When risk ≥ medium is detected (via chat or SMS):
    │
    ▼
Telegram / notification alert sent to family member
containing: sender, message snippet, risk level, explanation
```

---

## Flow 9 — SMS Auto-Detection (Background)

No user action needed after initial permission grant.

```
SMS arrives on device
    │
    ▼ (SmsDetectionService — background)
POST /detect-scam
{ sender, body }
    │
    ▼
AI analyzes SMS
    │
    ├── risk: low  ──►  silent (no notification)
    │
    ├── risk: medium / high / critical
    │       │
    │       ├──► Push notification to user
    │       │    "⚠️ Tin nhắn đáng ngờ từ [sender]"
    │       │
    │       ├──► Alert saved to Home Dashboard
    │       │    (tap to read full explanation)
    │       │
    │       └──► Telegram alert sent to family
    │            (if family contacts configured)
    │
    └── User taps notification  ──►  Home Dashboard
                                     (alert highlighted)
```

---

## Screen Map

| Screen | Route | Bottom Nav | Entry points |
| --- | --- | --- | --- |
| Splash | `/` | — | App launch |
| Onboarding | `/onboarding` | — | Auto from Splash |
| Home Dashboard | `/home` | Tab 0 — Trang chủ | Onboarding, back nav |
| AI Chat | `/chat` | Tab 1 — Trợ lý AI | Home CTA, bottom nav |
| Cooling-Off Timer | `/cooling-off` | — | Result card button, Home CTA |
| Contract Analysis | `/contract-analysis` | — | Home CTA |
| Family Guardian | `/family` | Tab 2 — Gia đình | Bottom nav |
| Live Monitor | `/live-monitor` | — | Home CTA |
| Settings | `/settings` | — | Home screen icon |
