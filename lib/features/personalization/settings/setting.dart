
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/custom_shapes/containers/primary_header_container.dart';
import '../../../../common/widgets/list_titles/settings_menu_title.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final controller = Get.put(UserController());
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ///Header
            TPrimaryHeaderContainer(
              child: Column(
                children: [
                  TAppBar(
                      title: Text('Thiết lập tài khoản',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .apply(color: TColors.white)),
                      showBackArrow: false),

                  ///User Profile Card
                  // ListTile(
                  //   leading: Stack(
                  //     children: [
                  //       CircleAvatar(
                  //           backgroundImage: (controller
                  //               .user.value.profilePicture.isNotEmpty)
                  //               ? NetworkImage(
                  //               controller.user.value.profilePicture)
                  //               : const AssetImage(TImages.userImageMale)
                  //           as ImageProvider,
                  //           radius: 25),
                  //       Positioned(
                  //         bottom: 0,
                  //         right: 0,
                  //         child: Obx(() => Container(
                  //           width: 11,
                  //           height: 11,
                  //           decoration: BoxDecoration(
                  //             color: controller.user.value.isOnline
                  //                 ? Colors.green
                  //                 : Colors.grey,
                  //             shape: BoxShape.circle,
                  //             border:
                  //             Border.all(color: Colors.white, width: 2),
                  //           ),
                  //         )),
                  //       ),
                  //     ],
                  //   ),
                  //   title: Obx(() {
                  //     if (controller.profileLoading.value) {
                  //       return const TShimmerEffect(width: 50, height: 20);
                  //     }
                  //     return Text(controller.user.value.fullName,
                  //         style: Theme.of(context)
                  //             .textTheme
                  //             .headlineSmall!
                  //             .apply(color: TColors.white));
                  //   }),
                  //   subtitle: Obx(
                  //         () => Text(controller.user.value.email,
                  //         style: Theme.of(context)
                  //             .textTheme
                  //             .bodyMedium!
                  //             .apply(color: TColors.white)),
                  //   ),
                  //   trailing: IconButton(
                  //       onPressed: () {},
                  //       icon: const Icon(Iconsax.edit, color: TColors.white)),
                  // ),
                  const SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),
            ),

            ///Body
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  ///Account Settings
                  const TSectionHeading(
                      title: 'Tài khoản', showActionButton: false),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  TSettingsMenuTile(
                    icon: Iconsax.user_octagon,
                    title: 'Tài Khoản & Bảo Mật',
                    subtitle: 'Thiết lập tài khoản',
                    onTap: () => Get.to(() => ()),
                  ),
                  TSettingsMenuTile(
                    icon: Iconsax.card,
                    title: 'Đăng kí',
                    subtitle: 'Những gói đăng kí hiện tại của bạn',
                    onTap: () => Get.to(() => ()),
                  ),
                  const TSectionHeading(
                      title: 'Cài đặt', showActionButton: false),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  TSettingsMenuTile(
                    icon: Iconsax.message_question,
                    title: 'Trung Tâm Trợ Giúp',
                    subtitle: 'Hỗ trợ đến từ nhân viên tư vấn',
                    onTap: () {},
                  ),

                  ///Logout
                  const SizedBox(height: TSizes.spaceBtwSections),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => logoutAccountWarningPopup(),
                      child: const Text('Đăng xuất'),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void logoutAccountWarningPopup() {
    final controller = Get.put(AuthenticationRepository());
    Get.defaultDialog(
      contentPadding: const EdgeInsets.all(TSizes.md),
      title: 'Đăng xuất',
      middleText: 'Điều này sẽ đưa bạn trở về trang đăng nhập',
      confirm: ElevatedButton(
              onPressed: () async {
                await controller.logout();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red)),
              child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: TSizes.lg),
                  child: Text('Đồng ý')),
      ),
      // ElevatedButton
      cancel: OutlinedButton(
        child: const Text('Hủy bỏ'),
        onPressed: () => Navigator.of(Get.overlayContext!).pop(),
      ), // OutlinedButton
    );
  }
}