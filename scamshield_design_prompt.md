# ScamShield — Flutter Mobile App UI/UX Design Prompt

---

## 🎯 Project Overview

**App name:** ScamShield (Lá Chắn Lừa Đảo)
**Platform:** Flutter (Android & iOS)
**Primary audience:** Elderly users (60–80 years old) in Vietnam — low tech-literacy, high scam vulnerability
**Secondary audience:** Adult children of elderly users (family guardians)
**Core function:** An agentic AI chatbot that analyzes suspicious messages, images, voice notes, and contracts to detect scams in real-time and guide elderly users to safety

**Mental model for the design:** This app is a calm, trustworthy shield — like having a knowledgeable family member always at hand. It never panics, but it never ignores danger either. Every screen should feel like a gentle, protective hand on the shoulder.

---

## 🎨 Design System

### Color Palette

```
Primary (Trust & Safety):
  --shield-teal:       #006D72   ← main brand, buttons, headers
  --shield-teal-light: #1A9DAA   ← active states, links
  --shield-teal-bg:    #E8F5F6   ← card backgrounds, safe zones

Alert (Danger Signals):
  --alert-red:         #C0392B   ← critical risk level
  --alert-orange:      #E67E22   ← high risk level
  --alert-amber:       #F1C40F   ← medium risk level
  --alert-green:       #27AE60   ← safe / no risk detected

Neutrals:
  --surface-white:     #FFFFFF
  --surface-light:     #F4F9FA   ← page backgrounds
  --text-primary:      #1A2D3A   ← main text (dark navy, NOT pure black)
  --text-secondary:    #5C7A88   ← subtitles, captions
  --divider:           #D9E8EC
```

**Palette rationale:** Teal communicates safety and calm authority (used by healthcare, banking). The warm alert spectrum (red → amber → green) maps intuitively to traffic light logic that elderly users already know. Avoid pure black text — use dark navy for softer readability.

### Typography

All sizes are Flutter `sp` (scale-independent pixels) — elderly-safe minimums.

```
Display:   "Nunito" Bold      34sp  — hero numbers, risk level badges
Heading 1: "Nunito" SemiBold  28sp  — screen titles
Heading 2: "Nunito" SemiBold  22sp  — section titles, card headers
Body:      "Nunito" Regular   18sp  — primary readable content (MINIMUM for elderly)
Label:     "Nunito" Medium    16sp  — button labels, form hints
Caption:   "Nunito" Regular   14sp  — metadata only (timestamps, disclaimers)
Chat AI:   "Nunito" Regular   18sp  — AI chatbot bubbles (same size, high contrast)
Chat User: "Nunito" Regular   18sp  — user chat bubbles
```

**Why Nunito:** Rounded letterforms (especially the 'a', 'g') reduce confusion for users with mild visual impairment. Highly legible at large sizes. Available on Google Fonts in Flutter.

### Spacing & Shape

```
Border radius:
  Cards:          20dp  (soft, approachable)
  Buttons:        16dp  (pill-adjacent but not full pill)
  Chat bubbles:   18dp with 4dp on sender corner
  Input fields:   14dp

Spacing scale (multiples of 8):
  xs: 8dp   sm: 16dp   md: 24dp   lg: 32dp   xl: 48dp

Touch targets:
  ALL interactive elements minimum 56dp height (exceeds WCAG 44px)
  Primary CTA buttons: full width (minus 24dp horizontal padding)
  Icon buttons: 56×56dp minimum
```

### Icon Style

Use **Rounded Material Icons** (Icons.shield_rounded, etc.) or **Phosphor Icons** package. Stroke weight: 2px. Never use outline-only icons for primary actions — fill them to aid recognition for elderly users.

---

## ♿ Elderly Accessibility Rules (Non-Negotiable)

Apply these on every screen without exception:

