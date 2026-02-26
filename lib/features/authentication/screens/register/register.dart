import 'package:flutter/material.dart';
import 'package:mini_dating_app_prototype/features/authentication/screens/register/widgets/register_form.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/sizes.dart';
import '../login/login.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppBar(
        title: Text('Tạo Tài Khoản'),
        showCloseButton: true,
        navigateOnClose: LoginScreen(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(TSizes.mediumLargeSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title
                  const Text(
                    'Kiểm tra lại thông tin và tạo tài khoản',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),

                  /// Form
                  const TRegisterForm(),
                  const SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
