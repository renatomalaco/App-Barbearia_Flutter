// lib/controller/config_controller.dart

import 'package:flutter/foundation.dart';
import '../model/config_model.dart';

class ConfigController {
  // Usando ValueNotifier para reatividade da UI
  final ValueNotifier<BarberSettings> settings;

  ConfigController()
      : settings = ValueNotifier<BarberSettings>(
          // Dados mocados iniciais
          BarberSettings(name: 'Barbeiro Exemplo', email: 'barbeiro@exemplo.com'),
        );

  void dispose() {
    settings.dispose();
  }
}