import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../features/date_schedule/models/dating_schedule_model.dart';

class DatingScheduleRepository extends GetxController {
  static DatingScheduleRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  /// Create schedule when match happens
  Future<void> createSchedule(String userA, String userB) async {
    final slots = _generate3WeeksSlots();

    await _db.collection("DatingSchedules").add({
      "users": [userA, userB],
      "createdAt": FieldValue.serverTimestamp(),
      "slots": slots.map((e) => e.toJson()).toList(),
    });
  }

  /// Generate 3 weeks timeline
  List<DatingSlot> _generate3WeeksSlots() {
    List<DatingSlot> slots = [];

    final now = DateTime.now();

    for (int i = 0; i < 21; i++) {
      final day = now.add(Duration(days: i));

      /// define slots of a day
      final daySlots = [
        DateTime(day.year, day.month, day.day, 9, 30),
        DateTime(day.year, day.month, day.day, 15, 30),
        DateTime(day.year, day.month, day.day, 17, 30),
      ];

      for (final time in daySlots) {
        /// 🔥 KEY LOGIC
        /// skip past time ONLY if it's today
        final isToday =
            day.year == now.year &&
            day.month == now.month &&
            day.day == now.day;

        if (isToday && time.isBefore(now)) {
          continue; // ❌ skip past slot
        }

        slots.add(DatingSlot(time: time));
      }
    }

    return slots;
  }

  /// Update slot
  Future<void> updateSlot({
    required String scheduleId,
    required int index,
    required String userId,
    required String status,
  }) async {
    final doc = _db.collection("DatingSchedules").doc(scheduleId);

    final snapshot = await doc.get();
    final data = snapshot.data()!;

    List slots = data['slots'];

    final users = List<String>.from(data['users']);

    if (users[0] == userId) {
      slots[index]['userA'] = status;
    } else {
      slots[index]['userB'] = status;
    }

    await doc.update({"slots": slots});
  }

  /// REALTIME LISTENER
  Stream<DatingScheduleModel?> listenSchedule(String myId, String matchId) {
    return _db
        .collection("DatingSchedules")
        .where("users", arrayContains: myId)
        .snapshots()
        .map((snapshot) {
          for (var doc in snapshot.docs) {
            final data = doc.data();
            final users = List<String>.from(data['users']);

            if (!users.contains(matchId)) continue;

            /// 🔥 IGNORE finished schedules
            if (data['finished'] == true) continue;

            return DatingScheduleModel.fromSnapshot(doc);
          }

          return null;
        });
  }

  Future<void> finalizeSchedule({
    required String scheduleId,
    required List<DatingSlot> agreedSlots,
  }) async {
    final doc = _db.collection("DatingSchedules").doc(scheduleId);

    final updatedSlots = agreedSlots.map((slot) {
      return DatingSlot(
        time: slot.time,
        userAStatus: slot.userAStatus,
        userBStatus: slot.userBStatus,
        status: "scheduled",
      ).toJson();
    }).toList();

    await doc.update({
      "slots": updatedSlots,
      "finalized": true,
      "finalizedAt": FieldValue.serverTimestamp(),
    });
  }

  Future<bool> isScheduleEnded(DatingScheduleModel schedule) async {
    if (schedule.slots.isEmpty) return true;

    /// 🔥 ALL slots must be ended
    return schedule.slots.every((slot) => slot.status == "ended");
  }

  Future<DatingScheduleModel?> getScheduleBetween(
    String userA,
    String userB,
  ) async {
    final snapshot = await _db
        .collection("DatingSchedules")
        .where("users", arrayContains: userA)
        .get();

    for (var doc in snapshot.docs) {
      final users = List<String>.from(doc['users']);
      if (users.contains(userB)) {
        return DatingScheduleModel.fromSnapshot(doc);
      }
    }

    return null;
  }

  Future<void> updateSlots(String scheduleId, List<DatingSlot> slots) async {
    await _db.collection("DatingSchedules").doc(scheduleId).update({
      "slots": slots.map((e) => e.toJson()).toList(),
    });
  }

  Future<bool> hasActiveSchedule(String userId) async {
    final snapshot = await _db
        .collection("DatingSchedules")
        .where("users", arrayContains: userId)
        .get();

    for (var doc in snapshot.docs) {
      final schedule = DatingScheduleModel.fromSnapshot(doc);

      final isEnded =
          schedule.slots.isNotEmpty &&
          schedule.slots.every((slot) => slot.status == "ended");

      if (!isEnded) {
        return true;
      }
    }

    return false;
  }

  Future<bool> hasActiveScheduleExcept(
    String userId,
    String excludeUserId,
  ) async {
    final snapshot = await _db
        .collection("DatingSchedules")
        .where("users", arrayContains: userId)
        .get();

    for (var doc in snapshot.docs) {
      final users = List<String>.from(doc['users']);

      /// 🔥 Ignore current match schedule
      if (users.contains(excludeUserId)) continue;

      final schedule = DatingScheduleModel.fromSnapshot(doc);

      if (schedule.slots.isEmpty) continue;

      final lastSlot = schedule.slots.last;
      final endTime = lastSlot.time.add(const Duration(hours: 2));

      if (!DateTime.now().isAfter(endTime)) {
        return true;
      }
    }

    return false;
  }

  Future<void> finishSchedule(String scheduleId) async {
    await FirebaseFirestore.instance
        .collection('DatingSchedules')
        .doc(scheduleId)
        .update({"finished": true});
  }

  Future<void> markSlotEnded({
    required String scheduleId,
    required int index,
  }) async {
    final doc = _db.collection("DatingSchedules").doc(scheduleId);

    final snapshot = await doc.get();
    final data = snapshot.data()!;

    List slots = data['slots'];

    slots[index]['status'] = "ended";

    await doc.update({"slots": slots});
  }
}
