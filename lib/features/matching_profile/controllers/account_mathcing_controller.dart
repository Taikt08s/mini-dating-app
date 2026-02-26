import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../data/repositories/account_matching/account_matching_repository.dart';
import '../../../features/authentication/models/user_models.dart';
import '../../../data/repositories/authentication/user_repository.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';

class AccountMatchingController extends GetxController {
  static AccountMatchingController get instance => Get.find();

  final repository = Get.put(AccountMatchingRepository());
  final userRepository = Get.put(UserRepository());

  RxList<UserModel> users = <UserModel>[].obs;
  Rx<UserModel> currentUser = UserModel.empty().obs;

  List<String> oldMatches = [];

  @override
  void onInit() {
    init();
    super.onInit();
  }

  Future<void> init() async {
    await fetchCurrentUser();
    await fetchUsers();
    listenMatchRealtime();
  }

  /// Fetch current user
  Future<void> fetchCurrentUser() async {
    final user = await UserRepository.instance.fetchUserDetails();
    currentUser.value = user;
    oldMatches = List.from(user.matches);
  }

  /// Fetch users
  Future<void> fetchUsers() async {
    final uid = AuthenticationRepository.instance.authUser?.uid;

    final allUsers = await repository.getAllUsers();

    users.assignAll(allUsers.where((u) => u.id != uid).toList());
  }

  /// Like user
  Future<void> likeUser(UserModel targetUser) async {
    final myId = currentUser.value.id;

    if (currentUser.value.likedUsers.contains(targetUser.id)) return;

    /// UI update instantly
    currentUser.value.likedUsers.add(targetUser.id);
    currentUser.refresh();

    /// Firebase
    await repository.likeUser(myId: myId, targetId: targetUser.id);
  }

  /// 🔥 REALTIME MATCH LISTENER (BOTH USERS SEE POPUP)
  void listenMatchRealtime() {
    final uid = AuthenticationRepository.instance.authUser?.uid;
    if (uid == null) return;

    repository.listenCurrentUser(uid).listen((updatedUser) async {
      currentUser.value = updatedUser;

      final newMatches = updatedUser.matches;

      for (var matchId in newMatches) {
        if (!oldMatches.contains(matchId)) {

          /// 🔥 SIMPLE RULE: only check MYSELF
          final myBusy = await repository.scheduleRepo.hasActiveSchedule(uid);
          final otherBusy = await repository.scheduleRepo.hasActiveSchedule(matchId);

          if (!myBusy && !otherBusy) {
            _showMatchPopup(matchId);
          } else {
            if (kDebugMode) {
              print("⛔ One of users busy → NO POPUP");
            }
          }
        }
      }

      oldMatches = List.from(newMatches);
    });
  }

  void _showMatchPopup(String matchUserId) async {
    final matchedUser = await UserRepository.instance.getUserById(matchUserId);

    Get.defaultDialog(
      title: "🎉 Ghép đôi thành công!",
      middleText: "Bạn và ${matchedUser?.name ?? ''} đã thích nhau.Hãy lên lịch cho cuộc hẹn hò đầu tiên nào ❤️",
      textConfirm: "Tiếp tục",
      onConfirm: () => Get.back(),
    );
  }

  bool isLiked(String userId) {
    return currentUser.value.likedUsers.contains(userId);
  }
}
