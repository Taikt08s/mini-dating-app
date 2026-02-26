import 'package:flutter/material.dart';

import '../../../../utils/constants/image_strings.dart';

class EmptyDateSchedule extends StatelessWidget {
  const EmptyDateSchedule({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            TImages.emptyBoxImage,
            width: 220,
          ),
          const SizedBox(height: 20),
          const Text(
            "Chưa có lịch hẹn",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text("Hãy đi tìm tri kỉ của bạn nào 💕"),
        ],
      ),
    );
  }
}