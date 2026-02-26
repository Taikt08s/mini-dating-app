import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/validators/validation.dart';
import '../../../controllers/register/register_controller.dart';
import 'hobby_selector.dart';

class TRegisterForm extends StatelessWidget {
  const TRegisterForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());

    return Form(
      key: controller.signupFormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: TSizes.spaceBtwSections),
        child: Column(
          children: [

            /// Name
            TextFormField(
              controller: controller.name,
              validator: (value) =>
                  TValidator.validateEmptyText('Tên', value),
              decoration: const InputDecoration(
                labelText: 'Tên',
                prefixIcon: Icon(Iconsax.user),
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwInputFields),

            Row(
              children: [
                /// Age
                Expanded(
                  child: TextFormField(
                    controller: controller.age,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        TValidator.validateAge(value),
                    decoration: const InputDecoration(
                      labelText: 'Tuổi',
                      prefixIcon: Icon(Iconsax.calendar),
                    ),
                  ),
                ),

                const SizedBox(width: TSizes.spaceBtwInputFields),

                /// Gender
                Expanded(
                  child: Obx(
                        () => DropdownButtonFormField<String>(
                      initialValue: controller.gender.value.isEmpty
                          ? null
                          : controller.gender.value,
                      items: ['Nam', 'Nữ', 'Khác']
                          .map((gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      ))
                          .toList(),
                      onChanged: (value) {
                        controller.gender.value = value ?? '';
                      },
                      decoration: const InputDecoration(
                        labelText: 'Giới tính',
                        prefixIcon: Icon(Iconsax.people),
                      ),
                      validator: (value) =>
                      value == null ? 'Hãy chọn giới tính' : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            HobbySelector(
              selectedHobbies: controller.selectedHobbies,
            ),

            const SizedBox(height: TSizes.spaceBtwInputFields),

            /// Bio
            TextFormField(
              controller: controller.bio,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Bio (mô tả ngắn)',
                prefixIcon: Icon(Iconsax.note),
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwInputFields),

            /// Email
            TextFormField(
              controller: controller.email,
              validator: (value) =>
                  TValidator.validateEmail(value),
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Iconsax.direct),
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwInputFields),

            /// Password
            Obx(
                  () => TextFormField(
                controller: controller.password,
                validator: (value) =>
                    TValidator.validatePassword(value),
                obscureText: controller.hidePassword.value,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  prefixIcon: const Icon(Iconsax.password_check),
                  suffixIcon: IconButton(
                    onPressed: () => controller.hidePassword.value =
                    !controller.hidePassword.value,
                    icon: Icon(
                      controller.hidePassword.value
                          ? Iconsax.eye_slash
                          : Iconsax.eye,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            /// Register Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => controller.signup(),
                child: const Text('Đăng ký'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
