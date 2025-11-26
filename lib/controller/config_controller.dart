import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/config_model.dart';

class ConfigController {
  final ValueNotifier<BarberSettings> settings;

  // Stream para ouvir mudanças no perfil em tempo real
  Stream<DocumentSnapshot>? _userStream;

  ConfigController()
      : settings = ValueNotifier<BarberSettings>(
          BarberSettings(
            name: 'Carregando...',
            email: '',
            profileImageUrl: '',
          ),
        ) {
    _initRealtimeData();
  }

  void _initRealtimeData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Escuta o documento do usuário no Firestore em tempo real (RF005)
      _userStream = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots();

      _userStream!.listen((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          settings.value = BarberSettings(
            name: data['name'] ?? 'Usuário',
            email: data['email'] ?? user.email ?? '',
            // Se não tiver foto, manda string vazia para a View tratar
            profileImageUrl: data['profileImageUrl'] ?? '',
            notificationsEnabled: settings.value.notificationsEnabled,
            darkModeEnabled: settings.value.darkModeEnabled,
          );
        }
      });
    }
  }

  void dispose() {
    settings.dispose();
  }
}