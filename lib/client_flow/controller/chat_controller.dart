import '../../model/chat_model.dart';

class ChatController {
  // Mapeia o nome do chat para sua lista de mensagens
  final Map<String, List<ChatMessage>> _mockConversations = {
    "Jhon Cortes Clássicos": [
      ChatMessage(text: "Olá! Gostaria de agendar um horário.", isSentByMe: false),
      ChatMessage(text: "Claro! Para quando você gostaria?", isSentByMe: true),
      ChatMessage(text: "Pode ser para sábado, às 10h?", isSentByMe: false),
      ChatMessage(text: "Sábado às 10h está disponível. Confirmado!", isSentByMe: true),
    ],
    "Barbearia Old School": [
      ChatMessage(text: "Boa tarde, vocês têm horário para hoje?", isSentByMe: true),
      ChatMessage(text: "Boa tarde! Temos sim, às 18:00. Pode ser?", isSentByMe: false),
      ChatMessage(text: "Perfeito! Te aguardo.", isSentByMe: false),
    ],
    "Classic Cuts": [
      ChatMessage(text: "Olá, gostaria de saber o preço do corte + barba.", isSentByMe: true),
      ChatMessage(text: "Olá! O combo sai por R\$ 80,00.", isSentByMe: false),
      ChatMessage(text: "Você: Podemos remarcar?", isSentByMe: true),
    ],
  };

  // Método para obter as mensagens de um chat específico
  List<ChatMessage> getMessagesForChat(String chatName) {
    // Retorna a lista de mensagens ou uma lista vazia se o chat não for encontrado
    return _mockConversations[chatName] ?? [];
  }
}