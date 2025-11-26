import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'auth/view/forgot_password_view.dart';
import 'auth/view/login_view.dart';
import 'auth/view/register_view.dart';
import 'auth/view/barber_register_view.dart';
import 'view/config_view.dart';
import 'view/welcome_view.dart';
import 'view/list_view.dart';
import 'client_flow/view/schedule_view.dart';
import 'view/about_view.dart';
import 'client_flow/view/edit_profile_view.dart';
import '../view/theme_service.dart';

final g = GetIt.instance;

void setupDependencies() {
  // Registra o serviço de tema como um singleton
  g.registerSingleton<ThemeService>(ThemeService());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  setupDependencies();
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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: g<ThemeService>(),
      builder: (context, themeMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Barber Connect',
          theme: ThemeData(brightness: Brightness.light), 
          darkTheme: ThemeData(brightness: Brightness.dark), 
          themeMode: themeMode, 
          initialRoute: '/',
          routes: {
            '/': (context) => const WelcomeView(),
            'register': (context) => RegisterView(),
            'barber_register': (context) => const BarberRegisterView(),
            'forgot_password': (context) => ForgotPasswordView(),
            'agenda': (context) => ScheduleView(),
            'about': (context) => const AboutView(),
            'config': (context) => const ConfigView(),
            'list': (context) => const ListsView(), 
            'edit_profile': (context) => const EditProfileView(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == 'login') {
              final userType = settings.arguments as String;
              return MaterialPageRoute(builder: (context) => LoginView(userType: userType));
            }
            if (settings.name == 'list') {
              // Permite que a rota 'list' receba um argumento opcional para o índice da aba
              final initialIndex = settings.arguments as int? ?? 0;
              return MaterialPageRoute(builder: (context) => ListsView(initialIndex: initialIndex));
            }
            return null; // OFlutter lida com outras rotas
          },
        );
      },
    );
  }
}
