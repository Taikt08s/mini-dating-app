
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../data/repositories/authentication/user_repository.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../../../utils/popups/loaders.dart';
import '../../models/user_models.dart';
import '../../screens/login/login.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();

  /// UI State
  final hidePassword = true.obs;
  final policy = true.obs;

  /// Controllers
  final name = TextEditingController();
  final age = TextEditingController();
  final bio = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  RxList<String> selectedHobbies = <String>[].obs;
  final gender = ''.obs;

  /// Form Key
  final GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  final storage = const FlutterSecureStorage();

  /// Signup Function
  void signup() async {
    try {
      TFullScreenLoader.openLoadingDialog(
          'Đang xử lí chờ xíu...', TImages.loadingCircle);

      /// Check internet
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      /// Validate form
      if (!signupFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      /// Policy check
      if (!policy.value) {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(
          title: 'Vui lòng chấp nhận điều khoản',
          message:
          'Bạn cần đồng ý với chính sách để tiếp tục sử dụng ứng dụng',
        );
        return;
      }

      /// Register user (Firebase Auth)
      final userCredential = await AuthenticationRepository.instance
          .registerWithEmailAndPassword(
          email.text.trim(), password.text.trim());

      /// Create UserModel
      final newUser = UserModel(
        id: userCredential.user!.uid,
        name: name.text.trim(),
        age: int.tryParse(age.text.trim()) ?? 18,
        gender: gender.value,
        bio: bio.text.trim(),
        email: email.text.trim(),
        profilePicture: '',
        isOnline: false,
        likedUsers: [],
        likedByUsers: [],
        matches: [],
        hobbies: selectedHobbies.toList(),
      );

      /// Save to Firestore
      final userRepository = Get.put(UserRepository());
      await userRepository.saveUserRecord(newUser);

      TFullScreenLoader.stopLoading();

      /// Success
      TLoaders.successSnackBar(
        title: 'Thành công',
        message: 'Tài khoản đã được tạo!',
      );
      Get.offAll(() => const LoginScreen());

    } catch (e) {
      TFullScreenLoader.stopLoading();

      TLoaders.errorSnackBar(
        title: 'Xảy ra lỗi',
        message: e.toString(),
      );
    }
  }
}
