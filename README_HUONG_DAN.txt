BỘ FILE GIAO DIỆN SMART HOME MÔ PHỎNG

Bản này được viết lại theo ảnh mẫu người dùng gửi, theo hướng app simulation:

1. Trang chủ tổng quan
- Hiển thị tiêu thụ hôm nay, tiền điện tạm tính, số phòng, số cảnh báo.
- Dữ liệu kWh và tiền điện cập nhật liên tục từ SimulationEngine.
- Có phần tiêu thụ theo phòng và thiết bị thường dùng.

2. Danh sách phòng
- Có các phòng: Phòng khách, Phòng ngủ, Bếp, Phòng giặt, Phòng tắm.
- Bấm vào từng phòng để xem danh sách thiết bị.

3. Danh sách thiết bị theo phòng
- Có tìm kiếm thiết bị.
- Có switch bật/tắt và slider cho thiết bị phù hợp.
- Bấm vào thiết bị để vào trang điều khiển chi tiết.

4. Điều khiển thiết bị chi tiết
- Mô phỏng trang điều hòa: nhiệt độ, chế độ, tốc độ quạt, hẹn giờ, tiêu thụ điện.

5. Thêm/quét thiết bị
- Giữ lại đúng ý tưởng trang quét thiết bị.
- Có radar đang tìm kiếm.
- Có danh sách thiết bị tìm thấy.
- Có nút Quét lại.
- Phần Nhập thủ công nằm ở cuối trang quét và mặc định ẩn.

6. Thống kê tiêu thụ
- Có tab Ngày/Tuần/Tháng/Năm.
- Ngày dùng biểu đồ đường nối điểm và cập nhật liên tục.
- Tuần dùng biểu đồ cột.
- Có thống kê tiêu thụ theo thiết bị.

7. Lịch sử tiêu thụ
- Có biểu đồ đường theo giờ.
- Có bảng phân bổ theo khung giờ.

8. Cảnh báo
- Có tab Tất cả/Thiết bị/Hệ thống.
- Có danh sách cảnh báo giống ảnh mẫu.

9. Cài đặt ngưỡng & quy tắc
- Có ngưỡng ngày, tháng, tiền.
- Có quy tắc tự động tắt thiết bị.

10. Cài đặt chung
- Có thông tin nhà, giá điện, đơn vị tính, lịch sử, cảnh báo, sao lưu, giới thiệu.

Tài khoản đăng nhập demo:
admin / 123456

Cách dùng:
- Mở thư mục SmartHomeNE bằng Qt Creator.
- Cấu hình kit Qt 6.5 trở lên.
- Clean Project nếu trước đó đã build project cũ.
- Build và Run.

Lưu ý:
- Đây là bản giao diện simulation, chưa gắn database thật.
- Các icon đang dùng Unicode để tránh phụ thuộc file ảnh ngoài.
- Nếu bạn đã có class HomeManager cũ, có thể giữ lại, nhưng bản này hoạt động chủ yếu bằng QML + SimulationEngine.
