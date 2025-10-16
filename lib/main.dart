import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'view/forgot_password_view.dart';
import 'view/login_view.dart';
import 'view/register_view.dart';
import 'view/welcome_view.dart';
import 'view/list_view.dart';

final g = GetIt.instance;

void main() {
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => const MainApp()
    )
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BabearIA',
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeView(),
        'login': (context) => LoginView(),
        'register': (context) => RegisterView(),
        'forgot_password': (context) => ForgotPasswordView(),
        'list': (context) => ListsView(),
      },
    );
  }
}
