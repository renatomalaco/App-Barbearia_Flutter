import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';
import '../controller/config_controller.dart';
import '../model/config_model.dart';
import '../view/theme_service.dart';

class ConfigView extends StatefulWidget {
  const ConfigView({super.key});

  @override
  State<ConfigView> createState() => _ConfigViewState();
}

class _ConfigViewState extends State<ConfigView> {
  final _controller = ConfigController();
  final _themeService = GetIt.I<ThemeService>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ValueListenableBuilder<BarberSettings>(
          valueListenable: _controller.settings,
          builder: (context, settings, child) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Ajustes e Perfil',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.baloo2(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Flexible(
                  child: ListView(
                    children: [
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, 'edit_profile'),
                        child: CircleAvatar(
                          radius: 50,
                          // Usando um ClipOval para garantir que a imagem fique redonda
                          child: ClipOval(
                            child: Image.network(
                              settings.profileImageUrl,
                              width: 100, // 2x o raio
                              height: 100, // 2x o raio
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          settings.name,
                          style: GoogleFonts.baloo2(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Center(
                        child: Text(
                          settings.email,
                          style: GoogleFonts.baloo2(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      SwitchListTile(
                        title: Text('Habilitar Notificações', style: GoogleFonts.baloo2()),
                        value: settings.notificationsEnabled,
                        onChanged: (bool value) {
                          setState(() {
                            // Atualiza o estado no controller
                            _controller.settings.value.notificationsEnabled = value;
                          });
                        },
                        secondary: const Icon(Icons.notifications_outlined),
                      ),
                      SwitchListTile(
                        title: Text('Modo Escuro', style: GoogleFonts.baloo2()),
                        value: settings.darkModeEnabled,
                        onChanged: (bool value) {
                          setState(() {
                            _controller.settings.value.darkModeEnabled = value;
                            // Notifica o serviço de tema sobre a mudança
                            _themeService.toggleTheme(value);
                          });
                        },
                        secondary: const Icon(Icons.dark_mode_outlined),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: Text('Sobre o App', style: GoogleFonts.baloo2()),
                        onTap: () {
                          Navigator.pushNamed(context, 'about');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: Text('Sair', style: GoogleFonts.baloo2(color: Colors.red)),
                        onTap: () {
                          // Lógica para logout
                          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}