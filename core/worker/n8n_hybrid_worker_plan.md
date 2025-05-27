
## Kế hoạch Triển khai Thực tế Hệ thống n8n Hybrid Worker: VPS First, Local Assist khi Backlog Cao

### 1. Mục tiêu
- Xây dựng mô hình hybrid worker n8n.
- Đảm bảo VPS gánh chính toàn bộ workload.
- Local worker chỉ kích hoạt khi queue backlog cao (>50 job).
- Credential, callback luôn sử dụng domain VPS để tránh lỗi OAuth, webhook callback.

### 2. Thành phần hệ thống
| Thành phần         | Vai trò                                    | Ghi chú |
|--------------------|--------------------------------------------|---------|
| n8n VPS (UI + API) | Trung tâm queue, UI, webhook, API gateway | Domain cố định cho credential, callback |
| Redis (VPS)        | Quản lý queue, thống nhất cho toàn bộ hệ thống | VPS quản lý |
| Worker VPS         | Worker chủ lực, xử lý toàn bộ job mặc định | Luôn bật, 3 worker x 5 concurrency |
| Worker Local       | Worker phụ, chỉ kích hoạt khi backlog lớn | Bật/tắt tự động qua monitor, 9 worker x 10 concurrency |
| RedisInsight       | Giám sát queue, worker status              | Dùng để monitor toàn bộ queue |


### 3. Các bước triển khai thực tế

#### Bước 1: Thiết lập VPS (Nhóm Worker Chính)
- Cài đặt n8n VPS.
- Bật EXECUTIONS_MODE=queue.
- Triển khai Redis tại VPS.
- Thiết lập 3 worker chính của n8n.
- Mỗi worker xử lý 5 tiến trình con (concurrency = 5), tổng 15 process con.

#### Bước 2: Thiết lập Máy Local (Hỗ trợ Tự động Mở rộng) - ✅ HOÀN THÀNH
- Cài đặt n8n Local. ✅
- Kết nối Redis queue ở VPS. ✅
- Kết nối PostgreSQL ở VPS (đã sửa lỗi, không dùng SQLite). ✅
- Thiết lập 9 worker Local. ✅
- Mỗi worker Local xử lý 10 process con (concurrency = 10), tổng 90 process con. ✅
- Phiên bản n8n (`1.92.2`) đã được đồng bộ với VPS. ✅
- Ban đầu các worker Local ở trạng thái dừng (sẽ được quản lý bởi script monitor ở Bước 3).
- Đồng bộ workflow + credential từ VPS về Local (dùng API n8n VPS) - *Cần thực hiện nếu có thay đổi workflow/credential trên VPS và local cần bản sao đầy đủ để chạy độc lập khi cần, hiện tại local worker đang dùng chung DB nên không cần đồng bộ trực tiếp workflow files/credentials qua API nếu chỉ làm executor.*.
- **Ghi chú quan trọng:** Toàn bộ credential callback URI vẫn giữ nguyên domain VPS, **Local worker chỉ là executor backend, không host webhook trực tiếp, không thay đổi URI về local domain. Điều này tránh lỗi OAuth, callback khi worker local xử lý.** ✅ Đã đảm bảo.

#### Bước 3: Cơ chế Tự động Mở rộng (Auto-Scaling) - ✅ HOÀN THÀNH
- ✅ Phát triển script monitor queue backlog (`scripts/local_worker_autoscaler.py`).
- ✅ Script kết nối Redis (VPS), kiểm tra queue `bull:jobs:wait`.
- ✅ Nếu queue pending > `HIGH_WATERMARK` (ví dụ 50) → scale up `n8n-local-worker` lên `LOCAL_WORKER_ACTIVE_REPLICAS` (ví dụ 9).
- ✅ Nếu queue pending < `LOW_WATERMARK` (ví dụ 25) → scale down `n8n-local-worker` về 0.
- ✅ Thêm cooldown period để tránh bật/tắt liên tục.
- ✅ Docker hóa script autoscaler (`scripts/Dockerfile`) và tích hợp vào `docker-compose.local-workers.yml`.
- ✅ Tách `local-worker-autoscaler` và `n8n-local-worker` vào Docker Compose project `n8n-worker-group` riêng biệt.
- ✅ Đặt tên container cố định `local-worker-autoscaler`.
- ✅ Script autoscaler đang chạy và sẵn sàng kiểm thử.

#### Bước 4: Giám sát & Kiểm thử - ⏳ CHUẨN BỊ KIỂM THỬ AUTOSCALER
- Dùng RedisInsight để giám sát queue, worker status, job progress. ✅
- Kiểm thử các kịch bản:
  - ✅ Worker VPS xử lý job chính xác khi Local chưa bật (hoặc đang tắt).
  - ✅ Worker Local tham gia xử lý job chính xác khi được bật thủ công.
  - ✅ Hệ thống hybrid (VPS + Local bật thủ công) đã xử lý thành công 100 workflow thử nghiệm.
  - ⏳ **Tải cao, queue backlog > `HIGH_WATERMARK` → Local worker được autoscaler bật và xử lý job.**
  - ⏳ **Khi queue giảm < `LOW_WATERMARK` → Local worker được autoscaler dừng.**
  - ⏳ Mất kết nối Local worker → job fail sẽ được VPS xử lý tiếp (Cần kiểm thử kỹ hơn sau khi có script monitor).

### 4. Kết luận chiến lược tối ưu
| Thành phần | Worker | Concurrency | Tổng process con | RAM tổng (ước lượng) | CPU tổng (ước lượng) |
|------------|--------|-------------|------------------|-----------------------|----------------------|
| **Local (auto-scaler khi backlog >100)** | 9 | 10 | 90 | Phụ thuộc cấu hình local | Phụ thuộc cấu hình local |
| **VPS (primary worker pool)** | 3 | 5 | 15 | ~2.25GB (ước lượng dựa trên 150MB/worker + 100MB/process) | ~3 Core (ước lượng dựa trên 20% core/process) |

Tổng tải hệ thống được phân tán rõ ràng:
- **VPS là chủ lực.**
- **Local chỉ hỗ trợ khi backlog cao.**
- **Credential, webhook callback luôn dùng domain VPS để đảm bảo an toàn và không gây lỗi callback.**
- **Local worker không được sửa hoặc rewrite URI callback thành domain Local, mọi callback vẫn trỏ về domain VPS (best practice production).**

### 5. Sơ đồ luồng (bổ sung sau nếu cần)
- Redis Queue ở VPS.
- Worker VPS kết nối và xử lý job mặc định.
- Custom monitor queue (`scripts/local_worker_autoscaler.py` trong container `local-worker-autoscaler`) theo dõi queue.
- Khi queue pending > `HIGH_WATERMARK` → trigger Worker Local bật để xử lý backlog.
- Khi queue < `LOW_WATERMARK` → tự động stop Worker Local.
