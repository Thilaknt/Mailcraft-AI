import 'dart:convert';

import 'email_models.dart';

class HistoryItem {
  final String id;
  final String senderName;
  final String senderRole;
  final String subject;
  final String recipientType;
  final String recipientName;
  final String purpose;
  final String tone;
  final String language;
  final String body;
  final bool isFavorite;
  final DateTime createdAt;

  HistoryItem({
    required this.id,
    this.senderName = '',
    this.senderRole = '',
    required this.subject,
    required this.recipientType,
    this.recipientName = '',
    required this.purpose,
    required this.tone,
    required this.language,
    required this.body,
    this.isFavorite = false,
    required this.createdAt,
  });

  factory HistoryItem.fromRequestResponse(
    EmailRequestModel request,
    EmailResponseModel response,
  ) {
    return HistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderName: request.senderName,
      senderRole: request.senderRole,
      subject: response.subject,
      recipientType: request.recipientType,
      recipientName: request.recipientName,
      purpose: request.purpose,
      tone: request.tone,
      language: request.language,
      body: response.body,
      isFavorite: false,
      createdAt: DateTime.now(),
    );
  }

  HistoryItem copyWith({
    String? id,
    String? senderName,
    String? senderRole,
    String? subject,
    String? recipientType,
    String? recipientName,
    String? purpose,
    String? tone,
    String? language,
    String? body,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return HistoryItem(
      id: id ?? this.id,
      senderName: senderName ?? this.senderName,
      senderRole: senderRole ?? this.senderRole,
      subject: subject ?? this.subject,
      recipientType: recipientType ?? this.recipientType,
      recipientName: recipientName ?? this.recipientName,
      purpose: purpose ?? this.purpose,
      tone: tone ?? this.tone,
      language: language ?? this.language,
      body: body ?? this.body,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_name': senderName,
      'sender_role': senderRole,
      'subject': subject,
      'recipient_type': recipientType,
      'recipient_name': recipientName,
      'purpose': purpose,
      'tone': tone,
      'language': language,
      'body': body,
      'is_favorite': isFavorite,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] as String,
      senderName: json['sender_name'] as String? ?? '',
      senderRole: json['sender_role'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      recipientType: json['recipient_type'] as String? ?? '',
      recipientName: json['recipient_name'] as String? ?? '',
      purpose: json['purpose'] as String? ?? '',
      tone: json['tone'] as String? ?? '',
      language: json['language'] as String? ?? '',
      body: json['body'] as String? ?? '',
      isFavorite: json['is_favorite'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  String toEncodedJson() => json.encode(toJson());

  static HistoryItem fromEncodedJson(String encoded) =>
      HistoryItem.fromJson(json.decode(encoded) as Map<String, dynamic>);
}
