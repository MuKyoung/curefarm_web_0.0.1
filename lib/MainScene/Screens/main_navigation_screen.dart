import 'dart:math';
import 'package:curefarm_beta/Extensions/Sizes.dart';
import 'package:curefarm_beta/AuthScene/repos/authentication_repo.dart';
import 'package:curefarm_beta/MainScene/view_models/main_view_model.dart';
import 'package:curefarm_beta/SettingScene/Screens/settings_screen.dart';
import 'package:curefarm_beta/widgets/nav_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();

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
    "inbox",
    "profile",
  ];

  late int _selectedIndex = _tabs.indexOf(widget.tab);

  final screens = [
    const Center(
      child: Text(
        'Home',
        style: TextStyle(fontSize: 49),
      ),
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
      child: Text(
        'Profile',
        style: TextStyle(fontSize: 49),
      ),
    ),
  ];

  void _onTap(int index) {
    context.go("/${_tabs[index]}");
    setState(() {
      _selectedIndex = index;
    });
  }

  void _goToSettingsScreen(){
Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const SettingsScreen(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(mainViewModelProvider);
    
    return
    loginState.when(data: (isLoggedIn){
      return Scaffold(
      appBar: AppBar(
        elevation: 10,
        actions: [IconButton(
        onPressed: _goToSettingsScreen,
        icon: const FaIcon(FontAwesomeIcons.gear),),],),
      body: Stack(
        children: [
          Offstage(
            offstage: _selectedIndex != 0,
            child : screens.elementAt(_selectedIndex),
          ),
          Offstage(
            offstage: _selectedIndex != 1,
            child : screens.elementAt(_selectedIndex),
          ),
          Offstage(
            offstage: _selectedIndex != 3,
            child : screens.elementAt(_selectedIndex),
          ),
          Offstage(
            offstage: _selectedIndex != 4,
            child : screens.elementAt(_selectedIndex),
          ),
        ],),
      bottomNavigationBar: BottomAppBar(
        elevation: 10,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            NavTab(
              text: "홈",
              isSelected: _selectedIndex == 0,
              icon: FontAwesomeIcons.house,
              onTap: () => _onTap(0),
            ),
            NavTab(
              text: "검색",
              isSelected: _selectedIndex == 1,
              icon: FontAwesomeIcons.magnifyingGlass,
              onTap: () => _onTap(1),
            ),
            isLoggedIn ? 
            NavTab(
              text: "채팅",
              isSelected: _selectedIndex == 3,
              icon: FontAwesomeIcons.message,
              onTap: () => _onTap(3),
            ) : const SizedBox.shrink(),
            NavTab(
              text: "프로필",
              isSelected: _selectedIndex == 4,
              icon: FontAwesomeIcons.user,
              onTap: () => _onTap(4),
            ),
          ],
        ),
      ),
    );
    },
    loading: () => const CircularProgressIndicator(),
    error: (error, stack) => Text('Error: $error'),);
  }
}