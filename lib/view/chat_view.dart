import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatView extends StatefulWidget {
  final String chatId; // ID do Outro Usuário
  final String title;
  final String avatarUrl;
  final bool isBarberView; // Define quem está enviando

  const ChatView({
    super.key,
    required this.chatId,
    required this.title,
    required this.avatarUrl,
    this.isBarberView = false, // Padrão false (Cliente)
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _textController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();

    final user = _auth.currentUser;
    if (user != null) {
      final timestamp = FieldValue.serverTimestamp();
      
      // LÓGICA DE IDENTIFICAÇÃO
      // Se sou Cliente (false): clientUid sou Eu, barberUid é o ChatId
      // Se sou Barbeiro (true): clientUid é o ChatId, barberUid sou Eu
      final String clientUid = widget.isBarberView ? widget.chatId : user.uid;
      final String barberUid = widget.isBarberView ? user.uid : widget.chatId;
      
      final messageData = {
        'text': text,
        'senderId': user.uid,
        'timestamp': timestamp,
      };

      try {
        // 1. Grava na caixa do CLIENTE
        final clientRef = _firestore.collection('users').doc(clientUid).collection('chats').doc(barberUid);
        await clientRef.collection('messages').add(messageData);
        await clientRef.set({
          'lastMessage': text,
          'lastUpdated': timestamp,
          'chatName': widget.isBarberView ? 'Barbearia' : widget.title,
          'otherUid': barberUid, // ID para o cliente navegar
        }, SetOptions(merge: true));

        // 2. Grava na caixa do BARBEIRO (Isso faz a mensagem aparecer para o Kleber)
        final barberRef = _firestore.collection('barbershops').doc(barberUid).collection('chats').doc(clientUid);
        await barberRef.collection('messages').add(messageData);
        await barberRef.set({
          'lastMessage': text,
          'lastUpdated': timestamp,
          'clientName': widget.isBarberView ? widget.title : (user.displayName ?? 'Cliente'),
          'clientUid': clientUid, // ID para o barbeiro navegar
        }, SetOptions(merge: true));

      } catch (e) {
        print("Erro: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) return const SizedBox();

    // Define qual coleção ler para montar a tela
    Query query;
    if (widget.isBarberView) {
      // Barbeiro lê da sua caixa
      query = _firestore.collection('barbershops').doc(user.uid).collection('chats').doc(widget.chatId).collection('messages');
    } else {
      // Cliente lê da sua caixa
      query = _firestore.collection('users').doc(user.uid).collection('chats').doc(widget.chatId).collection('messages');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: GoogleFonts.baloo2(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.orderBy('timestamp', descending: false).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                
                if (docs.isEmpty) return Center(child: Text("Sem mensagens", style: GoogleFonts.baloo2(color: Colors.grey)));

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == user.uid;
                    return _buildMessageBubble(data['text'], isMe);
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
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF844333) : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text, style: GoogleFonts.baloo2(color: isMe ? Colors.white : Colors.black)),
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Digite...',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFF844333),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}