1. **Font size:** Never render user-facing text below 16sp. Body text 18sp minimum.
2. **Contrast ratio:** All text on backgrounds must meet WCAG AA (4.5:1). Alert text: AAA (7:1).
3. **Touch targets:** 56dp minimum height for all tappable elements.
4. **No gesture-only actions:** Never require swipe-to-dismiss or pinch-to-zoom as the only path. Always provide a visible button alternative.
5. **Error copy:** Plain Vietnamese. No jargon. "Ảnh bị mờ, vui lòng chụp lại" not "Image processing failed."
6. **Loading states:** Always show a named spinner ("Đang phân tích..."), never a bare spinner.
7. **Confirmation dialogs:** Destructive or financial actions require a large-font confirmation modal with clearly differentiated Confirm/Cancel buttons.
8. **No small X buttons:** Close/dismiss must be a full-width button or a clearly labeled tappable area.

---

## 📱 Screens to Generate

Generate each screen at **390×844dp** (iPhone 14 / standard Flutter canvas). Show both light mode. Include status bar and home indicator area.

---

### Screen 1 — Splash & Onboarding

**Splash Screen**
- Full-screen background: `--shield-teal` gradient (top: `#006D72` → bottom: `#1A9DAA`)
- Center: ScamShield shield logo (white, 120dp, filled shield with a checkmark inside)
- Below logo: App name "Lá Chắn Lừa Đảo" in white Nunito Bold 28sp
- Bottom tagline: "Bảo vệ bạn khỏi lừa đảo" white Nunito Regular 18sp
- No progress bar — pure brand moment

**Onboarding Slide 1 — "Gửi tin nhắn nghi ngờ"**
- Top 50%: Soft illustration (teal tones) — a smartphone with a suspicious Zalo message, a shield icon floating protectively over it
- Bottom 50%: White card with rounded top corners (radius 32dp)
  - Heading: "Nhận được tin nhắn lạ?" — 28sp Bold, `--text-primary`
  - Body: "Chỉ cần chụp ảnh hoặc gửi nội dung — ScamShield sẽ kiểm tra ngay cho bạn." — 18sp Regular
  - Progress dots: 3 dots, active = teal filled circle, inactive = light gray
  - "Tiếp theo" button: full-width teal rounded button, 56dp height, white text 18sp

**Onboarding Slide 2 — "AI phân tích tức thì"**
- Illustration: Abstract AI radar/scan lines over a document
- Heading: "Phát hiện dấu hiệu lừa đảo"
- Body: "AI sẽ tìm ra dấu hiệu nguy hiểm trong hợp đồng, voucher, và lời mời."
- Same button/dot structure

**Onboarding Slide 3 — "Báo cho gia đình"**
- Illustration: Two phones with a heart/shield connecting them
- Heading: "Chia sẻ với người thân ngay"
- Body: "Kết nối với con cái hoặc người thân để cùng bảo vệ nhau."
- Button: "Bắt đầu" (final CTA)

---

### Screen 2 — Home / Dashboard

**Layout philosophy:** A calm, uncluttered dashboard. One primary action dominates. Recent activity in cards below. No sidebar navigation — use a bottom navigation bar with 3 tabs maximum.

**Top section (teal header, no shadow):**
- Left: "Xin chào, Bà Lan 👋" — 22sp SemiBold, white
- Subtext: "Hôm nay bạn có gì cần kiểm tra không?" — 16sp Regular, white 80% opacity
- Right: Bell icon (notifications) 56×56dp touch area, white

**Quick Action Card (large, center stage):**
- Full-width card, `--shield-teal` background, 20dp radius, 24dp padding
- Large shield icon with scan animation hint (subtle pulse ring)
- Primary text: "Kiểm tra ngay" — 28sp Bold, white
- Sub-text: "Gửi ảnh, tin nhắn hoặc ghi âm" — 16sp Regular, white 85% opacity
- Microphone icon + Camera icon + Text icon as three small chips inside the card

**Risk Summary Row (3 mini-stat cards):**
- Card 1: "5 lần kiểm tra" (history count)
- Card 2: "2 rủi ro phát hiện" (amber accent)
- Card 3: "Gia đình: An toàn" (green accent)
- Each card: white background, 12dp radius, icon + number (28sp Bold) + label (14sp)

