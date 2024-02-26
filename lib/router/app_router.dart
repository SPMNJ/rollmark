import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rollmark/dto/form_data.dart';
import 'package:rollmark/form/page.dart';
import 'package:rollmark/recruitment/activity.dart';
import 'package:rollmark/recruitment/mobile_screen.dart';
import 'package:rollmark/recruitment/recruits.dart';
import 'package:rollmark/ui/create_page.dart';
import 'package:rollmark/ui/form_page.dart';

import '../provider.dart';

import '../ui/forgot_page.dart';
import '../ui/home_page.dart';
import '../ui/login_page.dart';
import '../ui/splash_page.dart';

final _key = GlobalKey<NavigatorState>();
final _recruitmentKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  FutureOr<bool> checkFormEditing(context) async {
    if (!ref.read(formEditing)) {
      return true;
    }
    Future<bool?> test = showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text(
              'You have unsaved changes. Are you sure you want to exit without saving?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
    bool? result = await test;
    if (result == true) {
      ref.read(formEditing.notifier).update((state) => false);
      return true;
    } else {
      return false;
    }
  }

  FormDoc? formDoc;

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
      GoRoute(
        path: "/forms",
        name: "forms",
        builder: (context, state) {
          return FormPage();
        },
        routes: [
          GoRoute(
              path: "new",
              name: "form-new",
              builder: (context, state) {
                return FormEditPage();
              },
              onExit: (context) => checkFormEditing(context)),
          GoRoute(
            path: ":formID",
            name: "form-edit",
            builder: (context, state) {
              if (state.extra != null) {
                formDoc = state.extra as FormDoc;
                return FormEditPage(existingDoc: formDoc);
              } else {
                throw Exception("No form data found");
              }
            },
            redirect: (context, state) {
              if (state.pathParameters["formID"] == null) {
                return '/forms';
              } else if (state.extra != null) {
                return null;
              }
              FirebaseFirestore.instance
                  .collection('forms')
                  .doc(state.pathParameters["formID"])
                  .get()
                  .then((doc) {
                if (!doc.exists) {
                  return '/forms';
                }
                formDoc = FormDoc.fromDocument(doc);
                return null;
              });
              return '/forms';
            },
            onExit: (context) => checkFormEditing(context),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      // If our async state is loading, don't perform redirects, yet
      if (authState.isLoading || authState.hasError) return null;

      // Here we guarantee that hasData == true, i.e. we have a readable value

      // This has to do with how the FirebaseAuth SDK handles the "log-in" state
      // Returning `null` means "we are not authorized"
      final isAuth = authState.valueOrNull != null;

      final isSplash = state.uri.toString() == "/";
      if (isSplash) {
        return null;
      }

      final isLoggingIn = state.uri.toString() == "/login" ||
          state.uri.toString() == "/login/forgot-password" ||
          state.uri.toString() == "/login/create";
      if (isLoggingIn) return isAuth ? "/home" : null;

      return isAuth ? null : "/login";
    },
  );
});
