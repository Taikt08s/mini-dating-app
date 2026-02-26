import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HobbySelector extends StatelessWidget {
  final RxList<String> selectedHobbies;

  const HobbySelector({
    super.key,
    required this.selectedHobbies,
  });

  @override
  Widget build(BuildContext context) {
    final hobbies = [
      "Gym",
      "Game",
      "Du lịch",
      "Âm nhạc",
      "Ăn uống",
      "Phim",
      "Công nghệ",
      "Thể thao",
      "Thú cưng",
      "Nghệ thuật",
    ];

    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.brown,
      Colors.cyan,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Sở thích",
          style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(hobbies.length, (index) {
            final hobby = hobbies[index];
            final isSelected =
            selectedHobbies.contains(hobby);

            return GestureDetector(
              onTap: () {
                if (isSelected) {
                  selectedHobbies.remove(hobby);
                } else {
                  selectedHobbies.add(hobby);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors[index].withValues(alpha: 0.8)
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  hobby,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 12
                  ),
                ),
              ),
            );
          }),
        )),
      ],
    );
  }
}