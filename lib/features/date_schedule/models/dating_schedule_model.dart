import 'package:cloud_firestore/cloud_firestore.dart';

class DatingSlot {
  DateTime time;
  String userAStatus;
  String userBStatus;
  String status;

  DatingSlot({
    required this.time,
    this.userAStatus = "empty",
    this.userBStatus = "empty",
    this.status = "created",
  });

  Map<String, dynamic> toJson() => {
    "time": time,
    "userA": userAStatus,
    "userB": userBStatus,
    "status": status,
  };

  factory DatingSlot.fromMap(Map<String, dynamic> data) {
    return DatingSlot(
      time: (data['time'] as Timestamp).toDate(),
      userAStatus: data['userA'] ?? "empty",
      userBStatus: data['userB'] ?? "empty",
      status: data['status'] ?? "created",
    );
  }
}

class DatingScheduleModel {
  String id;
  List<String> users;
  List<DatingSlot> slots;
  bool finished;

  DatingScheduleModel({
    required this.id,
    required this.users,
    required this.slots,
    this.finished = false,
  });

  factory DatingScheduleModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return DatingScheduleModel(
      id: doc.id,
      users: List<String>.from(data['users']),
      slots: (data['slots'] as List).map((e) => DatingSlot.fromMap(e)).toList(),
      finished: data['finished'] ?? false,
    );
  }
}
