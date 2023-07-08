import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      context.go('/home');
    });
    return const FlutterLogo();
  }
}
