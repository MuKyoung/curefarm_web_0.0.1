import 'package:curefarm_beta/MainScene/Screens/main_navigation_screen.dart';
import 'package:curefarm_beta/AuthScene/Screens/tutorial_screen.dart';
import 'package:curefarm_beta/AuthScene/Screens/SignUp&Login/login_screen.dart';
import 'package:curefarm_beta/AuthScene/Screens/SignUp&Login/sign_up_screen.dart';
import 'package:curefarm_beta/AuthScene/repos/authentication_repo.dart';
import 'package:curefarm_beta/SettingScene/Screens/settings_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider((ref){  
  return GoRouter(
  initialLocation: SignUpScreen.routeURL,
  // redirect: (context, state) {
  //   final isLoggedIn = ref.read(authRepo).isLoggedIn;
  //   if(!isLoggedIn){
  //     if(state.matchedLocation != SignUpScreen.routeURL && 
  //       state.matchedLocation != LoginScreen.routeURL){
  //     return SignUpScreen.routeURL;
  //     }
  //   }
  //   return null;
  // },
  routes: [
    GoRoute(
      name: SignUpScreen.routeName,
      path: SignUpScreen.routeURL,
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      name: LoginScreen.routeName,
      path: LoginScreen.routeURL,
      builder: (context, state) => const LoginScreen(),
    ),
     GoRoute(
      name: SettingsScreen.routeName,
      path: SettingsScreen.routeURL,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: "/:tab(home|discover|inbox|profile)",
      name: MainNavigationScreen.routeName,
      builder: (context, state) {
        final tab = state.pathParameters["tab"]!;
        return MainNavigationScreen(tab: tab);
      },
    )
  ],
);});