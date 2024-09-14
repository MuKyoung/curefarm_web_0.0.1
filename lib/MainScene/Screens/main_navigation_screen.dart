import 'package:curefarm_beta/MainScene/Screens/home_screen.dart';
import 'package:curefarm_beta/MainScene/view_models/main_view_model.dart';
import 'package:curefarm_beta/ManagerMainScene/Screens/manager_home_screen.dart';
import 'package:curefarm_beta/ManagerMainScene/Screens/upload_page.dart';
import 'package:curefarm_beta/ProfilePage/View/user_profile_view.dart';
import 'package:curefarm_beta/SettingScene/Screens/settings_screen.dart';
import 'package:curefarm_beta/widgets/nav_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();

  static const String routeName = "mainNavigation";

  final String tab;

  const MainNavigationScreen({
    super.key,
    required this.tab,
  });
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  final List<String> _tabs = [
    "home",
    "discover",
    "xxxx",
    "chat",
    "profile",
    "managerHome",
    "managerChat",
  ];

  final screens = [
    const Center(
      child: HomeScreen(),
    ),
    const Center(
      child: Text(
        'Search',
        style: TextStyle(fontSize: 49),
      ),
    ),
    Container(),
    const Center(
      child: Text(
        'Chats',
        style: TextStyle(fontSize: 49),
      ),
    ),
    const Center(
      child: UserProfileScreen(),
    ),
    const Center(
      child: UploadPage(),
    ),
    const Center(
      child: Text(
        '매니저 채팅',
        style: TextStyle(fontSize: 49),
      ),
    ),
  ];

  void _onTap(int index) {
    ref.read(mainViewModelProvider.notifier).updateSelectedIndex(index);
    context.go("/${_tabs[index]}");
  }

  void _goToSettingsScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModelState = ref.watch(mainViewModelProvider);

    return viewModelState.when(
      data: (state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            actions: [
              IconButton(
                onPressed: _goToSettingsScreen,
                icon: const FaIcon(FontAwesomeIcons.gear),
              ),
            ],
          ),
          body: Stack(
            children: screens.asMap().entries.map((entry) {
              int idx = entry.key;
              Widget screen = entry.value;
              return Offstage(
                offstage: state.selectedIndex != idx,
                child: screen,
              );
            }).toList(),
          ),
          bottomNavigationBar: BottomAppBar(
            elevation: 10,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                !state.isManager
                    ? NavTab(
                        text: "홈",
                        isSelected: state.selectedIndex == 0,
                        icon: FontAwesomeIcons.house,
                        onTap: () => _onTap(0),
                      )
                    : const SizedBox.shrink(),
                !state.isManager
                    ? NavTab(
                        text: "검색",
                        isSelected: state.selectedIndex == 1,
                        icon: FontAwesomeIcons.magnifyingGlass,
                        onTap: () => _onTap(1),
                      )
                    : const SizedBox.shrink(),
                state.isLoggedIn && !state.isManager
                    ? NavTab(
                        text: "채팅",
                        isSelected: state.selectedIndex == 3,
                        icon: FontAwesomeIcons.message,
                        onTap: () => _onTap(3),
                      )
                    : const SizedBox.shrink(),
                state.isManager
                    ? NavTab(
                        text: "매니저홈",
                        isSelected: state.selectedIndex == 5,
                        icon: FontAwesomeIcons.house,
                        onTap: () => _onTap(5),
                      )
                    : const SizedBox.shrink(),
                state.isManager
                    ? NavTab(
                        text: "매니저채팅",
                        isSelected: state.selectedIndex == 6,
                        icon: FontAwesomeIcons.message,
                        onTap: () => _onTap(6),
                      )
                    : const SizedBox.shrink(),
                state.isLoggedIn
                    ? NavTab(
                        text: "프로필",
                        isSelected: state.selectedIndex == 4,
                        icon: FontAwesomeIcons.user,
                        onTap: () => _onTap(4),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
