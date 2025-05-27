## 🧑‍💻 Các Tier Người Dùng trong Hệ Thống n8n Runtime

| Tier         | Mô tả                                                  | Giới hạn                            | Quyền lợi chính                                                                 |
|--------------|----------------------------------------------------------|--------------------------------------|----------------------------------------------------------------------------------|
| **Free**     | Người dùng sử dụng workflow miễn phí hoặc gói dùng thử | `limit_value_free`                  | - Sử dụng được các workflow công khai <br> - Bị giới hạn truy cập/quota        |
| **Pro** | Khách mua gói workflow trả phí theo tháng ở cấp độ Pro            | `limit_value_pro`            | - Được tăng giới hạn sử dụng workflow <br> - Giới hạn truy cập/quota cao hơn Free.<br> - Ưu tiên queue trong hệ thống queue tổng sau khách Premium.          |
| **Premium**  | Khách mua gói workflow trả phí theo tháng ở cấp độ Premium    | `limit_value_premium`              | - Giới hạn truy cập/quota cao hơn Pro. <br> - Ưu tiên đầu tiên queue trong hệ thống queue tổng<br> - Không có queue riêng               |
| **Khách VIP** | Khách đặt làm riêng workflow theo yêu cầu             |                | - Không bị giới hạn như các tier trên <br> - Có **queue riêng**, ưu tiên xử lý  |

---

## 🔐 Giải Thích Chi Tiết `limit_unit`

| `limit_unit`       | Định nghĩa                                                                 |
|--------------------|------------------------------------------------------------------------------|
| `perRequest`       | Giới hạn số **item xử lý mỗi lần gọi workflow**                            |
| `perDay`           | Giới hạn **số lần gọi tối đa trong một ngày**                              |
| `cooldownSeconds`  | Yêu cầu khoảng **thời gian chờ giữa 2 lần gọi**, tính bằng giây            |
| `maxAccount`       | Số **tài khoản được phép kết nối đồng thời**                              |
| `maxToken`         | Số **API token/key đồng thời được dùng**                                   |
| `custom`           | Giới hạn đặc biệt (tùy biến theo từng `description` trong workflow config) |

---

## 🔄 Hệ thống Runtime liên kết

| Thành phần        | Vai trò                                                                                   |
|------------------|--------------------------------------------------------------------------------------------|
| `userId`         | Định danh người dùng                                                                      |
| `workflow_slug`   | Định danh workflow + mapping đến quota                                                    |
| `ordersId`    | Ghi nhận quyền sử dụng theo từng order (user + workflow + status)                        |
| `workflow_config` | Cấu hình quota cho workflow gồm `limit_unit`, `limit_value_free`, `limit_value_pro`, `limit_value_premium`,... |
| `usage_logs`      | Ghi log từng lần gọi để kiểm tra quota, block nếu vi phạm                                |

---

## 🧪 Ví dụ cụ thể:
```json
{
  "workflow_slug": "free_autoInbox_fb",
  "limit_unit": "perDay",
  "limit_value_free": 10,
  "limit_value_pro": 100,
  "limit_value_premium": 500
}
```
→ User Free: gọi tối đa 10 lần/ngày<br>
→ User Pro: gọi tối đa 100 lần/ngày<br>
→ User Premium: gọi tối đa 500 lần/ngày<br>
→ Hệ thống kiểm tra bằng log trong usage_logs hoặc hình thức kiểm tra khác.