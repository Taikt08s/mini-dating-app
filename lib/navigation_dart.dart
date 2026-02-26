import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mini_dating_app_prototype/utils/constants/colors.dart';
import 'package:mini_dating_app_prototype/utils/helpers/helper_functions.dart';

import 'features/date_schedule/screens/date_schedule.dart';
import 'features/matching_profile/screens/account_matching/account_matching.dart';
import 'features/personalization/settings/setting.dart';


class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 80,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) =>
              controller.selectedIndex.value = index,
          backgroundColor: dark ? TColors.black : TColors.white,
          indicatorColor: dark
              ? TColors.white.withAlpha((0.1 * 255).round())
              : TColors.primary.withAlpha((0.1 * 255).round()),
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          destinations: const [
            NavigationDestination(
              icon: Icon(Iconsax.heart),
              label: 'Ghép đôi',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.calendar),
              label: 'Lịch hẹn',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.setting),
              label: 'Cài đặt',
            ),
          ],
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    const AccountMatchingScreen(),
    const DatingScheduleScreen(),
    const SettingsScreen(),
  ];
}
