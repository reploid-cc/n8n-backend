# 📌 Tổng Quan Hệ Thống Queue Cho Khách Hàng

## 1. Phân Loại Người Dùng

| Loại người dùng | Mô tả                                  | Ưu tiên xử lý               |
|------------------|-----------------------------------------|-----------------------------|
| VIP              | Khách hàng đặc biệt, hệ thống nội bộ   | Toàn quyền, bypass queue tổng |
| Premium          | Gói cao cấp trả phí                    | Ưu tiên cao                 |
| Pro              | Gói chuyên nghiệp trả phí              | Ưu tiên trung bình          |
| Free             | Gói miễn phí cơ bản                    | Ưu tiên thấp                |

## 2. Queue Hệ Thống

### 🔁 Queue Tổng (limit_queue)
- Giới hạn tổng số lượng job được xử lý đồng thời.
- Áp dụng cho tất cả user trừ VIP.

### ⚙️ Queue Theo Workflow (limit_workflow)
- Mỗi workflow có thể có giới hạn riêng (VD: workflow A = 400 jobs).
- Tất cả user đều bị giới hạn bởi limit này.

### 👤 Queue Cá Nhân
- Cho phép gán giới hạn riêng theo từng khách hàng.
- Phù hợp với khách agency, hệ thống nội bộ, hoặc doanh nghiệp lớn.

## 3. Fair-Use & Rate Limiting

| Loại người dùng | Rate limit (req/min) | Daily quota      | Concurrent jobs |
|------------------|-----------------------|-------------------|------------------|
| VIP              | 60                    | Không giới hạn    | 10               |
| Premium          | 30                    | 1000              | 5                |
| Pro              | 15                    | 500               | 3                |
| Free             | 5                     | 100               | 1                |

## 4. Queue Overflow Strategy

| Loại người dùng | Khi queue đầy                                      |
|------------------|----------------------------------------------------|
| VIP              | Luôn xử lý ngay (mở rộng queue động)              |
| Premium          | Xếp hàng chờ ưu tiên, tối đa 30 phút              |
| Pro              | Xếp hàng thường, tối đa 2 giờ                      |
| Free             | Trả về thông báo "Hệ thống đang bận"              |

- Tích hợp ETA (estimated time)
- Tự động priority boosting nếu chờ quá lâu

## 5. Monitoring & Alerting System

| Metrics           | Ngưỡng cảnh báo                  | Hành động                    |
|-------------------|----------------------------------|------------------------------|
| Queue length      | >80% capacity                    | Auto-scale resource          |
| Wait time         | >5p (Premium), >15p (Pro)        | Redistribute resources       |
| Error rate        | >5%                              | Alert kỹ thuật               |
| Resource usage    | >90% CPU/RAM                     | Tăng hạ tầng                 |
| Completion rate   | <95%                             | Điều tra lỗi                 |

- Tích hợp Prometheus + Grafana
- Healthcheck định kỳ các workflow

## 6. Dynamic Priority System

| Yếu tố ảnh hưởng     | Mô tả                                       |
|----------------------|----------------------------------------------|
| Job importance       | Urgent/Critical được ưu tiên                |
| Historical behavior  | Người dùng ổn định được ưu tiên             |
| Time sensitivity     | Deadline gần được nâng ưu tiên              |
| Resource usage       | Job nhẹ ưu tiên trong peak time             |
| Business impact      | Job ảnh hưởng doanh thu được boost          |

- Công thức: `priority = base_priority * factor_1 * ... * factor_n`
- Recalculate định kỳ toàn queue

## 7. Retry Mechanism & Error Handling

| Loại lỗi            | Retry | Backoff     | Notification        |
|---------------------|--------|-------------|----------------------|
| Temporary errors    | 3      | 2^n sec     | Sau 2 lần            |
| Resource constraints| 5      | 30 sec      | Ngay lập tức         |
| Auth errors         | 0      | N/A         | Ngay + log           |
| Network errors      | 3      | 5^n sec     | Sau lần 2            |

- Dead-letter queue cho job lỗi vượt ngưỡng
- Phân loại lỗi & Post-mortem analysis

## 8. Billing Integration

| Loại người dùng | Billing model           | Overage charges | Usage tracking     |
|------------------|--------------------------|------------------|---------------------|
| VIP              | Fixed + Usage-based      | Discounted rate  | Full report         |
| Premium          | Tiered pricing           | Standard rate    | Monthly summary     |
| Pro              | Fixed + Pay-as-you-go    | Standard rate    | Basic tracking      |
| Free             | Free tier + Upsell       | Blocked          | Limited tracking    |

- Realtime usage tracking
- Cảnh báo gần hết quota
- Tự động gợi ý nâng gói

## 9. Kiến Trúc Hệ Thống

| Thành phần        | Công nghệ gợi ý           | Vai trò chính                         |
|-------------------|----------------------------|----------------------------------------|
| Queue Manager     | Redis / RabbitMQ / Kafka   | Quản lý job & ưu tiên                  |
| Rate Limiter      | Redis + Lua                | Kiểm soát request                      |
| Scheduler         | Airflow / Temporal         | Orchestrate job                        |
| Monitoring        | Prometheus + Grafana       | Thu thập & trực quan hóa metrics       |
| Auth              | Auth0 / JWT                | Quản lý phân quyền & tier              |
| Resource Manager  | Kubernetes / Docker Swarm  | Phân phối tài nguyên linh hoạt         |

### Triển khai dạng microservices:
```
Client → API Gateway → Auth & Rate Limiter → Queue Manager → Resource Allocator → Workflow Executor → Result Storage → Notification
```

## 10. Roadmap Triển Khai

| Giai đoạn     | Thời gian  | Nội dung                                             |
|---------------|------------|------------------------------------------------------|
| Giai đoạn 1   | 2-3 tuần   | MVP: Redis queue, rate limit, dashboard đơn giản    |
| Giai đoạn 2   | 4-6 tuần   | Dynamic priority, retry logic, billing tích hợp     |
| Giai đoạn 3   | 8-10 tuần  | ML-based prediction, anomaly detection, multi-region|

## ✅ Lưu ý Triển Khai
- Bắt đầu đơn giản, sau đó mở rộng dần
- Stress test trước khi production
- Telemetry đầy đủ để debug
- Tài liệu rõ ràng cho user & admin
