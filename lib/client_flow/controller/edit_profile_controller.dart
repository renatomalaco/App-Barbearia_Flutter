// lib/client_flow/controller/edit_profile_controller.dart

import 'package:flutter/material.dart';
import '../model/edit_profile_model.dart';

class EditProfileController {
  final ValueNotifier<ClientProfile> userProfile;

  EditProfileController()
      : userProfile = ValueNotifier<ClientProfile>(
          ClientProfile(
            name: 'Barbeiro Exemplo',
            email: 'barbeiro@exemplo.com',
            phone: '',
            profileImageUrl: 'https://media.discordapp.net/attachments/1249450843002896516/1428545035283992586/jsus_cristo.png?ex=68f2e3bd&is=68f1923d&hm=060b3bddd2cf74cfcdeffa521b00f4c6492013281478d3e2976bcc613d1f822c&=&format=webp&quality=lossless&width=786&height=810',
          ),
        );

  void saveProfile(BuildContext context) {
    // Aqui iria a lógica para salvar os dados em um backend ou localmente.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil salvo com sucesso!')),
    );
    Navigator.pushNamedAndRemoveUntil(context, 'list', (route) => false);
  }

  void dispose() {
    userProfile.dispose();
  }
}