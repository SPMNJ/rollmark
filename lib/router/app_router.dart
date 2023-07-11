import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rollmark/recruitment/activity.dart';
import 'package:rollmark/recruitment/mobile_screen.dart';
import 'package:rollmark/recruitment/recruits.dart';
import 'package:rollmark/ui/create_page.dart';

import '../auth.dart';

import '../ui/forgot_page.dart';
import '../ui/home_page.dart';
import '../ui/login_page.dart';
import '../ui/splash_page.dart';

final _key = GlobalKey<NavigatorState>();
final _recruitmentKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _key,
    debugLogDiagnostics: true,
    initialLocation: "/",
    routes: [
      GoRoute(
        path: "/",
        name: "splash-page",
        builder: (context, state) {
          return const SplashPage();
        },
      ),
      GoRoute(
        path: "/home",
        name: "home",
        builder: (context, state) {
          return const Home();
        },
      ),
      GoRoute(
          path: "/login",
          name: "login",
          builder: (context, state) {
            return const Login();
          },
          routes: [
            GoRoute(
              path: "forgot-password",
              name: "forgot-password",
              builder: (context, state) {
                return const ForgotPassword();
              },
            ),
            GoRoute(
                path: "create",
                name: "sign-up",
                builder: (context, state) {
                  return const CreateAccount();
                }),
          ]),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          MediaQueryData mediaQuery = MediaQuery.of(context);
          if (mediaQuery.size.width > 600) {
            //Desktop screen size
            return const Placeholder();
          } else {
            //Mobile screen size
            return RecruitMobileScreen(navigationShell);
          }
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _recruitmentKey,
            routes: [
              GoRoute(
                  path: "/recruitment",
                  name: "recruitment",
                  builder: (context, state) {
                    return const RecruitPage();
                  }),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                  path: "/recruitactivity",
                  name: "recruitment-activity",
                  builder: (context, state) {
                    return const RecruitLogPage();
                  }),
            ],
          ),
        ],
      ),
    ],  
    redirect: (context, state) { 
      return null;
      // If our async state is loading, don't perform redirects, yet
      if (authState.isLoading || authState.hasError) return null;

      // Here we guarantee that hasData == true, i.e. we have a readable value

      // This has to do with how the FirebaseAuth SDK handles the "log-in" state
      // Returning `null` means "we are not authorized"
      final isAuth = authState.valueOrNull != null;

      final isSplash = state.location == "/";
      if (isSplash) {
        return null;
      }

      final isLoggingIn = state.location == "/login" ||
          state.location == "/login/forgot-password" ||
          state.location == "/login/create";
      if (isLoggingIn) return isAuth ? "/home" : null;

      return isAuth ? null : "/login";
    },
  );
});
