import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../view/chat_view.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("Faça login para ver suas mensagens"));
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Mensagens',
                style: GoogleFonts.baloo2(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(color: Colors.grey, height: 1),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('chats')
                    .orderBy('lastUpdated', descending: true) // Ordena por mais recente
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return const Center(child: Text("Erro ao carregar"));
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          "Nenhuma conversa iniciada.",
                          style: GoogleFonts.baloo2(color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final chatDoc = docs[index];
                      final data = chatDoc.data() as Map<String, dynamic>;
                      
                      // Usa os campos salvos na Dupla Escrita
                      // Se 'chatName' não existir, usa o ID do documento como fallback
                      final chatName = data['chatName'] ?? chatDoc.id; 
                      final lastMessage = data['lastMessage'] ?? '';
                      final otherUid = data['otherUid'] ?? chatDoc.id; // Importante para navegar

                      return Column(
                        children: [
                          ListTile(
                            leading: const CircleAvatar(
                              radius: 28,
                              backgroundImage: NetworkImage("https://cdn-icons-png.flaticon.com/512/149/149071.png"),
                            ),
                            title: Text(chatName, style: GoogleFonts.baloo2(fontWeight: FontWeight.bold)),
                            subtitle: Text(lastMessage, style: GoogleFonts.baloo2(), overflow: TextOverflow.ellipsis),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatView(
                                    chatId: otherUid, // Usa o ID correto
                                    title: chatName,
                                    avatarUrl: "https://cdn-icons-png.flaticon.com/512/149/149071.png",
                                  ),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1, indent: 80),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}