**Recent Cases Section:**
- Section title: "Lịch sử gần đây" — 20sp SemiBold
- 2-3 case preview cards:
  - Each card: white bg, 16dp radius, left accent border (color = risk level)
  - Left icon: warning/check shield
  - Title: "Hợp đồng kỳ nghỉ" — 18sp SemiBold
  - Subtitle: "Rủi ro cao · 2 giờ trước" — 14sp, `--text-secondary`
  - Chevron right

**Bottom Navigation Bar (3 tabs):**
- Tab 1: Home (house icon) — "Trang chủ"
- Tab 2: Chat (chat bubble icon) — "Trợ lý AI" ← default active
- Tab 3: Family (people icon) — "Gia đình"
- Active tab: teal icon + teal label + subtle teal underline indicator
- Inactive: gray icon + gray label
- Height: 72dp (oversized for elderly tap accuracy)

---

### Screen 3 — Chat Interface (Main Scam Analysis Screen)

This is the heart of the app. Design it as a warm, guided conversational interface — NOT a cold terminal.

**AppBar:**
- Background: white, 1dp bottom divider `--divider`
- Left: Back arrow (56dp touch) 
- Center: Shield avatar (teal circle, 40dp, white shield icon) + "ScamShield AI" 18sp SemiBold + "Đang hoạt động 🟢" 13sp green subtitle
- Right: More options icon (56dp touch)

