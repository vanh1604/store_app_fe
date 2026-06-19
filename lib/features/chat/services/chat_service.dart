import 'dart:convert';
import 'package:vanh_store_app/core/services/api_service.dart';
import 'package:vanh_store_app/features/chat/models/chat_product.dart';

class ChatResponse {
  final String message;
  final List<ChatProduct> products;
  final String? sessionId;

  const ChatResponse({
    required this.message,
    required this.products,
    this.sessionId,
  });
}

class ChatServiceException implements Exception {
  final String message;
  const ChatServiceException(this.message);

  @override
  String toString() => message;
}

class ChatService {
  Future<ChatResponse> sendMessage(String message) async {
    final response = await ApiService.authenticatedRequest(
      method: 'POST',
      endpoint: '/api/chat/message',
      body: {'message': message},
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 429) {
      final body = jsonDecode(response.body);
      throw ChatServiceException(
        body['message'] ?? 'Quá nhiều tin nhắn. Vui lòng thử lại sau.',
      );
    }

    if (response.statusCode != 200) {
      // Lấy message thật từ backend (vd lỗi cấu hình AI / hết quota) thay vì
      // luôn hiện "Lỗi kết nối" chung chung — giúp debug dễ hơn.
      String serverMsg = 'Lỗi kết nối. Vui lòng thử lại.';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['message'] is String) {
          serverMsg = body['message'] as String;
        }
      } catch (_) {}
      throw ChatServiceException(serverMsg);
    }

    final body = jsonDecode(response.body);
    final data = body['data'] as Map<String, dynamic>;
    final productsRaw = data['products'] as List<dynamic>? ?? [];

    return ChatResponse(
      message: data['message'] ?? '',
      products: productsRaw
          .map((p) => ChatProduct.fromMap(p as Map<String, dynamic>))
          .toList(),
      sessionId: data['sessionId'] as String?,
    );
  }

  Future<void> clearSession() async {
    await ApiService.authenticatedRequest(
      method: 'DELETE',
      endpoint: '/api/chat/clear',
    );
  }
}
