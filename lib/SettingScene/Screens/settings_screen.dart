import 'package:curefarm_beta/AuthScene/Screens/SignUp&Login/login_screen.dart';
import 'package:curefarm_beta/AuthScene/repos/authentication_repo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const routeName = "settings";
  static const routeURL = "/settings";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile.adaptive(
            value: false,
            onChanged: (value) {},
            title: const Text("Enable notifications"),
            subtitle: const Text("They will be cute."),
          ),
          CheckboxListTile(
            activeColor: Colors.black,
            value: false,
            onChanged: (value) {},
            title: const Text("Marketing emails"),
            subtitle: const Text("We won't spam you."),
          ),
          ListTile(
            title: const Text("Log out"),
            textColor: Colors.red,
            onTap: () {
              showCupertinoDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Are you sure?"),
                  content: const Text("Plx dont go"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("No", style: TextStyle(color: Colors.red),),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(authRepo).logOut();
                        Navigator.of(context).pop();
                      },
                      child: const Text("Yes", style: TextStyle(color: Colors.blue),),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            title: const Text("Log In"),
            textColor: Colors.blue,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Are you sure?"),
                  content: const Text("Plx dont go"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("No", style: TextStyle(color: Colors.red),),
                    ),
                    TextButton(
                      onPressed: () => context.go(LoginScreen.routeURL),
                      child: const Text("Yes", style: TextStyle(color: Colors.blue),),
                    ),
                  ],
                ),
              );
            },
          ),
          const AboutListTile(
            applicationVersion: "1.0",
            applicationLegalese: "Don't copy me.",
          ),
        ],
      ),
    );
  }
}