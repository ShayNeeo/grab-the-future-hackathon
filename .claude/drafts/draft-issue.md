---
title: "[Feature] Family Alert Agent — AI tạo hướng dẫn can thiệp không đối đầu cho người thân"
kind: issue
template: fallback
labels: [enhancement]
---

## Summary

Thêm **Family Alert Agent** (tính năng #6) cho phép người thân nhận một bản cảnh báo rõ ràng, dễ hiểu do AI tạo ra khi phát hiện người cao tuổi đang đối mặt với nguy cơ lừa đảo. Cảnh báo bao gồm tóm tắt tình huống, các dấu hiệu rủi ro chính, kịch bản can thiệp cụ thể (nên nói gì / không nên nói gì), và các việc cần làm ngay — giúp người thân hành động hiệu quả mà không tạo ra sự đối đầu hay phản kháng từ nạn nhân.

## Business Goal / Why

Nhiều nạn nhân cao tuổi đã bị kẻ lừa đảo xây dựng niềm tin trước đó, nên khi người thân nói "mẹ/ba bị lừa rồi" thường gây phản ứng phòng thủ và mâu thuẫn. ScamShield cần một luồng riêng giúp người thân **can thiệp đúng cách, đúng lúc** — không đối đầu, không làm nạn nhân cảm thấy bị phán xét, nhưng vẫn dừng được hành động nguy hiểm. Tính năng này bổ sung trực tiếp cho màn hình Gia đình (`/family`) hiện đang là UI tĩnh chưa có chức năng thực sự.

## Actor

Elderly Vietnamese users (bà/ông dùng app) — gửi ảnh/mô tả tình huống; đồng thời người thân (con cái, cháu) — nhận và đọc cảnh báo.

## Affected Files

| File | Vai trò / Thay đổi |
|---|---|
| [`lib/src/models/family_alert_response.dart`](lib/src/models/family_alert_response.dart) | **Mới** — Model `FamilyAlertResponse` với 6 trường: `situationSummary`, `riskLevel`, `mainRisks`, `doNotSay`, `doSay`, `immediateActions` |
| [`lib/src/providers/family_alert_provider.dart`](lib/src/providers/family_alert_provider.dart) | **Mới** — Riverpod `StateNotifierProvider` quản lý trạng thái loading/error/data của alert |
| [`lib/ui/screens/family_alert_screen.dart`](lib/ui/screens/family_alert_screen.dart) | **Mới** — Màn hình hiển thị cảnh báo gia đình: header màu theo risk level, danh sách dấu hiệu, card "Không nói / Nên nói", checklist hành động, nút chia sẻ |
| [`lib/src/services/scamshield_api.dart`](lib/src/services/scamshield_api.dart) | Thêm `generateFamilyAlert(AnalysisResponse)` gọi `POST /family-alert` |
| [`lib/app/app.dart`](lib/app/app.dart) | Đăng ký route `/family-alert` trong `onGenerateRoute` với argument `AnalysisResponse` |
| [`lib/app/routes.dart`](lib/app/routes.dart) | Thêm hằng số `AppRoutes.familyAlert = '/family-alert'` |
| [`lib/ui/screens/scam_result_card_screen.dart`](lib/ui/screens/scam_result_card_screen.dart) | Kết nối nút "📤 Gửi cho người thân" → navigate tới `FamilyAlertScreen` |
| [`scamshield_api/app/models/schemas.py`](scamshield_api/app/models/schemas.py) | Thêm Pydantic models `FamilyAlertRequest` và `FamilyAlertResponse` |
| [`scamshield_api/app/agents/prompts.py`](scamshield_api/app/agents/prompts.py) | Thêm `FAMILY_ALERT_PROMPT` — prompt hướng dẫn AI tạo kịch bản can thiệp không đối đầu |
| [`scamshield_api/app/routers/analyze.py`](scamshield_api/app/routers/analyze.py) | Thêm `POST /family-alert` endpoint — nhận analysis data, gọi Gemma, trả về `FamilyAlertResponse` |

## Proposed Behavior

1. Người dùng phân tích xong một tình huống → màn hình `ScamResultCardScreen` hiển thị kết quả.
2. Người dùng nhấn **"📤 Gửi cho người thân"** → navigate tới `FamilyAlertScreen`, truyền `AnalysisResponse` làm argument.
3. `FamilyAlertScreen` khởi động → gọi `familyAlertProvider.generate(analysis)` → spinner loading hiện ra.
4. Backend `POST /family-alert` nhận analysis data, gọi Gemma với `FAMILY_ALERT_PROMPT`, trả về JSON `FamilyAlertResponse`.
5. Màn hình hiển thị:
   - **Header màu theo risk** (đỏ/cam/vàng/xanh) với tóm tắt tình huống và nhãn mức độ.
   - **Dấu hiệu chính** — danh sách bullet tối đa 4 điểm.
   - **Cách can thiệp** — card đỏ "Không nên nói: …" + card xanh "Nên nói: …" + ghi chú giải thích tại sao.
   - **Việc cần làm ngay** — checklist hành động cụ thể.
   - **Nút "📤 Chia sẻ cảnh báo này"** — xuất text qua `share_plus` (SMS, Zalo, v.v.).
6. Nếu API lỗi → hiển thị màn hình lỗi với nút "Thử lại".

## Acceptance Criteria

- [ ] Nút "📤 Gửi cho người thân" trên `ScamResultCardScreen` điều hướng đúng tới `FamilyAlertScreen`.
- [ ] Màn hình hiển thị spinner trong khi chờ API.
- [ ] Màu header thay đổi theo `riskLevel` (critical → đỏ, high → cam, medium → vàng, low → xanh).
- [ ] Section "Cách can thiệp" có đủ hai card: "Không nên nói" (đỏ) và "Nên nói" (xanh).
- [ ] Nút chia sẻ xuất đúng nội dung cảnh báo dạng văn bản tiếng Việt.
- [ ] Màn hình lỗi với nút "Thử lại" hiện ra khi API không phản hồi.
- [ ] `flutter analyze` không có lỗi.
- [ ] Backend `POST /family-alert` trả về JSON đúng schema `FamilyAlertResponse`.

## Out of Scope

- Gửi push notification thực sự tới điện thoại người thân (cần backend notification service).
- Lưu lịch sử cảnh báo đã gửi.
- Xác thực / đăng nhập tài khoản người thân.
- Liên kết danh sách người thân thực tế với hệ thống backend.

## Dependencies / Blockers

- Backend API (`scamshield_api`) phải đang chạy và có `GEMMA_API_KEY` hợp lệ để endpoint `/family-alert` hoạt động.
- `share_plus ^9.0.0` đã có trong `pubspec.yaml` — không cần thêm dependency.
