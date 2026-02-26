import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../features/authentication/models/user_models.dart';
import '../dating_schedule/dating_schedule_repository.dart';

class AccountMatchingRepository extends GetxController {
  static AccountMatchingRepository get instance => Get.find();
  final scheduleRepo = Get.put(DatingScheduleRepository());
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get all users
  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _db.collection("Users").get();

    return snapshot.docs.map((doc) => UserModel.fromSnapshot(doc)).toList();
  }

  /// Like user
  Future<void> likeUser({
    required String myId,
    required String targetId,
  }) async {
    bool isMatch = false;

    final myRef = _db.collection("Users").doc(myId);
    final targetRef = _db.collection("Users").doc(targetId);

    await _db.runTransaction((transaction) async {
      final mySnap = await transaction.get(myRef);
      final targetSnap = await transaction.get(targetRef);

      final myData = mySnap.data()!;
      final targetData = targetSnap.data()!;

      List myLiked = List.from(myData['LikedUsers'] ?? []);
      List targetLiked = List.from(targetData['LikedUsers'] ?? []);

      /// 1. Add like
      if (!myLiked.contains(targetId)) {
        myLiked.add(targetId);
        transaction.update(myRef, {'LikedUsers': myLiked});
      }

      transaction.update(targetRef, {
        'LikedByUsers': FieldValue.arrayUnion([myId])
      });

      /// 2. CHECK MATCH
      if (targetLiked.contains(myId)) {
        isMatch = true;

        List myMatches = List.from(myData['Matches'] ?? []);
        List targetMatches = List.from(targetData['Matches'] ?? []);

        if (!myMatches.contains(targetId)) {
          myMatches.add(targetId);
          transaction.update(myRef, {'Matches': myMatches});
        }

        if (!targetMatches.contains(myId)) {
          targetMatches.add(myId);
          transaction.update(targetRef, {'Matches': targetMatches});
        }
      }
    });

    /// ✅ AFTER transaction → safe to call async
    if (isMatch) {
      final repo = DatingScheduleRepository.instance;

      /// 🔥 GLOBAL CHECK (MOST IMPORTANT FIX)
      final myBusy = await repo.hasActiveSchedule(myId);
      final targetBusy = await repo.hasActiveSchedule(targetId);

      if (myBusy || targetBusy) {
        if (kDebugMode) {
          print("⛔ One of users already has active schedule → SKIP");
        }
        return;
      }

      /// ✅ SAFE → create schedule
      await repo.createSchedule(myId, targetId);

      if (kDebugMode) {
        print("🔥 SCHEDULE CREATED (NO CONFLICT)");
      }
    }
  }

  /// Add match for both users
  Future<void> addMatch({
    required String myId,
    required String targetId,
  }) async {
    await _db.collection("Users").doc(myId).update({
      'Matches': FieldValue.arrayUnion([targetId]),
    });

    await _db.collection("Users").doc(targetId).update({
      'Matches': FieldValue.arrayUnion([myId]),
    });
  }

  /// Listen current user (REALTIME for popup)
  Stream<UserModel> listenCurrentUser(String uid) {
    return _db
        .collection("Users")
        .doc(uid)
        .snapshots()
        .map((doc) => UserModel.fromSnapshot(doc));
  }
}
