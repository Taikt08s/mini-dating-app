import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../utils/constants/colors.dart';
import '../../controllers/dating_schedule_controller.dart';
import '../../models/dating_schedule_model.dart';

class DateCardWidget extends StatelessWidget {
  final DatingSlot slot;
  final int index;

  const DateCardWidget({super.key, required this.slot, required this.index});

  String getStatus() {
    if (slot.status == "ended") return "ended";
    final now = DateTime.now();

    if (now.isBefore(slot.time)) {
      return "scheduled";
    }
    return "in_progress";
  }

  /// 🎨 map status → UI
  (Color, String) getStatusUI(String status) {
    switch (status) {
      case "in_progress":
        return (Colors.orange.shade500, "Đang diễn ra");
      case "ended":
        return (Colors.green.shade500, "Đã kết thúc");
      case "scheduled":
      case "created":
        return (Colors.purple.shade500, "Sắp tới");
      default:
        return (Colors.grey.shade500, "Không xác định");
    }
  }

  @override
  Widget build(BuildContext context) {
    final derivedStatus = getStatus();
    final (color, text) = getStatusUI(derivedStatus);
    final controller = DatingScheduleController.instance;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// 🕒 TIME
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, dd/MM', 'vi_VN').format(slot.time),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('HH:mm').format(slot.time),
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),

          /// 📌 STATUS
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(Icons.circle, color: color, size: 12),
              const SizedBox(height: 6),
              Text(
                text,
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (derivedStatus == "in_progress")
            GestureDetector(
              onTap: () async {
                await controller.markSlotEnded(index);
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: TColors.warning,
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Kết\nthúc",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
