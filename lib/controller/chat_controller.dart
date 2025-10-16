import '../model/chat_model.dart';

class ChatController {
  final List<ChatMessage> mockMessages = [
    ChatMessage(text: "Olá! Gostaria de agendar um horário.", isSentByMe: false),
    ChatMessage(text: "Claro! Para quando você gostaria?", isSentByMe: true),
    ChatMessage(text: "Pode ser para sábado, às 10h?", isSentByMe: false),
    ChatMessage(text: "Sábado às 10h está disponível. Confirmado!", isSentByMe: true),
  ];
}