import 'package:flutter/material.dart';

import '../controller/config_controller.dart';
import '../model/config_model.dart';

class ConfigView extends StatefulWidget {
  const ConfigView({super.key});

  @override
  State<ConfigView> createState() => _ConfigViewState();
}

class _ConfigViewState extends State<ConfigView> {
  final _controller = ConfigController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes e Perfil'),
        backgroundColor: Colors.black87,
      ),
      body: ValueListenableBuilder<BarberSettings>(
        valueListenable: _controller.settings,
        builder: (context, settings, child) {
          return ListView(
            children: [
              const SizedBox(height: 24),
              const CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1000&auto=format&fit=crop'),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  settings.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: Text(
                  settings.email,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              SwitchListTile(
                title: const Text('Habilitar Notificações'),
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
                title: const Text('Modo Escuro'),
                value: settings.darkModeEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _controller.settings.value.darkModeEnabled = value;
                  });
                },
                secondary: const Icon(Icons.dark_mode_outlined),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Sair', style: TextStyle(color: Colors.red)),
                onTap: () {
                  // Lógica para logout
                  Navigator.of(context).pushNamedAndRemoveUntil('login', (route) => false);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}