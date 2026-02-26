# dating_app_prototype

File APK sản phẩm (hỗ trợ Android): https://drive.google.com/file/d/1RW0QK3F4DXXcUBkCZ7O2ci4gizaLsKtH/view?usp=sharing

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
- Cải thiện
+ Việc matching account nên được thiết kế lại như queue giúp dễ quản lý việc matching thay vì phải loop và đi đìm lại các match cũ
+ Popup hiển thị match thành công vẫn còn bug khi không hiển thị khi người dùng A và B hoàn thành date schedule người A và C đã liked nhau từ trước và sẽ tạo một date schedule mới
+ Khi tạo date schedule chưa tính đến các edgde case như người dùng không chọn slot available, người dùng offline, 2 người dùng phải cùng confirm date schedule trước khi lưu vào firebase
+ Sử dụng cloud messaging để gửi FCM đến người dùng về việc match thành công
+ Thêm các trường dữ liệu mới khi tạo profile giúp những người khác hiểu rõ hơn như: zodiac, thú cưng, nghề nghiệp. học vấn
- Tính năng đề xuất
+ Sử dụng AI để đề xuất, hỗ trợ matching những người ngại giao tiếp hay hướng nội tìm ra những người dùng có điểm tương đồng với mình
+ Chọn địa điểm bằng GoongMap kết hợp với các sự kiện offline của Clique83 đưa ra các địa điểm date lý tưởng cho cặp đôi

## Demo Project
- Tạo tài khoản mới hoặc sử dụng các tài khoản có sẵn dưới đây
All account password: Taikt08s
Account email and name
+ xtrangemusic@gmail.com (user A name Tài)
+ taidd3141@gmail.com (user B name Dung)
+ xtrange08s@gmail.com (user C name Haan)
+ styematic@gmail.com (user D name Nhi) (Backup account)
- Đăng nhập trên 2 thiết bị giả lập/điện thoại với tài khoản user A và B + like profile của nhau
  <img width="387" height="861" alt="image" src="https://github.com/user-attachments/assets/db80236a-419f-48ec-b9d8-7e798e55a16a" /> <img width="401" height="891" alt="image" src="https://github.com/user-attachments/assets/0d619f5e-bde6-4e5a-952e-f278c7f0937b" />
- Sau khi like thành công sẽ hiện thông báo match thành công
<img width="390" height="882" alt="image" src="https://github.com/user-attachments/assets/f598bfce-7ac1-401d-a4e4-e705a8111ce0" />
- Sử dụng thanh điều hướng và qua phần lịch hẹn để tiếp tục, ở đây người dùng có thể chọn slot hẹn hò vào ngày mà họ mong muốn và chốt hẹn
<img width="795" height="894" alt="image" src="https://github.com/user-attachments/assets/b27badc6-67ef-4ba6-a823-a639f2401d7b" />
- Sau khi chốt chúng ta có sẽ được kết quả như sau. Vì lý do demo nên logic lịch hẹn có thể kết thúc ngay lập tức
<img width="788" height="889" alt="image" src="https://github.com/user-attachments/assets/4868c690-2d36-4b04-9abb-86d753c9e31f" />
- Nếu user A và user B đang hẹn hò nhưng user A tiếp tục like profile user C thì lịch hẹn sẽ không đc tạo cho đến khi lịch hẹn của A và B kết thúc
<img width="794" height="893" alt="image" src="https://github.com/user-attachments/assets/28d09b33-aa23-4813-b547-27af6de889a9" />
- Phía tay trái màn hình là màn hình hẹn lịch của user C mặc dù A và C đã like nhau nhưng lịch vẫn không tạo
<img width="797" height="888" alt="image" src="https://github.com/user-attachments/assets/ecce44db-e336-4e82-adf9-bd9d701d76d4" />
- Khi kết thúc lịch hẹn hẹ thống sẽ kiểm tra xem user A đã like ai khác và người khác đã like lại chưa nếu có sẽ tạo lịch mới với người mới (user C) như hình
<img width="794" height="898" alt="image" src="https://github.com/user-attachments/assets/e345402d-1a47-4036-9455-00302b27e844" />
<img width="789" height="883" alt="image" src="https://github.com/user-attachments/assets/48010944-9980-4b4a-bea9-62cb675efb5c" />
- Người dùng tiếp tục tạo lịch hẹn và tiếp tục. Phần demo đến đây là hết.









  


  

