import 'package:curefarm_beta/Extensions/Gaps.dart';
import 'package:curefarm_beta/Extensions/Sizes.dart';
import 'package:curefarm_beta/SignUp&Login/login_form.dart';
import 'package:curefarm_beta/SignUp&Login/email_screen.dart';
import 'package:curefarm_beta/widgets/auth_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _onSignUpTap(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _onEmailLoginTap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginFormScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Gaps.v80,
                const Text(
                  "큐어팜 로그인",
                  style: TextStyle(
                    fontSize: Sizes.size24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Gaps.v20,
                const Text(
                  "로그인하여 큐어팜만의 서비스를 경험하세요",
                  style: TextStyle(
                    fontSize: Sizes.size16,
                    color: Colors.black45,
                  ),
                  textAlign: TextAlign.center,
                ),
                Gaps.v40,
                GestureDetector(
                onTap: () => _onEmailLoginTap(context),
                child: const AuthButton(
                  icon: FaIcon(FontAwesomeIcons.user),
                  text: "이메일 로그인",
                ),
                ),
                Gaps.v16,
                const AuthButton(
                  icon: FaIcon(FontAwesomeIcons.google),
                  text: "구글 로그인",
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey.shade100,
        elevation: 2,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "계정이 없으신가요?",
              style: TextStyle(
                fontSize: Sizes.size16,
              ),
            ),
            Gaps.h5,
            GestureDetector(
              onTap: () => _onSignUpTap(context),
              child: Text(
                "회원가입",
                style: TextStyle(
                  fontSize: Sizes.size16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}