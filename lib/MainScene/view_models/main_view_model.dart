import 'package:curefarm_beta/AuthScene/repos/authentication_repo.dart';
import 'package:curefarm_beta/MainScene/Model/main_view_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ViewModel 클래스 정의
class MainViewModel extends StateNotifier<AsyncValue<MainViewState>> {
  final AuthenticationRepository _authRepo;

  MainViewModel(this._authRepo) : super(const AsyncValue.loading()) {
    _authRepo.authStateChanges().listen((User? user) {
      state = AsyncValue.data(MainViewState(
        isLoggedIn: user != null,
        selectedIndex: 0,
      ));
    });
  }

  void updateSelectedIndex(int index) {
    state = AsyncValue.data(state.value!.copyWith(selectedIndex: index));
  }
}

final mainViewModelProvider =
    StateNotifierProvider<MainViewModel, AsyncValue<MainViewState>>(
  (ref) {
    return MainViewModel(ref.watch(authRepo));
  },
);
