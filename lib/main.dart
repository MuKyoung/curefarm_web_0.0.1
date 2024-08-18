import 'package:curefarm_beta/Extensions/Sizes.dart';
import 'package:curefarm_beta/SignUp&Login/email_screen.dart';
import 'package:curefarm_beta/SignUp&Login/sign_up_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CureFarm());
}

class CureFarm extends StatelessWidget {
  const CureFarm({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '큐어팜 0.0.1',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.blue,
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: Sizes.size16 + Sizes.size2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: const SignUpScreen(),
    );
  }
}
