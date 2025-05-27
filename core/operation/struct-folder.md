### 🧪 R&D Lab – Phát triển & thử nghiệm

#### Mục tiêu:
- Viết prototype, test logic, validate công nghệ
- Tối ưu, chuẩn hóa trước khi chuyển production

#### Prefix & workflow_slug:
- Prefix: `[Idea]`, `[Research]`, `[Prototype]`, `[Test]`, `[Dev]`, `[Debug]`, `[Done]`
- Slug: `[prefix]_[functionGroup]_[platform][_dev/_test/_debug/_exp]`

---

### 🧩 Reusable Modules – Logic dùng lại qua HTTP

#### Mục tiêu:
- Logic độc lập, rõ ràng input/output, dùng lại được ở nhiều flow khác
- Gọi qua HTTP (Webhook Trigger)

#### Prefix & workflow_slug:
- Prefix: `[Module]`, `[Action]`, `[Utility]`, `[Fetch]`, `[Auth]`
- Slug: `[prefix]_[functionGroup]_[platform]`

---

### 📦 Templates – Workflow thương mại

#### Mục tiêu:
- Đóng gói bán, tặng miễn phí, hoặc dùng làm base cho client

#### Prefix & workflow_slug:
- Prefix: `[Free]`, `[Premium]`, `[Bundle]`, `[Beta]`, `[Demo]`
- Slug: `[prefix]_[functionGroup]_[platform]`

---

### 💼 Client Projects – Workflow cho khách hàng

#### Mục tiêu:
- Viết và triển khai các workflow riêng theo yêu cầu từng khách hàng
- Kết nối API, CRM, Zalo, form,... theo hệ thống của client
- Dễ bàn giao, bảo trì và kiểm soát quyền truy cập

#### Cấu trúc thư mục:
- `AIAUTOXX – TÊN KHÁCH HÀNG` → chứa toàn bộ workflow liên quan đến từng client

#### Quy tắc đặt tên workflow_slug:
- Format: `aiautoXX_functionGroup_platform`
- Ví dụ: `aiauto07_autoInboxComment_fb`, `aiauto10_syncCustomerData_sheet`

#### Phân biệt trạng thái bằng tag:
- `#active`: Workflow đang hoạt động chính thức
- `#archive`: Workflow đã ngưng sử dụng, lưu để tham khảo
- `#maintenance`: Đang bảo trì, tạm dừng

#### Prefix hiển thị trong tên workflow:
- `[Live]` – Đang chạy chính thức
- `[Archive]` – Phiên bản cũ, không còn sử dụng

#### Quy tắc phân loại version:
- `v1.0`: Phiên bản chính thức đầu tiên
- `v1.1, v1.2, ...`: Cập nhật nhỏ, sửa lỗi
- `v2.0`: Thay đổi lớn về tính năng hoặc cấu trúc

#### Hệ thống ghi chú thay đổi:
- Mỗi workflow nên có một node "Changelog" ở đầu workflow
- Format ghi chú: `[Ngày] - [Version] - [Người thay đổi] - [Mô tả thay đổi]`
- Mỗi thay đổi lớn cần cập nhật version và ghi chú thay đổi

#### Quy trình triển khai:
1. Tạo thư mục `AIAUTOXX – TÊN KHÁCH HÀNG`
2. Xác định mục tiêu sử dụng cụ thể
3. Thu thập tài liệu, input, form, webhook,...
4. Kiểm tra module/template có thể reuse từ 🧩/📦
5. Vẽ sơ đồ logic và xác định rõ input/output
6. Đặt workflow_slug đúng chuẩn
7. Cập nhật mapping vào Larkbase & Google Sheet
8. Gắn tag trạng thái & prefix tên workflow
9. Viết logic → test kỹ → clean → bàn giao
10. Cập nhật changelog sau mỗi lần sửa đổi

---

### 🎯 Internal Ops – Workflow tự động nội bộ

#### Mục tiêu:
- Tự động hóa quy trình nội bộ: tuyển dụng, CRM, marketing...

#### Slug chuẩn:
- `internal_functionGroup_platform`
- Ví dụ: `internal_syncForm_sheet`, `internal_reportLeads_crm`

#### Quy trình:
1. Viết thử tại 🧪 nếu là ý tưởng mới
2. Dùng module từ 🧩 nếu có
3. Gắn tag: `internal`, `crm`, `campaign`,...
4. Không hardcode token, ID
5. Test kỹ và vận hành thực tế
