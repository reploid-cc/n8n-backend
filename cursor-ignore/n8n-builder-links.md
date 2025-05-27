# N8n Builder - Danh Sách Đường Link

Tài liệu này tổng hợp tất cả các đường link dịch vụ trong dự án n8n-builder, phân loại theo môi trường triển khai.

## Môi Trường Local (Development)

| Dịch vụ | URL Local | URL Tunnel | Port | Mô tả |
|---------|-----------|------------|------|-------|
| n8n | [http://localhost:5678](http://localhost:5678) | [https://n8n.ai-automation.cloud](https://n8n.ai-automation.cloud) | 5678 | Giao diện chính n8n |
| NocoDB | [http://localhost:8080](http://localhost:8080) | [https://nocodb.ai-automation.cloud/](https://nocodb.ai-automation.cloud/) | 8080 | Database web interface |
| PostgreSQL | localhost:5432 | | 5432 | Database server |
| Redis | localhost:6379 | | 6379 | Cache và message queue |
| Nginx | [http://localhost](http://localhost) / [https://localhost](https://localhost) | | 80/443 | Web server |

### Thông tin đăng nhập mặc định

#### n8n
- **Username:** admin@example.com
- **Password:** password

#### PostgreSQL
- **Username:** n8nuser
- **Password:** yoursecurepassword
- **Database:** n8ndb
- **Host:** postgres (trong mạng Docker) hoặc localhost (từ máy host)
- **Port:** 5432

#### NocoDB
- **Email:** admin@example.com
- **Password:** password

### Kết nối PostgreSQL từ NocoDB

NocoDB đã được cấu hình tự động kết nối với PostgreSQL, nhưng nếu cần thiết lập thủ công:

1. Truy cập NocoDB tại http://localhost:8080
2. Đăng nhập với thông tin mặc định
3. Tại màn hình Project Explorer, click "New Project"
4. Chọn "Database Type" là "PostgreSQL"
5. Nhập thông tin kết nối:
   - **Host**: postgres (vì cùng trong mạng Docker)
   - **Port**: 5432
   - **Username**: n8nuser
   - **Password**: yoursecurepassword
   - **Database**: n8ndb

## Môi Trường Production (VPS)

*Chú ý: Các đường link VPS sẽ được cập nhật khi triển khai môi trường production.*

| Dịch vụ | URL | Port | Mô tả |
|---------|-----|------|-------|
| n8n | [https://n8n.masteryflow.cc](https://n8n.masteryflow.cc) | 5678 | Giao diện chính n8n |
| Worker Group | (internal) | - | Worker nodes |
| Monitoring | (sẽ cập nhật) | - | Grafana monitoring |

## Tunnel URLs

Tunnel URLs được tạo bởi Cloudflare Tunnel để truy cập các dịch vụ local từ internet.

| Dịch vụ | URL Tunnel | Liên kết đến |
|---------|------------|--------------|
| n8n | [https://n8n.ai-automation.cloud](https://n8n.ai-automation.cloud) | localhost:5678 |

## URLs Hữu ích khác

| Dịch vụ | URL | Mô tả |
|---------|-----|-------|
| GitHub Repository | [https://github.com/reploid-cc/n8n-builder](https://github.com/reploid-cc/n8n-builder) | Source code repository |
| Documentation | (sẽ cập nhật) | Tài liệu hướng dẫn sử dụng |

## Hướng dẫn truy cập

### Truy cập local
1. Đảm bảo Docker environment đang chạy: `docker ps`
2. Truy cập các dịch vụ qua localhost với các port tương ứng

### Truy cập qua tunnel
1. Đảm bảo container Cloudflared đang chạy
2. Truy cập n8n qua URL tunnel: [https://n8n.ai-automation.cloud](https://n8n.ai-automation.cloud)

### Sử dụng NocoDB thông qua Nginx proxy
Để truy cập NocoDB qua Nginx proxy, sử dụng URL:
- HTTP: [http://localhost/nocodb/](http://localhost/nocodb/)
- HTTPS: [https://localhost/nocodb/](https://localhost/nocodb/) (cần chấp nhận certificate tự ký)

### Truy cập HTTPS với certificate tự ký
Khi truy cập https://localhost, bạn sẽ thấy cảnh báo về certificate không tin cậy. Đây là bình thường vì chúng ta đang sử dụng certificate tự ký cho môi trường phát triển. Bạn có thể bỏ qua cảnh báo này và tiếp tục truy cập.

## Ghi chú
- Các URL và thông tin đăng nhập ở môi trường production sẽ khác với môi trường development
- Trong môi trường production, tất cả các dịch vụ sẽ được bảo vệ bằng authentication
- Tunnel URLs có thể thay đổi, tài liệu này sẽ được cập nhật khi có thay đổi
- Đường dẫn Cloudflared tunnel cần được cấu hình trong file config.yml và được mount vào container 