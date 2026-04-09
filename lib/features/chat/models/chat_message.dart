import 'package:vanh_store_app/features/chat/models/chat_product.dart';

enum MessageRole { user, assistant }

enum MessageStatus { sending, delivered, error }

class ChatMessage {
  final String id;
  final String text;
  final MessageRole role;
  final List<ChatProduct> products;
  final DateTime timestamp;
  final MessageStatus status;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.role,
    this.products = const [],
    required this.timestamp,
    this.status = MessageStatus.delivered,
  });

  ChatMessage copyWith({
    String? text,
    MessageStatus? status,
    List<ChatProduct>? products,
  }) {
    return ChatMessage(
      id: id,
      text: text ?? this.text,
      role: role,
      products: products ?? this.products,
      timestamp: timestamp,
      status: status ?? this.status,
    );
  }
}
