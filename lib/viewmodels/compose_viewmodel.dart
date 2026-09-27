import 'package:flutter/material.dart';

import '../models/email_models.dart';

class ComposeViewModel extends ChangeNotifier {
  static const List<String> recipientTypes = [
    'Friend',
    'Professor',
    'HR Manager',
    'Client',
    'Teacher',
    'Manager',
    'Team Lead',
    'Colleague',
    'Classmate',
    'Customer',
    'Recruiter',
    'Hiring Manager',
    'Mentor',
    'Family Member',
    'Business Partner',
    'Vendor',
    'Government Official',
    'Doctor',
    'Other',
  ];

  static const List<String> tones = [
    'Professional',
    'Friendly',
    'Formal',
    'Casual',
    'Persuasive',
    'Apologetic',
    'Appreciative',
    'Assertive',
    'Warm',
    'Concise',
    'Confident',
    'Empathetic',
    'Enthusiastic',
    'Polite',
    'Urgent',
  ];

  static const List<String> languages = [
    'English',
    'Hindi',
    'Kannada',
    'Tamil',
    'Telugu',
    'Malayalam',
    'Marathi',
    'Bengali',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Portuguese',
    'Japanese',
    'Chinese',
    'Arabic',
  ];

  String senderName = '';
  String senderRole = '';
  String recipientType = 'Friend';
  String recipientName = '';
  String purpose = '';
  String tone = 'Professional';
  String language = 'English';
  String additionalContext = '';

  bool get isValid =>
      senderName.trim().isNotEmpty &&
      recipientType.trim().isNotEmpty &&
      purpose.trim().isNotEmpty;

  void updateSenderName(String value) {
    senderName = value;
    notifyListeners();
  }

  void updateSenderRole(String value) {
    senderRole = value;
    notifyListeners();
  }

  void updateRecipientType(String value) {
    recipientType = value;
    notifyListeners();
  }

  void updateRecipientName(String value) {
    recipientName = value;
    notifyListeners();
  }

  void updatePurpose(String value) {
    purpose = value;
    notifyListeners();
  }

  void updateTone(String value) {
    tone = value;
    notifyListeners();
  }

  void updateLanguage(String value) {
    language = value;
    notifyListeners();
  }

  void updateAdditionalContext(String value) {
    additionalContext = value;
    notifyListeners();
  }

  void populateTemplate({
    required String targetPurpose,
    String? targetRecipientType,
    String? targetTone,
    String? targetLanguage,
    String? targetSenderName,
    String? targetSenderRole,
  }) {
    purpose = targetPurpose;
    if (targetRecipientType != null && recipientTypes.contains(targetRecipientType)) {
      recipientType = targetRecipientType;
    }
    if (targetTone != null && tones.contains(targetTone)) {
      tone = targetTone;
    }
    if (targetLanguage != null && languages.contains(targetLanguage)) {
      language = targetLanguage;
    }
    if (targetSenderName != null) {
      senderName = targetSenderName;
    }
    if (targetSenderRole != null) {
      senderRole = targetSenderRole;
    }
    notifyListeners();
  }

  EmailRequestModel buildRequest({String? sourceEmail}) {
    return EmailRequestModel(
      senderName: senderName.trim(),
      senderRole: senderRole.trim(),
      recipientType: recipientType,
      recipientName: recipientName.trim(),
      purpose: purpose.trim(),
      tone: tone,
      language: language,
      additionalContext: additionalContext.trim(),
      sourceEmail: sourceEmail,
    );
  }

  void reset() {
    senderName = '';
    senderRole = '';
    recipientType = 'Friend';
    recipientName = '';
    purpose = '';
    tone = 'Professional';
    language = 'English';
    additionalContext = '';
    notifyListeners();
  }
}
