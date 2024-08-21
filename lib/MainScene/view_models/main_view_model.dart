import 'package:curefarm_beta/AuthScene/repos/authentication_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainViewModel extends StateNotifier<AsyncValue<bool>> {
  final AuthenticationRepository _authRepo;

 MainViewModel(this._authRepo) : super(const AsyncValue.loading()) {
    _authRepo.authStateChanges().listen((User? user) {
      state = AsyncValue.data(user != null);
    });
 }
}

final mainViewModelProvider = StateNotifierProvider<MainViewModel, AsyncValue<bool>>(
  (ref) {
    return MainViewModel(ref.watch(authRepo));
  },
);