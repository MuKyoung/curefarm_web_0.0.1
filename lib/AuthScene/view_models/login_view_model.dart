import 'dart:async';

import 'package:curefarm_beta/AuthScene/repos/authentication_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginViewModel extends AsyncNotifier<void> {
  late final AuthenticationRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.read(authRepo);
  }

  Future<void> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () async => await _repository.signIn(email, password),
    );
    if (state.hasError) {
      final snack = SnackBar(
        action: SnackBarAction(label: "확인",
        onPressed: () {},),
        content: Text((state.error as FirebaseException).message ?? "잘못된 시도입니다."),);
      ScaffoldMessenger.of(context).showSnackBar(snack);
    } else {
      context.go("/home");
    }
  }
}

final loginProvider = AsyncNotifierProvider<LoginViewModel, void>(
  () => LoginViewModel(),
);