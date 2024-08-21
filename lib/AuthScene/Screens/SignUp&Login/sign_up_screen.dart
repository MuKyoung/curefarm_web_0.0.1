import 'package:curefarm_beta/Extensions/Gaps.dart';
import 'package:curefarm_beta/Extensions/Sizes.dart';
import 'package:curefarm_beta/AuthScene/Screens/SignUp&Login/email_screen.dart';
import 'package:curefarm_beta/AuthScene/Screens/SignUp&Login/login_screen.dart';
import 'package:curefarm_beta/AuthScene/Screens/SignUp&Login/username_screen.dart';
import 'package:curefarm_beta/AuthScene/widgets/auth_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  static String routeName = "signup";
  static String routeURL = "/signup";

  void _onLoginTap(BuildContext context) {
    context.go(LoginScreen.routeURL);
  }

  void _onEmailTap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const UsernameScreen(),
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
                  "큐어팜 회원가입",
                  style: TextStyle(
                    fontSize: Sizes.size24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Gaps.v20,
                const Text(
                  "계정을 생성하여 큐어팜과 함께하세요",
                  style: TextStyle(
                    fontSize: Sizes.size16,
                    color: Colors.black45,
                  ),
                  textAlign: TextAlign.center,
                ),
                Gaps.v40,
                GestureDetector(
                onTap: () => _onEmailTap(context),
                child: const AuthButton(
                  icon: FaIcon(FontAwesomeIcons.user),
                  text: "이메일로 시작하기",
                ),
              ),
                Gaps.v16,
                const AuthButton(
                  icon: FaIcon(FontAwesomeIcons.google),
                  text: "구글로 시작하기",
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
              '이미 계정이 있으신가요?',
              style: TextStyle(
                fontSize: Sizes.size16,
              ),
            ),
            Gaps.h5,
            GestureDetector(
              onTap: () => _onLoginTap(context),
              child: Text(
                '로그인',
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