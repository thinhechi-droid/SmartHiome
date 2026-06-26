HOTFIX lỗi QML PageHeader

Lỗi cũ:
RoomsView.qml:41:17: Cannot assign to non-existent property "onAddClicked"

Nguyên nhân:
PageHeader.qml dùng property var onAddClicked/onBackClicked. Trong QML, cú pháp onAddClicked: ... được hiểu là signal handler, không phải gán property bình thường. Vì vậy Qt báo không tìm thấy signal/property hợp lệ.

Đã sửa:
- PageHeader.qml đổi sang signal backClicked(), addClicked(), bellClicked(), gearClicked().
- Các dòng onBackClicked/onAddClicked trong những màn hình khác dùng được đúng chuẩn QML.
- AddDeviceView.qml sửa Timer để quét dừng thật sau 5 nhịp, không chạy nền vô hạn.

Cách dùng:
1. Copy toàn bộ thư mục SmartHomeNE này ghi đè vào project hiện tại, hoặc tối thiểu copy:
   - components/PageHeader.qml
   - AddDeviceView.qml
2. Trong Qt Creator chọn Clean Project.
3. Xóa thư mục build cũ nếu vẫn còn lỗi cache.
4. Build và chạy lại.
