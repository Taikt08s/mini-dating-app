import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mini_dating_app_prototype/features/matching_profile/screens/account_matching/widgets/account_matching_card.dart';

import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/account_mathcing_controller.dart';

class AccountMatchingScreen extends StatelessWidget {
  const AccountMatchingScreen({super.key});

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    // TODO: Fetch matching users
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AccountMatchingController());
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: TColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(TSizes.spaceBtwItems),
            child: Column(
              children: [
                /// HEADER
                const TSectionHeading(
                  title: 'Hệ thống đề xuất',
                  showActionButton: false,
                ),

                const SizedBox(height: TSizes.spaceBtwItems),

                /// EMPTY STATE (no users yet)
                Obx(() {
                  if (controller.users.isEmpty) {
                    return const Text("Chưa có người dùng");
                  }

                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.75,
                    child: PageView.builder(
                      controller: PageController(viewportFraction: 0.9),
                      itemCount: controller.users.length,
                      itemBuilder: (_, index) {
                        final user = controller.users[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: AccountMatchingCard(user: user),
                        );
                      },
                    ),
                  );
                }),

                const SizedBox(height: TSizes.spaceBtwSections),

                /// MATCHES SECTION
                const TSectionHeading(
                  title: 'Kết đôi của bạn',
                  showActionButton: false,
                ),

                const SizedBox(height: TSizes.spaceBtwItems),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.favorite, size: 50, color: Colors.pink),
                      SizedBox(height: 12),
                      Text(
                        'Chưa có kết đôi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Khi bạn và ai đó ghép đôi và lên lịch hẹn, thông tin sẽ hiển thị tại đây 💕',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
