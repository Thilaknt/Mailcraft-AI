import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import 'api_service.dart';

enum VoiceState {
  idle,
  requestingPermission,
  recording,
  stopping,
  transcribing,
  error,
}

abstract class SpeechToTextService {
  Future<bool> initialize();
  Future<void> startListening({required Function(String text) onResult});
  Future<void> stopListening();
  bool get isListening;
}

abstract class TextToSpeechService {
  Future<bool> initialize();
  Future<void> speak(String text, {String? language});
  Future<void> stop();
  bool get isSpeaking;
}

class GroqWhisperVoiceService extends ChangeNotifier {
  final ApiService _apiService;
  final AudioRecorder _recorder = AudioRecorder();

  VoiceState _state = VoiceState.idle;
  String? _currentAudioPath;
  String? _errorMessage;
  int _recordingDurationSeconds = 0;
  Timer? _timer;

  VoiceState get state => _state;
  String? get errorMessage => _errorMessage;
  int get recordingDurationSeconds => _recordingDurationSeconds;
  bool get isRecording => _state == VoiceState.recording;
  bool get isTranscribing => _state == VoiceState.transcribing;

  GroqWhisperVoiceService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<bool> checkAndRequestPermission() async {
    _state = VoiceState.requestingPermission;
    notifyListeners();

    debugPrint('[Voice] Checking microphone permission...');
    final hasPermission = await _recorder.hasPermission();

    if (hasPermission) {
      debugPrint('[Voice] Microphone permission: granted');
      _state = VoiceState.idle;
      notifyListeners();
      return true;
    }

    final status = await Permission.microphone.request();
    if (status.isGranted) {
      debugPrint('[Voice] Microphone permission: granted after request');
      _state = VoiceState.idle;
      notifyListeners();
      return true;
    }

    debugPrint('[Voice] Microphone permission: denied');
    _errorMessage = 'Microphone permission is required for voice input.';
    _state = VoiceState.error;
    notifyListeners();
    return false;
  }

  Future<void> startRecording() async {
    final hasPermission = await checkAndRequestPermission();
    if (!hasPermission) return;

    try {
      final tempDir = await getTemporaryDirectory();
      final filename = 'voice_rec_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final path = '${tempDir.path}/$filename';

      _currentAudioPath = path;
      _errorMessage = null;
      _recordingDurationSeconds = 0;

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      debugPrint('[Voice] Audio recording started at $path');
      _state = VoiceState.recording;
      _startTimer();
      notifyListeners();
    } catch (e) {
      debugPrint('[Voice] Recording failed to start: $e');
      _errorMessage = 'Microphone unavailable or recording failed.';
      _state = VoiceState.error;
      notifyListeners();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recordingDurationSeconds++;
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<String?> stopRecordingAndTranscribe({String? language}) async {
    if (_state != VoiceState.recording) return null;

    _stopTimer();
    _state = VoiceState.stopping;
    notifyListeners();

    try {
      final path = await _recorder.stop();
      debugPrint('[Voice] Audio recording stopped');

      final finalPath = path ?? _currentAudioPath;
      if (finalPath == null) {
        throw ApiException('Audio file missing or recording failed.');
      }

      final file = File(finalPath);
      final exists = await file.exists();
      debugPrint('[Voice] Audio file exists: $exists');

      if (!exists) {
        throw ApiException('Audio file missing or recording failed.');
      }

      _state = VoiceState.transcribing;
      notifyListeners();

      final transcribedText = await _apiService.transcribeAudio(file, language: language);

      // Safe cleanup of temp audio file
      try {
        if (await file.exists()) {
          await file.delete();
          debugPrint('[Voice] Temp audio file cleaned up safely');
        }
      } catch (_) {}

      _state = VoiceState.idle;
      notifyListeners();

      return transcribedText;
    } catch (e) {
      debugPrint('[Voice] Transcription error: $e');
      _errorMessage = e is ApiException ? e.message : 'Voice transcription failed. Please try again.';
      _state = VoiceState.error;
      notifyListeners();
      return null;
    }
  }

  Future<void> cancelRecording() async {
    _stopTimer();
    try {
      if (await _recorder.isRecording()) {
        final path = await _recorder.stop();
        if (path != null) {
          final file = File(path);
          if (await file.exists()) {
            await file.delete();
          }
        }
      }
    } catch (_) {}
    _state = VoiceState.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimer();
    _recorder.dispose();
    super.dispose();
  }
}

class PlaceholderSpeechToTextService implements SpeechToTextService {
  bool _listening = false;

  @override
  Future<bool> initialize() async => true;

  @override
  Future<void> startListening({required Function(String text) onResult}) async {
    _listening = true;
  }

  @override
  Future<void> stopListening() async {
    _listening = false;
  }

  @override
  bool get isListening => _listening;
}

class PlaceholderTextToSpeechService implements TextToSpeechService {
  bool _speaking = false;

  @override
  Future<bool> initialize() async => true;

  @override
  Future<void> speak(String text, {String? language}) async {
    _speaking = true;
  }

  @override
  Future<void> stop() async {
    _speaking = false;
  }

  @override
  bool get isSpeaking => _speaking;
}
