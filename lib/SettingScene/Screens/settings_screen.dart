import 'package:curefarm_beta/AuthScene/Screens/SignUp&Login/login_screen.dart';
import 'package:curefarm_beta/AuthScene/repos/authentication_repo.dart';
import 'package:curefarm_beta/MainScene/Screens/main_navigation_screen.dart';
import 'package:curefarm_beta/MainScene/view_models/main_view_model.dart';
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
    final viewModelState = ref.watch(mainViewModelProvider);

    return viewModelState.when(
      data: (state) {
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
              state.isLoggedIn && !state.isManager
                  ? ListTile(
                      title: const Text("관리자 모드 전환"),
                      textColor: Colors.black,
                      onTap: () {
                        showCupertinoDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("관리자 모드 전환"),
                            content: const Text("관리자 모드로 전환하시겠습니까?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text(
                                  "아니요",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                  ref
                                      .read(mainViewModelProvider.notifier)
                                      .updateSelectedIndex(6);
                                  ref
                                      .read(mainViewModelProvider.notifier)
                                      .converToManagerMode(true);
                                  context.go("/managerHome");
                                },
                                child: const Text(
                                  "네",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                  : const SizedBox.shrink(),
              state.isLoggedIn && state.isManager
                  ? ListTile(
                      title: const Text("고객 모드 전환"),
                      textColor: Colors.black,
                      onTap: () {
                        showCupertinoDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("고객 모드 전환"),
                            content: const Text("고객 모드로 전환하시겠습니까?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text(
                                  "아니요",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                  ref
                                      .read(mainViewModelProvider.notifier)
                                      .updateSelectedIndex(0);
                                  ref
                                      .read(mainViewModelProvider.notifier)
                                      .converToManagerMode(false);
                                  context.go("/home");
                                },
                                child: const Text(
                                  "네",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                  : const SizedBox.shrink(),
              state.isLoggedIn
                  ? ListTile(
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
                                child: const Text(
                                  "아니요",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  ref.read(authRepo).logOut();
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                  ref
                                      .read(mainViewModelProvider.notifier)
                                      .updateSelectedIndex(1);
                                  context.go("/home");
                                },
                                child: const Text(
                                  "네",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : const SizedBox.shrink(),
              !state.isLoggedIn
                  ? ListTile(
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
                                child: const Text(
                                  "No",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    context.go(LoginScreen.routeURL),
                                child: const Text(
                                  "Yes",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : const SizedBox.shrink(),
              const AboutListTile(
                applicationVersion: "1.0",
                applicationLegalese: "Don't copy me.",
              ),
            ],
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
