## n8n Hybrid Worker Strategy: VPS First, Local Assist when Backlog High

### 1. Tài nguyên hiện tại

#### VPS:
- **RAM khả dụng:** 4 GB
- **CPU khả dụng:** 4 Core

#### Local:
- **RAM khả dụng:** 64 GB (30 GB cho hệ thống khác -> còn 34 GB, sử dụng tối đa 20 GB cho n8n)
- **CPU khả dụng:** 20 Core
- **Lưu ý:** Hiện tại giữ lại **2 Core** cho các tác vụ khác. **Khuyến nghị tương lai nên giữ lại 3 Core khi tăng số lượng workload AI, Docker, Chrome, etc.**

#### Giám sát:
- **Sử dụng RedisInsight để theo dõi queue, worker status, job progress.**
- **Sử dụng script `local_worker_autoscaler.py` (chạy trong container Docker `local-worker-autoscaler` thuộc project `n8n-worker-group` trên máy local) để tự động theo dõi queue backlog và trigger Local worker bật/tắt.**
    - Script này kết nối tới Redis trên VPS để lấy thông tin queue.
    - Nó thực thi lệnh `docker compose -p n8n-worker-group ... scale` để điều khiển số lượng `n8n-local-worker`.

---

### 2. Bảng tính chi tiết tài nguyên

#### VPS:
| Thành phần        | Số lượng    | RAM/process    | Tổng RAM     | CPU/process   | Tổng CPU    |
|--------------------|-------------|----------------|--------------|---------------|-------------|
| Worker chính       | 3           | 150MB          | 450MB        | Không đáng kể | Không đáng kể |
| Process con        | 15 (3x5)    | 100MB          | 1.5GB        | 20% 1 Core    | 3 Core (75%) |
| **Tổng (ước lượng)** |             |                | **~2GB**     |               | **3 Core**  |

#### Local (Kích hoạt khi backlog cao):
| Thành phần        | Số lượng    | RAM/process    | Tổng RAM     | CPU/process   | Tổng CPU    |
|--------------------|-------------|----------------|--------------|---------------|-------------|
| Worker chính       | 9           | 150MB          | 1.35GB       | Không đáng kể | Không đáng kể |
| Process con        | 90 (9x10)   | 100MB          | 9GB          | 20% 1 Core    | 18 Core |
| **Tổng (ước lượng)** |             |                | **~10.4GB**  |               | **18 Core** |

---

### 3. Chiến lược phân phối tài nguyên

#### Khuyến nghị chuẩn:
- **VPS First:**
  - Worker VPS luôn bật và xử lý toàn bộ job mặc định.
  - Concurrency 5/job, đảm bảo tận dụng tối đa VPS trước (hiện tại 3 worker x 5 concurrency).
- **Local Assist (Khi backlog > HIGH_WATERMARK, ví dụ >50):**
  - Worker Local mặc định ở trạng thái dừng (0 replicas).
  - Script `local_worker_autoscaler.py` giám sát queue. Nếu queue pending > `HIGH_WATERMARK` job thì trigger bật Local worker lên `LOCAL_WORKER_ACTIVE_REPLICAS` (ví dụ 9 worker x 10 concurrency → 90 job song song).
  - Khi queue giảm xuống an toàn (< `LOW_WATERMARK`, ví dụ <25), script `local_worker_autoscaler.py` sẽ tự động stop Local worker (scale về 0 replicas) để trả lại tài nguyên cho các workload khác.

#### Không khuyến nghị:
- **Không chạy worker Local và VPS song song mặc định.**
  - Chỉ chạy Local khi queue backlog lớn.
  - VPS luôn là chủ lực, Local chỉ đóng vai trò Auto-Scaler khi cần.

#### Giám sát:
- Dùng **RedisInsight** để theo dõi queue length, worker status, job progress.
- Script `local_worker_autoscaler.py` tự động giám sát và điều khiển Local worker.

---

### 4. Kết luận chiến lược tối ưu:
| Thành phần | Worker | Concurrency | Tổng process con | RAM tổng (ước lượng) | CPU tổng (ước lượng) |
|------------|--------|-------------|------------------|-----------------------|----------------------|
| **Local (auto-scaler khi backlog >100)** | 9 | 10 | 90 | ~10.4GB | ~18 Core |
| **VPS (primary worker pool)** | 3 | 5 | 15 | ~2GB | ~3 Core |

Tổng tải hệ thống được phân tán rõ ràng, VPS sẽ gánh chính, Local chỉ tham gia khi queue backlog lớn.

---

### 5. Sơ đồ luồng (bổ sung sau nếu cần)
- Redis Queue ở VPS.
- Worker VPS kết nối và xử lý job mặc định.
- Custom monitor queue (VD: RedisInsight API ưu tiên, custom script) theo dõi queue.
- Khi queue pending > 50 → trigger Worker Local bật để xử lý backlog.
- Khi queue < 25 → tự động stop Worker Local.

### 6. Tình trạng Hiện tại và Bước Tiếp theo

*   **Tình trạng Hiện tại:**
    *   Worker VPS (3 worker x 5 concurrency) đã được thiết lập, cấu hình và hoạt động ổn định, xử lý jobs từ Redis queue chung.
    *   Worker Local (9 worker x 10 concurrency) đã được thiết lập, cấu hình và hoạt động ổn định khi được bật thủ công.
    *   Hệ thống hybrid đã được kiểm tra với 100 workflow và chạy bình thường.
    *   **Script `local_worker_autoscaler.py` đã được phát triển, Docker hóa, và đang chạy.** Nó có khả năng giám sát Redis queue và thực hiện lệnh scale các local worker. Nó được quản lý trong project Docker Compose `n8n-worker-group` riêng biệt.
*   **Bước Tiếp theo (Chiến lược Ưu tiên):**
    *   **Kiểm thử toàn diện hoạt động của `local_worker_autoscaler.py`:** Tạo tải, quan sát hành vi scale up/down, kiểm tra log.
    *   Tinh chỉnh các ngưỡng (`HIGH_WATERMARK`, `LOW_WATERMARK`, `COOLDOWN_PERIOD_SECONDS`) của autoscaler nếu cần thiết sau kiểm thử.
    *   (Sau khi autoscaler ổn định) Triển khai cơ chế "VPS First, Local Assist" thực sự, có thể bao gồm việc điều chỉnh logic của worker VPS hoặc cách job được phân phối nếu cần, để đảm bảo local worker chỉ hỗ trợ khi VPS quá tải, chứ không phải xử lý song song ngay từ đầu nếu không cần thiết (hiện tại autoscaler sẽ kích hoạt local worker một khi ngưỡng queue cao được đáp ứng, không có logic ưu tiên worker VPS trong bản thân autoscaler).
