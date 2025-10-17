import 'package:flutter/material.dart';
import '../client_flow/controller/chat_controller.dart';
import '../model/chat_model.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatView extends StatelessWidget {
  final String chatName;
  final String avatarUrl;

  ChatView({
    super.key,
    required this.chatName,
    required this.avatarUrl,
  });

  final ChatController _controller = ChatController();
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Busca as mensagens corretas para este chat
    final messages = _controller.getMessagesForChat(chatName);

    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            child: Column(
              children: [                
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(avatarUrl),
                  ),
                  title: Text(
                    chatName,
                    style: GoogleFonts.baloo2(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Online',
                    style: GoogleFonts.baloo2(color: Colors.green),
                  ),
                ),
                const Divider(color: Colors.grey, height: 1),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: message.isSentByMe ? const Color(0xFF844333) : const Color(0xFFd3d3d3),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Text(
          message.text,
          style: GoogleFonts.baloo2(
            color: message.isSentByMe ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Digite uma mensagem...',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24.0), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Color(0xFF844333)),
              onPressed: () {
                // Funcionalidade de envio a ser implementada
              },
            ),
          ],
        ),
      ),
    );
  }
}