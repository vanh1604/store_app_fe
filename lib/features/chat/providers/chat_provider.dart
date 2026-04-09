import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:vanh_store_app/features/chat/models/chat_message.dart';
import 'package:vanh_store_app/features/chat/services/chat_service.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? errorMessage;
  final String? sessionId;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.errorMessage,
    this.sessionId,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? errorMessage,
    String? sessionId,
    bool clearError = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      sessionId: sessionId ?? this.sessionId,
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  final _service = ChatService();
  final _uuid = const Uuid();

  String _nextId() => _uuid.v4();

  @override
  ChatState build() => const ChatState();

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || state.isLoading) return;

    final userMessageId = _nextId();
    final userMessage = ChatMessage(
      id: userMessageId,
      text: text.trim(),
      role: MessageRole.user,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    // Optimistic: add user bubble immediately
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      clearError: true,
    );

    try {
      final response = await _service.sendMessage(text.trim());

      final deliveredUser = userMessage.copyWith(status: MessageStatus.delivered);
      final assistantMessage = ChatMessage(
        id: _nextId(),
        text: response.message,
        role: MessageRole.assistant,
        products: response.products,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [
          ...state.messages.where((m) => m.id != userMessageId),
          deliveredUser,
          assistantMessage,
        ],
        isLoading: false,
        sessionId: response.sessionId ?? state.sessionId,
      );
    } catch (e) {
      final failedUser = userMessage.copyWith(status: MessageStatus.error);
      state = state.copyWith(
        messages: [
          ...state.messages.where((m) => m.id != userMessageId),
          failedUser,
        ],
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> clearChat() async {
    try {
      await _service.clearSession();
      state = const ChatState();
    } catch (_) {
      state = const ChatState();
    }
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(() {
  return ChatNotifier();
});
