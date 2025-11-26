import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../view/chat_view.dart'; 

class BarberChatListView extends StatelessWidget {
  const BarberChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mensagens', style: GoogleFonts.baloo2(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false, // Remove seta de voltar se estiver na tab bar
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('barbershops')
            .doc(user!.uid)
            .collection('chats')
            .orderBy('lastUpdated', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Nenhum cliente enviou mensagem ainda.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.baloo2(color: Colors.grey),
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final clientName = data['clientName'] ?? 'Cliente';
              // O ID do documento na coleção 'chats' do barbeiro É o UID do cliente
              final clientId = docs[index].id; 

              return Column(
                children: [
                  ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(clientName, style: GoogleFonts.baloo2(fontWeight: FontWeight.bold)),
                    subtitle: Text(data['lastMessage'] ?? '', style: GoogleFonts.baloo2(), maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatView(
                            chatId: clientId, // Passa o ID do cliente
                            title: clientName,
                            avatarUrl: "https://cdn-icons-png.flaticon.com/512/149/149071.png",
                            isBarberView: true, // [IMPORTANTE] Barbeiro respondendo
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                ],
              );
            },
          );
        },
      ),
    );
  }
}