**Chat area (scroll, bottom-anchored):**
- Background: `--surface-light` (#F4F9FA)

**AI Message Bubble (left-aligned):**
- Background: White card
- Border radius: 4dp top-left, 18dp elsewhere (tail on top-left)
- Max width: 80% of screen
- Padding: 14dp horizontal, 12dp vertical
- Text: 18sp Regular, `--text-primary`
- Timestamp: 12sp, `--text-secondary`, below bubble
- AI avatar: small 28dp teal circle left of bubble

*Opening AI message example:*
"Xin chào Bà Lan! 🛡️ Bạn nhận được tin nhắn, hình ảnh hay cuộc gọi nào đáng ngờ không? Hãy gửi cho tôi kiểm tra nhé."

**User Message Bubble (right-aligned):**
- Background: `--shield-teal` (#006D72)
- Border radius: 18dp, 4dp top-right
- Text: 18sp Regular, white
- Timestamp: 12sp, `--text-secondary`, below right

**Image/Media Bubble:**
- 200×200dp rounded image preview (20dp radius) inside a user bubble
- Below image: "📎 Ảnh hợp đồng.jpg" label + small "Đang phân tích..." shimmer loading state

**AI Analysis In-Progress State:**
- Three animated typing dots in an AI bubble
- Text below dots: "Đang kiểm tra dấu hiệu lừa đảo..." 16sp italic teal

**Input Bar (bottom, above keyboard):**
- Height: 72dp
- Background: white, top shadow
- Left group: Camera icon button (56dp) + Gallery icon button (56dp) + Microphone icon button (56dp) — all teal icons
- Center: Text input field, 16sp placeholder "Nhập hoặc dán nội dung...", 14dp radius, `--surface-light` bg
- Right: Send button, teal filled circle 48dp, white send arrow icon

---

### Screen 4 — Scam Analysis Result Card (inside Chat)

Render this as a special AI message card — wider than a normal bubble, full content width minus 16dp margin.

**Risk Level Banner (top of card):**
- For CRITICAL: Full-width red banner (#C0392B), white text, shield-with-X icon
  - "⚠️ RỦI RO RẤT CAO" — 22sp Bold, centered
- For HIGH: Orange banner (#E67E22)
  - "⚠️ RỦI RO CAO"  
- For SAFE: Green banner (#27AE60)
  - "✅ AN TOÀN"

**Card body (white, 20dp radius, subtle shadow):**

*Case Summary section:*
- Label chip: "Hợp đồng kỳ nghỉ" — teal chip, 14sp
- "Giai đoạn: Trước khi đặt cọc" — 16sp gray

*Red Flags list:*
- Section header: "Dấu hiệu nguy hiểm phát hiện được" — 18sp SemiBold, `--text-primary`
- Each flag as a row:
  - Left: Red filled circle with number (1, 2, 3...) — 28dp circle, white number 16sp Bold
  - Right: Flag title 16sp SemiBold + description 15sp Regular in two lines
  - Red tint row background (#FFF5F5)
  - Divider between rows

*Manipulation Tactics (if voice analysis):*
- Collapsible section "Kỹ thuật thao túng tâm lý" 
- Pills inside: "Áp lực thời gian", "Khan hiếm giả tạo", "Bằng chứng xã hội" — amber pill chips

**Action Buttons (bottom of card):**
- Primary (large, full-width): "🛑 Không ký / Không chuyển tiền" — teal button, 56dp, 18sp Bold
- Secondary (outlined): "⏱️ Bật chế độ suy nghĩ 48h" — teal outline button, 56dp
- Tertiary (text): "📤 Gửi cho người thân" — teal text link, 18sp

---

### Screen 5 — Cooling-Off Timer Screen

Activated when user triggers the 48-hour decision delay feature.

**Full-screen background:** Soft gradient `--shield-teal-bg` to white

**Top section:**
- Large shield icon with hourglass: 100dp, teal
- Heading: "Đang trong giai đoạn suy nghĩ" — 26sp SemiBold, centered
- Subheading: "Đừng ký hoặc chuyển tiền trong thời gian này" — 18sp Regular, `--text-secondary`, centered, 2-line

**Countdown Timer (dominant visual):**
- Large circular progress ring (200dp diameter), teal stroke, light gray track
- Center: Remaining time in large display — "47:23:15" — 34sp Bold Nunito, teal
- Below: "giờ : phút : giây" — 14sp gray caption

**Reason card:**
- White card, 20dp radius, 24dp padding
- "Tại sao cần chờ?" — 18sp SemiBold
- Body text explaining cooling-off rationale — 16sp Regular
- 3 bullet rows with teal checkmark icons

**Bottom CTA:**
- "📞 Gọi cho gia đình ngay" — large teal button, 56dp
- "Chia sẻ cảnh báo này" — outlined button, 56dp
- Small print: "Bộ đếm sẽ nhắc bạn khi hết giờ" — 14sp gray, centered

---

### Screen 6 — Contract Risk Analysis Screen

Shown after user uploads a contract image.

**AppBar:** "Phân tích Hợp đồng" — 22sp, back button

**Risk summary strip:**
- Top horizontal strip: risk color + "Hợp đồng: RỦI RO CAO" + summary badge

**Checklist section — "Danh sách kiểm tra hợp đồng":**
Present as a vertical list of check items, each row:
- 56dp height
- Left icon: ✅ green check / ❌ red X / ❓ orange question
- Item label 16sp: e.g., "Có điều khoản hoàn tiền không?"
- Result label 15sp right-aligned: "Không thấy" (red) / "Có" (green) / "Không rõ" (orange)
- Alternating row background (white / `--surface-light`)

**High-Risk Clauses (expandable):**
- Section header + count badge ("3 điều khoản nguy hiểm")
- Each clause as an expandable card with red left border
- Collapsed: shows clause title 16sp + red "Nguy hiểm" chip
- Expanded: reveals explanation text 15sp Regular

**Questions to ask before signing:**
- Section: "Câu hỏi cần hỏi bên bán"
- Numbered list (teal numbered circles)
- Each question 16sp Regular
- "Sao chép tất cả câu hỏi" button below — helps elderly copy/paste to send to a family member

**Bottom fixed button:**
- "🚫 Không ký bản này — Gửi cho chuyên gia" — full-width red-tinted button

---

### Screen 7 — Family Guardian Screen

Allows connecting family members as guardians.

**Header section:**
- Teal header, white text
- "Gia đình của tôi" title
- Subtitle: "Người thân sẽ nhận cảnh báo khi bạn cần"

**Connected guardians list:**
- Each guardian card: white, 20dp radius
  - Avatar circle (initials, teal bg) — 52dp
  - Name 18sp SemiBold
  - Relationship label "Con gái" — 14sp chip, teal light bg
  - Status "🟢 Đang kết nối" — 14sp green
  - "Gửi cảnh báo ngay" button (outlined, 44dp)

**"Thêm người thân" CTA:**
- Dashed border card, center icon (+) teal, 18sp "Thêm thành viên gia đình"

**Emergency Alert toggle:**
- Large toggle card: "Tự động thông báo khi phát hiện rủi ro cao"
- Toggle switch (oversized, 60×34dp) — teal when active
- Description 14sp below toggle

---

### Screen 8 — Settings / Profile Screen

Clean, list-based. No fancy layouts — clarity over cleverness for elderly.

**Profile header (teal card):**
- Avatar circle 72dp, white initials
- Name 22sp Bold white
- "Thành viên từ 2024" 15sp white 80%
- Edit profile button (white outlined, small)

**Settings sections (grouped list, white cards):**

*Cài đặt an toàn:*
- Kích hoạt bảo vệ nền (Background scan)
- Chặn số lạ tự động
- Ngưỡng cảnh báo gia đình (dropdown)

*Cài đặt hiển thị:*
- Cỡ chữ (3-option segmented: Vừa / Lớn / Rất lớn)
- Độ tương phản cao (toggle)

*Gia đình:*
- Quản lý danh sách người giám hộ
- Lịch sử chia sẻ cảnh báo

*Trợ giúp:*
- Hướng dẫn sử dụng
- Liên hệ hỗ trợ (large teal button: "📞 Gọi 1800-SHIELD")

---

## 🔧 Flutter Implementation Notes

Include these in your design annotations:

```
Framework:       Flutter 3.x with Material 3 (useMaterial3: true)
State mgmt:      Riverpod or Bloc — note which component needs state
Package hints:
  - google_fonts: ^6.x (Nunito)
  - lottie: ^3.x (for shield pulse animation, typing dots)
  - chat_bubbles: ^1.x (or custom ClipRRect bubbles)
  - flutter_local_notifications (cooling-off timer reminders)

Widget patterns:
  - All list items: ListTile with dense: false, minVerticalPadding: 16
  - All buttons: ElevatedButton with minimumSize: Size.fromHeight(56)
  - Chat scroll: ListView.builder with reverse: true, controller with auto-scroll
  - Risk badge: Container with BoxDecoration, custom border-radius asymmetry
  - Bottom nav: NavigationBar (Material 3) not BottomNavigationBar

SafeArea: Always wrap screens in SafeArea — elderly use older phones with non-standard notches
Keyboard handling: resizeToAvoidBottomInset: true on chat screen
```

---

## 🖌️ Reference Visual

The aesthetic reference is the **Plantland app** (shown) — soft teal brand color, clean white card surfaces, rounded shapes, friendly typography, no harsh shadows. Adapt that warmth and accessibility for a safety/protection context by adding the amber/red alert system and aging-friendly typography scale.

**Key departure from reference:** Plantland uses decorative illustrations prominently. ScamShield should use functional iconography over decorative illustration — every visual element should reinforce a meaning (shield = protection, X = danger, clock = wait), not decorate. The one aesthetic risk: use the countdown circle progress ring as the signature motion element — a rotating teal arc that communicates "time is protection."

---

## 📋 Generation Checklist

For each screen, verify before finalizing:
- [ ] No text below 16sp
- [ ] All CTA buttons ≥ 56dp height  
- [ ] Risk level color is immediately obvious without reading text
- [ ] Vietnamese copy is plain, no English jargon visible to end user
- [ ] Loading/analyzing state is designed (not just success state)
- [ ] Empty state is designed (e.g., no recent cases yet)
- [ ] The screen makes sense if the user has mild visual impairment
