import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../model/edit_profile_model.dart';

class EditProfileController {
  final ValueNotifier<ClientProfile> userProfile;
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  EditProfileController()
      : userProfile = ValueNotifier<ClientProfile>(
          ClientProfile(
            name: '',
            email: FirebaseAuth.instance.currentUser?.email ?? '',
            phone: '',
            profileImageUrl: '', // Começa vazio para usar o fallback na UI
          ),
        ) {
    _loadCurrentData();
  }

  Future<void> _loadCurrentData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      
      String currentName = '';
      String currentEmail = user.email ?? ''; // Pega do Auth por padrão
      String currentPhone = '';
      String currentImage = '';

      if (doc.exists) {
        final data = doc.data()!;
        currentName = data['name'] ?? '';
        // Se tiver email no banco usa, senão mantém o do Auth
        if (data['email'] != null && data['email'].toString().isNotEmpty) {
          currentEmail = data['email'];
        }
        currentPhone = data['phone'] ?? '';
        currentImage = data['profileImageUrl'] ?? '';
      }

      // Atualiza os valores
      userProfile.value = ClientProfile(
        name: currentName,
        email: currentEmail,
        phone: currentPhone,
        profileImageUrl: currentImage,
      );
    }
  }

  // Função para Selecionar Imagem (Apenas Local)
  Future<void> pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Apenas atualiza o estado local com o caminho do arquivo
      userProfile.value = ClientProfile(
        name: userProfile.value.name,
        email: userProfile.value.email,
        phone: userProfile.value.phone,
        profileImageUrl: image.path, // Salva o caminho local!
      );
      // Notifica os ouvintes (UI)
      // userProfile.notifyListeners(); // (Se necessário, mas o value setter já faz isso em ValueNotifier)
    }
  }

  Future<void> saveProfile(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    isLoading.value = true;
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': userProfile.value.name,
        'phone': userProfile.value.phone,
        'email': userProfile.value.email,
        // Salva o caminho local no banco
        'profileImageUrl': userProfile.value.profileImageUrl, 
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil salvo com sucesso!'), backgroundColor: Colors.green),
        );
        // Retorna para a tela anterior
        Navigator.pop(context); 
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void dispose() {
    userProfile.dispose();
    isLoading.dispose();
  }
}