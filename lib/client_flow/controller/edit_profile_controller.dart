import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/edit_profile_model.dart';

class EditProfileController {
  final ValueNotifier<ClientProfile> userProfile;

  EditProfileController()
      : userProfile = ValueNotifier<ClientProfile>(
          ClientProfile(
            // Tenta pegar o email atual do Auth ou deixa vazio
            name: '', 
            email: FirebaseAuth.instance.currentUser?.email ?? '',
            phone: '',
            // Mantém a imagem padrão por enquanto
            profileImageUrl: 'https://media.discordapp.net/attachments/1249450843002896516/1428545035283992586/jsus_cristo.png?ex=68f2e3bd&is=68f1923d&hm=060b3bddd2cf74cfcdeffa521b00f4c6492013281478d3e2976bcc613d1f822c&=&format=webp&quality=lossless&width=786&height=810',
          ),
        ) {
    _loadCurrentData();
  }

  // Carrega os dados atuais do Firestore para preencher os campos (Consistência)
  Future<void> _loadCurrentData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        // Atualiza o Notifier com os dados reais do banco
        userProfile.value = ClientProfile(
          name: data['name'] ?? '',
          email: data['email'] ?? user.email ?? '',
          phone: data['phone'] ?? '',
          profileImageUrl: userProfile.value.profileImageUrl,
        );
      }
    }
  }

  // Implementação do RF004: Atualização de Dados
  Future<void> saveProfile(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: Usuário não autenticado.')),
      );
      return;
    }

    try {
      // 1. Atualiza a coleção 'users' (Coleção Principal)
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': userProfile.value.name,
        'phone': userProfile.value.phone,
        'updated_at': FieldValue.serverTimestamp(),
      });

      // 2. Atualiza/Cria em uma segunda coleção 'audit_logs' (Coleção Secundária)
      // Isso atende explicitamente o requisito "atualização em pelo menos duas coleções"
      await FirebaseFirestore.instance.collection('audit_logs').add({
        'action': 'UPDATE_PROFILE',
        'user_id': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'details': 'Nome alterado para ${userProfile.value.name}'
      });

      if (!context.mounted) return;

      // Feedback de Sucesso (RF004)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pushNamedAndRemoveUntil(context, 'list', (route) => false);

    } catch (e) {
      // Feedback de Falha (RF004)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha ao atualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void dispose() {
    userProfile.dispose();
  }
}