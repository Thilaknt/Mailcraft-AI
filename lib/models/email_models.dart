class EmailRequestModel {
  final String senderName;
  final String senderRole;
  final String recipientType;
  final String recipientName;
  final String purpose;
  final String tone;
  final String language;
  final String additionalContext;
  final String? sourceEmail;

  EmailRequestModel({
    required this.senderName,
    this.senderRole = '',
    required this.recipientType,
    this.recipientName = '',
    required this.purpose,
    required this.tone,
    required this.language,
    this.additionalContext = '',
    this.sourceEmail,
  });

  Map<String, dynamic> toJson() {
    return {
      'sender_name': senderName,
      'sender_role': senderRole,
      'recipient_type': recipientType,
      'recipient_name': recipientName,
      'purpose': purpose,
      'tone': tone,
      'language': language,
      'additional_context': additionalContext,
      'source_email': sourceEmail,
    };
  }
}

class EmailResponseModel {
  final String subject;
  final String body;
  final int qualityScore;
  final int wordCount;
  final int characterCount;
  final int readingTimeSeconds;

  EmailResponseModel({
    required this.subject,
    required this.body,
    required this.qualityScore,
    required this.wordCount,
    required this.characterCount,
    required this.readingTimeSeconds,
  });

  factory EmailResponseModel.fromJson(Map<String, dynamic> json) {
    final bodyText = json['body'] as String? ?? '';
    final calculatedWords = bodyText.trim().isEmpty
        ? 0
        : bodyText.trim().split(RegExp(r'\s+')).length;
    final calculatedChars = bodyText.length;
    final calculatedReadSecs = calculatedWords > 0
        ? (calculatedWords / 200 * 60).round().clamp(5, 3600)
        : 5;

    return EmailResponseModel(
      subject: json['subject'] as String? ?? '',
      body: bodyText,
      qualityScore: json['quality_score'] is int
          ? json['quality_score'] as int
          : int.tryParse('${json['quality_score']}') ?? 92,
      wordCount: json['word_count'] is int
          ? json['word_count'] as int
          : calculatedWords,
      characterCount: json['character_count'] is int
          ? json['character_count'] as int
          : calculatedChars,
      readingTimeSeconds: json['reading_time_seconds'] is int
          ? json['reading_time_seconds'] as int
          : calculatedReadSecs,
    );
  }
}
