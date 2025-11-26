import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatView extends StatefulWidget {
  final String chatId; // ID do Destinatário (Barbeiro ou Cliente)
  final String title;  // Nome do Destinatário (Para o título da tela)
  final String avatarUrl;
  final bool isBarberView; // Define se quem está usando é o Barbeiro

  const ChatView({
    super.key,
    required this.chatId,
    required this.title,
    required this.avatarUrl,
    this.isBarberView = false,
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
      
      // Identifica os IDs corretos
      final String clientUid = widget.isBarberView ? widget.chatId : user.uid;
      final String barberUid = widget.isBarberView ? user.uid : widget.chatId;

      try {
        // 1. BUSCA O NOME DO REMETENTE NO BANCO PARA NÃO FICAR GENÉRICO
        // Se eu sou o cliente (Renato), busco meu nome na coleção 'users'
        // Se eu sou o barbeiro (Kleber), busco na 'barbershops'
        String senderName = user.displayName ?? 'Usuário';
        
        final userDoc = await _firestore
            .collection(widget.isBarberView ? 'barbershops' : 'users')
            .doc(user.uid)
            .get();
            
        if (userDoc.exists) {
          senderName = userDoc.data()?['name'] ?? senderName;
        }

        // Dados da mensagem
        final messageData = {
          'text': text,
          'senderId': user.uid,
          'senderName': senderName, // Agora envia "Renato" corretamente
          'timestamp': timestamp,
        };

        // --- GRAVAÇÃO DUPLA (Para aparecer nos dois celulares) ---

        // 1. Caixa do Cliente (Para Renato ver o histórico)
        final clientChatRef = _firestore
            .collection('users')
            .doc(clientUid)
            .collection('chats')
            .doc(barberUid);

        await clientChatRef.collection('messages').add(messageData);
        await clientChatRef.set({
          'lastMessage': text,
          'lastUpdated': timestamp,
          'chatName': widget.isBarberView ? 'Barbearia (Você)' : widget.title, 
          'otherUid': barberUid,
        }, SetOptions(merge: true));

        // 2. Caixa do Barbeiro (Para Kleber receber a mensagem)
        final barberChatRef = _firestore
            .collection('barbershops')
            .doc(barberUid)
            .collection('chats')
            .doc(clientUid);

        await barberChatRef.collection('messages').add(messageData);
        await barberChatRef.set({
          'lastMessage': text,
          'lastUpdated': timestamp,
          'clientName': widget.isBarberView ? widget.title : senderName, // Garante que Kleber veja "Renato"
          'clientUid': clientUid,
        }, SetOptions(merge: true));

      } catch (e) {
        print("Erro ao enviar: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) return const SizedBox();

    // Define de onde ler as mensagens
    Query query;
    if (widget.isBarberView) {
      // Barbeiro lendo sua própria caixa
      query = _firestore.collection('barbershops').doc(user.uid).collection('chats').doc(widget.chatId).collection('messages');
    } else {
      // Cliente lendo sua própria caixa
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
                
                if (docs.isEmpty) return Center(child: Text("Diga olá para ${widget.title}!", style: GoogleFonts.baloo2(color: Colors.grey)));

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == user.uid;
                    return _buildMessageBubble(data['text'] ?? '', isMe);
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
                hintText: 'Digite uma mensagem...',
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