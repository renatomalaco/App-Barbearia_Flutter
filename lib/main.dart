import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'view/auth/forgot_password_view.dart';
import 'view/auth/login_view.dart';
import 'view/auth/register_view.dart';
import 'view/welcome_view.dart';
import 'view/list_view.dart';
import 'view/schedule_view.dart';
import 'view/chat_view.dart';

final g = GetIt.instance;

void main() {
  initializeDateFormatting('pt_BR', null).then((_) {
    runApp(
      DevicePreview(
        enabled: true,
        builder: (context) => const MainApp()
      )
    );
  });
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
        'agenda': (context) => ScheduleView(),
        'chat': (context) => ChatView(),
      },
    );
  }
}
