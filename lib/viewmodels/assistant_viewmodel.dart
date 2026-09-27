import 'package:flutter/foundation.dart';

import '../models/assistant_models.dart';
import '../services/api_service.dart';

class AssistantViewModel extends ChangeNotifier {
  final ApiService _apiService;

  final List<ChatMessageModel> _messages = [];
  bool _isTyping = false;
  String? _conversationId;
  String? _errorMessage;

  List<ChatMessageModel> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;
  bool get isEmpty => _messages.isEmpty;
  String? get errorMessage => _errorMessage;

  AssistantViewModel({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  void clearConversation() {
    _messages.clear();
    _conversationId = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    final query = text.trim();
    if (query.isEmpty || _isTyping) return;

    _errorMessage = null;

    final userMessage = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: MessageSender.user,
      text: query,
    );

    _messages.add(userMessage);
    _isTyping = true;
    notifyListeners();

    try {
      final historyPayload = _messages.map((m) => m.toHistoryJson()).toList();

      final request = ChatRequestModel(
        message: query,
        conversationId: _conversationId,
        messages: historyPayload,
      );

      final response = await _apiService.sendChatMessage(request);
      _conversationId = response.conversationId;

      final assistantMessage = ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: MessageSender.assistant,
        text: response.message,
        subject: response.subject,
        body: response.body,
        type: response.type,
      );

      _messages.add(assistantMessage);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('ApiException: ', '');
      _messages.add(
        ChatMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sender: MessageSender.assistant,
          text: 'Error: $_errorMessage',
        ),
      );
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }
}
