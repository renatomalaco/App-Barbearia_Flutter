import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../view/chat_view.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    // Dados de exemplo para a lista de chats
    final List<Map<String, String>> chatList = [
      {
        "name": "Jhon Cortes Clássicos",
        "lastMessage": "Sábado às 10h está disponível. Confirmado!",
        "time": "10:45",
        "avatarUrl": "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1000&auto=format&fit=crop",
      },
      {
        "name": "Barbearia Old School",
        "lastMessage": "Perfeito! Te aguardo.",
        "time": "Ontem",
        "avatarUrl": "https://images.unsplash.com/photo-1585747860715-2ba37e788b70?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8YmFyYmVyc2hvcHxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&q=60&w=600",
      },
      {
        "name": "Classic Cuts",
        "lastMessage": "Você: Podemos remarcar?",
        "time": "2d atrás",
        "avatarUrl": "https://images.unsplash.com/photo-1693755807658-17ce5331aacb?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fGJhcmJlcnNob3B8ZW58MHwwfDB8fHww&auto=format&fit=crop&q=60&w=600",
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Mensagens',
                style: GoogleFonts.baloo2(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(color: Colors.grey, height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: chatList.length,
                itemBuilder: (context, index) {
                  final chat = chatList[index];
                  return Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundImage: NetworkImage(chat['avatarUrl']!),
                        ),
                        title: Text(
                          chat['name']!,
                          style: GoogleFonts.baloo2(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          chat['lastMessage']!,
                          style: GoogleFonts.baloo2(),
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          chat['time']!,
                          style: GoogleFonts.baloo2(fontSize: 12, color: Colors.grey),
                        ),
                        onTap: () {
                          // Navega para a tela de conversa individual
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatView(
                                chatName: chat['name']!,
                                avatarUrl: chat['avatarUrl']!,
                              ),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 80),
                    ],
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