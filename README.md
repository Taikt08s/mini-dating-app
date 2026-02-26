# dating_app_prototype

File APK sản phẩm (hỗ trợ Android):

## Tổ chức hệ thống

- Ứng dụng được xây dựng theo mô hình:

+ Frontend: Flutter (GetX)

+ Backend: Firebase (Auth, Firestore, FCM)

+ Architecture: MVVM + Repository Pattern
  
- Luồng dữ liệu

UI (Flutter)
   ↓
Controller (GetX)
   ↓
Repository
   ↓
Firebase (Firestore / Auth)

- Logic account matching
+ Người dùng tạo tài khoản mới và đăng nhập bằng email + password. Họ sẽ chọn người dùng mà họ muốn kết đôi bằng cách like, hệ thống sẽ chạy Future<void> likeUser(UserModel targetUser) (UI update realtime) và lưu vào Firebase. Nếu user A like user B và ngược lại -> MATCH thành công.
+ Hàm likeUser(UserModel targetUser) sẽ được kích hoạt ngay khi like. Hàm này không tạo match mà chỉ cập nhật trạng thái like người kia và id của họ
+ Hàm listenMatchRealtime() được sự dụng để lắng nghe thay đổi ở phía firebase kiểm tra các điều kiện: Hệ thống lặp qua các match cũ để chắc chắn đây là MATCH mới, kiểm tra lịch của người kia xem họ có MATCH nào đang hoạt động hay không. Nếu cả 2 không có schedule đang hoạt động thì việc MATCH mới sẽ diễn ra. Nếu 1 trong 2 người đang có MATCH diễn ra popup sẽ không hiện.

-Logic tìm slot trùng
+ Hàm _generate3WeeksSlots() sẽ tạo 3 slot 1 ngày theo các thời gian cố định là 9:30 + 15:30 + 17:30 trải dài theo 21 ngày (3 tuần). Người dùng A và B sẽ chọn các slot rảnh và không rảnh/không chọn để đưa ra các buổi hẹn họ của mình ở hàm confirmSchedule() trong DatingScheduleController. Validation ở đây bắt người dùng phải chọn ít nhất 3 buổi hẹn hò và phải là 3 buổi có thời gian trùng khớp nhau thì lịch hẹn sẽ được tạo trong Firebase. Khi lưu các slot hệ thống sẽ không lưu tất cả slot trong 21 ngày đó mà chỉ lưu các slot có userA và userB status là "yes" để tối ưu lưu trữ.
+ Khi hệ thống tới khung thời gian mà cả 2 hẹn hò Widget DateCardWidget sẽ tự chuyển sang trạng thái đang diễn ra cùng với nút kết thúc buổi hẹn hò để cập nhật status="ended" cho buổi hẹn đó. Khi tất cả buổi hẹn có status ended thì hệ thống sẽ hiện nút "Kết thúc lịch hẹn" để kết thúc lịch hẹn giữa 2 người. Edge case ở đây: Khi người A và B đã lên lịch hẹn hò và trong thời gian đó người A like profile của người khác C thì hệ thống sẽ không tạo một date schedule mới listenMatchRealtime() và sẽ tạo một date schedule mới giữa A và C  chỉ khi lịch hẹn của A và B đã kết thúc tại finishAndFindNewMatch(String myId).

## Tổng kết




