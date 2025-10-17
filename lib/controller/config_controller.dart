// lib/controller/config_controller.dart

import 'package:flutter/foundation.dart';
import '../model/config_model.dart';

class ConfigController {
  // Usando ValueNotifier para reatividade da UI
  final ValueNotifier<BarberSettings> settings;

  ConfigController()
      : settings = ValueNotifier<BarberSettings>(
          // Dados mocados iniciais
          BarberSettings(
              name: 'Barbeiro Exemplo',
              email: 'barbeiro@exemplo.com',
              profileImageUrl:
                  'https://media.discordapp.net/attachments/1249450843002896516/1428545035283992586/jsus_cristo.png?ex=68f2e3bd&is=68f1923d&hm=060b3bddd2cf74cfcdeffa521b00f4c6492013281478d3e2976bcc613d1f822c&=&format=webp&quality=lossless&width=786&height=810'),
        );

  void dispose() {
    settings.dispose();
  }
}