import 'package:flutter/material.dart';
import 'package:mini_dating_app_prototype/features/authentication/screens/login/widgets/login_form.dart';
import 'package:mini_dating_app_prototype/features/authentication/screens/login/widgets/login_header.dart';

import '../../../../common/styles/spacing_styles.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: TSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            children: [
              /// Logo, Title & Sub-Title
              TLoginHeader(),

              ///Form
              TLoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}
