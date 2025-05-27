# Tổng Hợp Memory Bank

Tài liệu này đóng vai trò như mục lục chính cho Memory Bank. Nó tóm tắt mục đích của mỗi tệp và giúp hướng dẫn việc đọc các tệp dựa trên nhiệm vụ cụ thể.

## Các Tệp Cốt Lõi

### 1. projectbrief.md
- **Mục đích**: Tài liệu nền tảng xác định các yêu cầu cốt lõi và phạm vi dự án
- **Khi nào đọc**: Khi bắt đầu làm việc trên một tính năng mới hoặc để hiểu ranh giới dự án
- **Phần chính**: Tổng quan, Yêu cầu cốt lõi, Mục tiêu, Phạm vi, Lịch trình

### 2. productContext.md
- **Mục đích**: Giải thích lý do tồn tại của dự án này và các vấn đề nó giải quyết
- **Khi nào đọc**: Khi đưa ra quyết định về UX hoặc ưu tiên các tính năng
- **Phần chính**: Vấn đề giải quyết, Người dùng mục tiêu, Mục tiêu trải nghiệm người dùng, Giá trị kinh doanh

### 3. systemPatterns.md
- **Mục đích**: Ghi lại kiến trúc hệ thống và quyết định thiết kế kỹ thuật
- **Khi nào đọc**: Khi thêm các thành phần mới hoặc sửa đổi kiến trúc hệ thống
- **Phần chính**: Tổng quan kiến trúc, Mẫu thiết kế, Cấu trúc thành phần, Luồng dữ liệu

### 4. techContext.md
- **Mục đích**: Phác thảo các công nghệ được sử dụng và ràng buộc kỹ thuật
- **Khi nào đọc**: Khi thiết lập môi trường phát triển hoặc thêm phụ thuộc mới
- **Phần chính**: Công nghệ sử dụng, Môi trường phát triển, Các phụ thuộc, Ràng buộc kỹ thuật

### 5. activeContext.md
- **Mục đích**: Theo dõi trọng tâm công việc hiện tại và thay đổi gần đây
- **Khi nào đọc**: Ở đầu mỗi phiên làm việc để cập nhật trạng thái hiện tại
- **Phần chính**: Trọng tâm hiện tại, Thay đổi gần đây, Bước tiếp theo, Quyết định đang thực hiện

### 6. progress.md
- **Mục đích**: Ghi lại trạng thái dự án, công việc đã hoàn thành và vấn đề đã biết
- **Khi nào đọc**: Khi lên kế hoạch công việc mới hoặc giải quyết vấn đề
- **Phần chính**: Tính năng đã hoàn thành, Công việc đang tiến hành, Vấn đề đã biết, Các mốc quan trọng

## Hướng Dẫn Lựa Chọn Tệp Theo Nhiệm Vụ

1. **Cho phát triển tính năng mới**:
   - Bắt đầu: projectbrief.md, productContext.md
   - Sau đó: activeContext.md, systemPatterns.md

2. **Cho sửa lỗi**:
   - Bắt đầu: progress.md (phần Vấn đề đã biết)
   - Sau đó: activeContext.md, tài liệu tính năng liên quan

3. **Cho thay đổi kiến trúc**:
   - Bắt đầu: systemPatterns.md, techContext.md
   - Sau đó: projectbrief.md (để xác minh sự phù hợp với mục tiêu)

4. **Cho thiết lập môi trường phát triển**:
   - Bắt đầu: techContext.md
   - Sau đó: Bất kỳ tài liệu thiết lập cụ thể nào

## Bối Cảnh Bổ Sung

[Liệt kê bất kỳ tệp/thư mục bối cảnh bổ sung với mục đích khi chúng được thêm vào] 