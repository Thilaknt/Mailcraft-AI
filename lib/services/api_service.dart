import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/assistant_models.dart';
import '../models/email_models.dart';

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  final String baseUrl;

  static String get defaultBaseUrl {
    if (kIsWeb) return 'http://localhost:8000';
    if (Platform.isAndroid) return 'http://10.57.68.239:8000';
    return 'http://127.0.0.1:8000';
  }

  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? defaultBaseUrl;

  Future<bool> checkHealth() async {
    try {
      final uri = Uri.parse('$baseUrl/api/health');
      final response = await http.get(uri).timeout(const Duration(seconds: 4));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<String> transcribeAudio(File audioFile, {String? language}) async {
    final uri = Uri.parse('$baseUrl/api/assistant/transcribe');
    final reqId = DateTime.now().millisecondsSinceEpoch.toString().substring(7);

    debugPrint('[Voice] Upload started [reqId: $reqId]');
    debugPrint('[Voice] Audio file exists: ${audioFile.existsSync()}');

    if (!audioFile.existsSync()) {
      throw ApiException('Audio file missing or recording failed.');
    }

    final bytes = await audioFile.length();
    debugPrint('[Voice] Audio size: $bytes bytes');

    try {
      final request = http.MultipartRequest('POST', uri);
      request.files.add(
        await http.MultipartFile.fromPath('file', audioFile.path),
      );

      if (language != null && language.isNotEmpty) {
        request.fields['language'] = language;
      }

      debugPrint('[Voice] Transcription request started [reqId: $reqId]');
      final streamedResponse = await request.send().timeout(const Duration(seconds: 45));
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('[Voice] Groq transcription status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final text = data['text']?.toString() ?? '';
        debugPrint('[Voice] Transcription received: "$text"');
        if (text.isEmpty && data.containsKey('error')) {
          throw ApiException(data['error'].toString());
        }
        return text;
      }

      String message = 'Voice transcription failed. Please try again.';
      try {
        final errorBody = json.decode(response.body);
        if (errorBody is Map && errorBody.containsKey('detail')) {
          message = errorBody['detail'].toString();
        }
      } catch (_) {}

      throw ApiException(message);
    } on SocketException {
      throw ApiException('Unable to connect to the AI server.');
    } on TimeoutException {
      throw ApiException('Voice transcription took too long. Please try again.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Voice transcription failed ($e).');
    }
  }

  Future<ChatResponseModel> sendChatMessage(ChatRequestModel request) async {
    final uri = Uri.parse('$baseUrl/api/assistant/chat');
    final reqId = DateTime.now().millisecondsSinceEpoch.toString().substring(7);

    debugPrint('[Flutter chat-$reqId] POST /api/assistant/chat');

    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(request.toJson()),
          )
          .timeout(const Duration(seconds: 45));

      debugPrint('[Flutter chat-$reqId] Response status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        return ChatResponseModel.fromJson(body);
      }

      String message = 'Unable to reach the AI assistant service.';
      try {
        final errorBody = json.decode(response.body);
        if (errorBody is Map && errorBody.containsKey('detail')) {
          message = errorBody['detail'].toString();
        }
      } catch (_) {}

      if (response.statusCode == 401) {
        message = 'AI authentication failed. Check GROQ_API_KEY in backend .env file.';
      } else if (response.statusCode == 429) {
        message = 'AI request limit reached. Please try again in a few moments.';
      } else if (response.statusCode >= 500) {
        message = 'AI server error (HTTP ${response.statusCode}). Check backend logs.';
      }

      throw ApiException(message);
    } on SocketException {
      throw ApiException('AI server is unreachable. Verify FastAPI backend is running on 0.0.0.0:8000.');
    } on TimeoutException {
      throw ApiException('AI request timed out. Please check network connection.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Unable to reach the AI assistant ($e).');
    }
  }

  Future<EmailResponseModel> generateEmail(EmailRequestModel request) async {
    return _postEmail('/api/email/generate', request);
  }

  Future<EmailResponseModel> rewriteEmail(EmailRequestModel request) async {
    return _postEmail('/api/email/rewrite', request);
  }

  Future<EmailResponseModel> fixGrammar(EmailRequestModel request) async {
    return _postEmail('/api/email/grammar', request);
  }

  Future<EmailResponseModel> shortenEmail(EmailRequestModel request) async {
    return _postEmail('/api/email/shorten', request);
  }

  Future<EmailResponseModel> expandEmail(EmailRequestModel request) async {
    return _postEmail('/api/email/expand', request);
  }

  Future<EmailResponseModel> translateEmail(EmailRequestModel request) async {
    return _postEmail('/api/email/translate', request);
  }

  Future<EmailResponseModel> regenerateEmail(EmailRequestModel request) async {
    return _postEmail('/api/email/regenerate', request);
  }

  Future<EmailResponseModel> _postEmail(String path, EmailRequestModel request) async {
    final uri = Uri.parse('$baseUrl$path');
    final reqId = DateTime.now().millisecondsSinceEpoch.toString().substring(7);

    debugPrint('[Flutter req-$reqId] POST $path');
    debugPrint('[Flutter req-$reqId] API URL: $uri');

    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(request.toJson()),
          )
          .timeout(const Duration(seconds: 45));

      debugPrint('[Flutter req-$reqId] Response status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        return EmailResponseModel.fromJson(body);
      }

      String message = 'Unable to reach the AI service.';
      try {
        final errorBody = json.decode(response.body);
        if (errorBody is Map && errorBody.containsKey('detail')) {
          message = errorBody['detail'].toString();
        }
      } catch (_) {}

      if (response.statusCode == 401) {
        if (!message.contains('Groq')) {
          message = 'AI authentication failed. Check GROQ_API_KEY in backend .env file.';
        }
      } else if (response.statusCode == 429) {
        message = 'AI request limit reached. Please try again in a few moments.';
      } else if (response.statusCode >= 500) {
        message = 'AI server error (HTTP ${response.statusCode}). Check backend logs.';
      }

      throw ApiException(message);
    } on SocketException {
      debugPrint('[Flutter req-$reqId] SocketException: Connection refused to $baseUrl');
      throw ApiException('AI server is unreachable. Verify FastAPI is running on 0.0.0.0:8000.');
    } on TimeoutException {
      debugPrint('[Flutter req-$reqId] TimeoutException: Request to $path timed out after 45s');
      throw ApiException('AI request timed out. Please check network connection.');
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('[Flutter req-$reqId] Exception: $e');
      throw ApiException('Unable to reach the AI service ($e).');
    }
  }
}
