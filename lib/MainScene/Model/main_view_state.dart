class MainViewState {
  final bool isLoggedIn;
  final int selectedIndex;
  final bool isManager;

  MainViewState({
    required this.isLoggedIn,
    required this.selectedIndex,
    required this.isManager,
  });

  MainViewState copyWith({
    bool? isLoggedIn,
    int? selectedIndex,
    bool? isManager,
  }) {
    return MainViewState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isManager: isManager ?? this.isManager,
    );
  }
}
