import 'dart:async';
import 'package:get/get.dart';

import '../../../data/repositories/dating_schedule/dating_schedule_repository.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/popups/loaders.dart';
import '../../matching_profile/controllers/account_mathcing_controller.dart';
import '../models/dating_schedule_model.dart';

class DatingScheduleController extends GetxController {
  static DatingScheduleController get instance => Get.find();

  final repo = Get.put(DatingScheduleRepository());

  Rx<DatingScheduleModel?> schedule = Rx<DatingScheduleModel?>(null);
  Rx<ScheduleState> state = ScheduleState.loading.obs;
  String? _currentMatchId;
  StreamSubscription? _subscription;
  bool _hasTriggeredFinish = false;

  void init(String myId, String matchId) {
    ///Prevent duplicate listeners
    if (_currentMatchId == matchId) return;

    _currentMatchId = matchId;

    /// cancel old listener
    _subscription?.cancel();

    _subscription = repo.listenSchedule(myId, matchId).listen((data) async {
      if (data == null) {
        schedule.value = null;
        state.value = ScheduleState.empty;

        return;
      }

      if (data.finished == true && !_hasTriggeredFinish) {
        _hasTriggeredFinish = true;
        await finishAndFindNewMatch(myId);
        return;
      }

      schedule.value = data;
      await autoUpdateSlotStatuses();

      state.value = ScheduleState.hasData;
    });
  }

  void updateSlot(int index, String status, String myId) {
    if (schedule.value == null) return;

    repo.updateSlot(
      scheduleId: schedule.value!.id,
      index: index,
      userId: myId,
      status: status,
    );
  }

  Future<void> confirmSchedule() async {
    final current = schedule.value;
    if (current == null) return;
    final agreedSlots = current.slots.where(
          (slot) => slot.userAStatus == "yes" && slot.userBStatus == "yes",
    ).toList();

    if (agreedSlots.isEmpty) {
      TLoaders.warningSnackBar(
        title: 'Không có thời gian phù hợp',
        message: 'Chưa tìm được thời gian trùng. Vui lòng chọn lại.',
      );
      return;
    }

    if (agreedSlots.length < 3) {
      TLoaders.warningSnackBar(
        title: 'Chưa đủ điều kiện',
        message: 'Cả hai cần chọn ít nhất 3 khung giờ phù hợp để chốt lịch hẹn.',
      );
      return;
    }
    await repo.finalizeSchedule(
      scheduleId: current.id,
      agreedSlots: agreedSlots,
    );

    TLoaders.successSnackBar(
      title: 'Thành công',
      message: 'Lịch hẹn đã được chốt 💕',
    );
  }

  Future<void> autoUpdateSlotStatuses() async {
    final current = schedule.value;
    if (current == null) return;

    bool hasChanged = false;

    for (var slot in current.slots) {
      final endTime = slot.time.add(const Duration(hours: 2));

      if (DateTime.now().isAfter(endTime) && slot.status != "ended") {
        slot.status = "ended";
        hasChanged = true;
      }
    }

    /// 🔥 ONLY update Firestore if something changed
    if (hasChanged) {
      await repo.updateSlots(current.id, current.slots);
    }
  }

  Future<String?> findValidMatch(String myId, List<String> matches) async {
    for (var matchId in matches.reversed) {
      final schedule = await repo.getScheduleBetween(myId, matchId);

      if (schedule != null) {
        if (schedule.finished == true) continue;

        return matchId;
      }
    }

    return matches.isNotEmpty ? matches.last : null;
  }
  Future<void> finishAndFindNewMatch(String myId) async {
    final current = schedule.value;
    if (current == null) return;

    /// 1. mark finished
    await repo.finishSchedule(current.id);

    /// 2. get all matches
    final matches = AccountMatchingController.instance.currentUser.value.matches;

    for (var matchId in matches.reversed) {

      /// skip current partner
      if (current.users.contains(matchId)) continue;

      /// check if BOTH free
      final myBusy = await repo.hasActiveSchedule(myId);
      final otherBusy = await repo.hasActiveSchedule(matchId);

      if (!myBusy && !otherBusy) {

        /// check if schedule already exists
        final existed = await repo.getScheduleBetween(myId, matchId);

        if (existed == null) {
          await repo.createSchedule(myId, matchId);
          init(myId, matchId);
          state.value = ScheduleState.loading;
          schedule.value = null;
          TLoaders.successSnackBar(
            title: "Ghép lịch mới",
            message: "Đã tạo lịch hẹn mới 💕",
          );

          return;
        }
      }
    }

    TLoaders.warningSnackBar(
      title: "Không có lịch mới",
      message: "Hiện chưa có người phù hợp để lên lịch.",
    );
  }

  Future<void> markSlotEnded(int index) async {
    final current = schedule.value;
    if (current == null) return;

    /// 🔥 prevent ending too early
    final slot = current.slots[index];

    // final now = DateTime.now();
    // if (now.isBefore(slot.time)) {
    //   TLoaders.warningSnackBar(
    //     title: "Chưa đến giờ",
    //     message: "Bạn chưa thể kết thúc lịch hẹn này.",
    //   );
    //   return;
    // }

    await repo.markSlotEnded(
      scheduleId: current.id,
      index: index,
    );
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}