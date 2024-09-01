class MainViewState {
  final bool isLoggedIn;
  final int selectedIndex;

  MainViewState({
    required this.isLoggedIn,
    required this.selectedIndex,
  });

  MainViewState copyWith({
    bool? isLoggedIn,
    int? selectedIndex,
  }) {
    return MainViewState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}
