enum MessageSender { user, assistant }

class ChatMessageModel {
  final String id;
  final MessageSender sender;
  final String text;
  final String? subject;
  final String? body;
  final DateTime timestamp;
  final String type;

  ChatMessageModel({
    required this.id,
    required this.sender,
    required this.text,
    this.subject,
    this.body,
    DateTime? timestamp,
    this.type = 'text',
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isEmail => type == 'email' || (subject != null && body != null);

  Map<String, dynamic> toHistoryJson() {
    return {
      'role': sender == MessageSender.user ? 'user' : 'assistant',
      'content': isEmail ? 'Subject: ${subject ?? ""}\n\n${body ?? text}' : text,
    };
  }
}

class ChatRequestModel {
  final String message;
  final String? conversationId;
  final List<Map<String, dynamic>> messages;

  ChatRequestModel({
    required this.message,
    this.conversationId,
    required this.messages,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      if (conversationId != null) 'conversation_id': conversationId,
      'messages': messages,
    };
  }
}

class ChatResponseModel {
  final String message;
  final String type;
  final String? subject;
  final String? body;
  final String conversationId;

  ChatResponseModel({
    required this.message,
    required this.type,
    this.subject,
    this.body,
    required this.conversationId,
  });

  factory ChatResponseModel.fromJson(Map<String, dynamic> json) {
    return ChatResponseModel(
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? 'text',
      subject: json['subject']?.toString(),
      body: json['body']?.toString(),
      conversationId: json['conversation_id']?.toString() ?? '',
    );
  }
}
