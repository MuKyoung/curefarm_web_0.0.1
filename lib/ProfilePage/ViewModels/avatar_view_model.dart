import 'dart:async';
import 'dart:io';

import 'package:curefarm_beta/AuthScene/repos/authentication_repo.dart';
import 'package:curefarm_beta/users/repos/user_repo.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AvatarViewModel extends AsyncNotifier<void> {
  late final UserRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.read(userRepo);
  }

  Future<void> uploadAvatar(File file) async {
    state = const AsyncValue.loading();
    final fileName = ref.read(authRepo).user!.uid;
    state = await AsyncValue.guard(
      () async => await _repository.uploadAvatar(file, fileName),
    );
  }
}
