import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatView extends StatefulWidget {
  final String chatName; // Nome do Barbeiro/Chat
  final String avatarUrl;

  const ChatView({
    super.key,
    required this.chatName,
    required this.avatarUrl,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _textController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Função para enviar mensagem (RF003)
  void _sendMessage() async {
    if (_textController.text.trim().isEmpty) return;

    final user = _auth.currentUser;
    if (user != null) {
      final chatRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('chats')
          .doc(widget.chatName);

      // 1. Adiciona a mensagem na subcoleção
      await chatRef.collection('messages').add({
        'text': _textController.text.trim(),
        'senderId': user.uid,
        'senderName': 'Eu',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 2. Atualiza o documento do chat com a última mensagem (para aparecer na lista)
      await chatRef.set({
        'lastMessage': _textController.text.trim(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'barberName': widget.chatName, // Garante que o campo existe
      }, SetOptions(merge: true)); // Merge para não apagar outros dados se existirem

      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(widget.avatarUrl)),
            const SizedBox(width: 10),
            Text(widget.chatName, style: GoogleFonts.baloo2(color: Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            // StreamBuilder para ler as mensagens (RF005)
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(user!.uid)
                  .collection('chats')
                  .doc(widget.chatName)
                  .collection('messages')
                  .orderBy('timestamp', descending: false) // Ordem cronológica
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msgData = messages[index].data() as Map<String, dynamic>;
                    final isMe = msgData['senderId'] == user.uid;

                    return _buildMessageBubble(
                      msgData['text'] ?? '',
                      isMe,
                    );
                  },
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF844333) : Colors.grey[300],
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Text(
          text,
          style: GoogleFonts.baloo2(
            color: isMe ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8.0),
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Color(0xFF844333)),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}