import 'dart:async';

import 'package:curefarm_beta/AuthScene/Screens/tutorial_screen.dart';
import 'package:curefarm_beta/AuthScene/repos/authentication_repo.dart';
import 'package:curefarm_beta/users/view_models/users_view_model.dart';
import 'package:firebase/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignupViewModel extends AsyncNotifier<void> {
  late final AuthenticationRepository _authRepo;

  @override
  FutureOr<void> build() {
    _authRepo = ref.read(authRepo);
  }

  Future<void> signUp(BuildContext context) async {
    state = const AsyncValue.loading();
    final form = ref.read(signUpForm);
    final users = ref.read(usersProvider.notifier);
    state = await AsyncValue.guard(() async {
      final userCredential = await _authRepo.emailSignUp(
        form["email"],
        form["password"],
      );

      await userCredential.user!.updateDisplayName(
        form["username"],
      );

      await userCredential.user!.reload();
      var currentUser = FirebaseAuth.instance.currentUser;
      print("currentUser: ${currentUser?.displayName}");
      await users.createProfile(userCredential);
    });

    if (state.hasError) {
      final snack = SnackBar(
        action: SnackBarAction(
          label: "확인",
          onPressed: () {},
        ),
        content:
            Text((state.error as FirebaseException).message ?? "잘못된 시도입니다."),
      );
      ScaffoldMessenger.of(context).showSnackBar(snack);
    } else {
      context.go(TutorialScreen.routeURL);
    }
  }
}

final signUpForm = StateProvider((ref) => {});

final signUpProvider = AsyncNotifierProvider<SignupViewModel, void>(
  () => SignupViewModel(),
);
