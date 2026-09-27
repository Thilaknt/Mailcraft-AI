import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/assistant_models.dart';
import '../../services/voice_service.dart';
import '../../viewmodels/assistant_viewmodel.dart';
import '../../viewmodels/compose_viewmodel.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  late final GroqWhisperVoiceService _voiceService;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<String> _suggestions = [
    'Write an email',
    'Improve my email',
    'Make this shorter',
    'Translate my email',
    'Reply to an email',
    'Explain an email',
  ];

  @override
  void initState() {
    super.initState();
    _voiceService = GroqWhisperVoiceService();
    _voiceService.addListener(_onVoiceStateChanged);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _voiceService.removeListener(_onVoiceStateChanged);
    _voiceService.cancelRecording();
    _voiceService.dispose();
    _pulseController.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onVoiceStateChanged() {
    if (_voiceService.state == VoiceState.error && _voiceService.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_voiceService.errorMessage!),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          action: _voiceService.errorMessage!.contains('permission')
              ? SnackBarAction(
                  label: 'Settings',
                  textColor: Colors.white,
                  onPressed: () => openAppSettings(),
                )
              : null,
        ),
      );
    }
    setState(() {});
  }

  void _handleBack() {
    FocusScope.of(context).unfocus();
    if (_voiceService.isRecording) {
      _voiceService.cancelRecording();
    }

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onSendPressed(AssistantViewModel assistantVm) {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    _inputController.clear();
    assistantVm.sendMessage(text);
    _scrollToBottom();
  }

  void _onSuggestionTap(String text) {
    setState(() {
      _inputController.text = text;
      _inputController.selection = TextSelection.fromPosition(
        TextPosition(offset: text.length),
      );
    });
    _focusNode.requestFocus();
  }

  Future<void> _onVoiceTap() async {
    if (_voiceService.isRecording) {
      final transcribedText = await _voiceService.stopRecordingAndTranscribe();
      if (transcribedText != null && transcribedText.isNotEmpty) {
        setState(() {
          final currentText = _inputController.text;
          _inputController.text = currentText.isEmpty ? transcribedText : '$currentText $transcribedText';
          _inputController.selection = TextSelection.fromPosition(
            TextPosition(offset: _inputController.text.length),
          );
        });
        _focusNode.requestFocus();
      } else if (_voiceService.state == VoiceState.idle && _voiceService.errorMessage == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("I couldn't hear anything. Please try again."),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      await _voiceService.startRecording();
    }
  }

  void _onAttachmentTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Attachment support coming soon.'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _useInGenerator(String subject, String body) {
    final composeVm = Provider.of<ComposeViewModel>(context, listen: false);
    composeVm.updatePurpose(body);
    Navigator.of(context).pushNamed('/generator');
  }

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final assistantVm = Provider.of<AssistantViewModel>(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: _handleBack,
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'MailCraft AI',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'AI Assistant',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            if (!assistantVm.isEmpty)
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textSecondary),
                onPressed: () => assistantVm.clearConversation(),
                tooltip: 'Clear Conversation',
              ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: assistantVm.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: assistantVm.messages.length + (assistantVm.isTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == assistantVm.messages.length && assistantVm.isTyping) {
                            return _buildTypingIndicator();
                          }
                          final msg = assistantVm.messages[index];
                          return _buildMessageBubble(msg, assistantVm);
                        },
                      ),
              ),
              if (_voiceService.isRecording || _voiceService.isTranscribing)
                _buildVoiceStatusBanner(),
              _buildInputArea(assistantVm),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'How can I help?',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ask me to write, rewrite, improve or translate an email.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 10,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _suggestions.map((s) {
              return ActionChip(
                backgroundColor: AppColors.surface,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                avatar: const Icon(Icons.bolt, color: AppColors.primary, size: 16),
                label: Text(
                  s,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
                onPressed: () => _onSuggestionTap(s),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            SizedBox(width: 10),
            Text(
              'MailCraft AI is thinking...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceStatusBanner() {
    final isRec = _voiceService.isRecording;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isRec ? AppColors.error.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isRec) ...[
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Listening... ${_formatDuration(_voiceService.recordingDurationSeconds)}',
              style: const TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ] else ...[
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Transcribing...',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel message, AssistantViewModel assistantVm) {
    final isUser = message.sender == MessageSender.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.surface,
          gradient: isUser ? AppColors.brandGradient : null,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: Border.all(
            color: isUser ? Colors.transparent : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.isEmail && message.subject != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.subject, color: AppColors.primary, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        message.subject!,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            Text(
              message.isEmail && message.body != null ? message.body! : message.text,
              style: TextStyle(
                color: isUser ? Colors.white : AppColors.textPrimary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            if (!isUser && message.isEmail && message.body != null) ...[
              const SizedBox(height: 12),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildActionButton(
                    icon: Icons.copy_rounded,
                    label: 'Copy',
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: '${message.subject ?? ""}\n\n${message.body ?? ""}'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard'), behavior: SnackBarBehavior.floating),
                      );
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.auto_awesome,
                    label: 'Shorten',
                    onTap: () => assistantVm.sendMessage('Make this shorter'),
                  ),
                  _buildActionButton(
                    icon: Icons.g_translate_rounded,
                    label: 'Translate',
                    onTap: () => assistantVm.sendMessage('Translate this to Hindi'),
                  ),
                  _buildActionButton(
                    icon: Icons.open_in_new_rounded,
                    label: 'Use in Generator',
                    onTap: () => _useInGenerator(message.subject ?? '', message.body ?? ''),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(AssistantViewModel assistantVm) {
    final isRecording = _voiceService.isRecording;
    final isTranscribing = _voiceService.isTranscribing;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.textSecondary),
            onPressed: _onAttachmentTap,
          ),
          Expanded(
            child: TextField(
              controller: _inputController,
              focusNode: _focusNode,
              maxLines: 4,
              minLines: 1,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Type your message...',
                hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          IconButton(
            icon: isRecording
                ? ScaleTransition(
                    scale: _pulseAnimation,
                    child: const Icon(Icons.stop_circle_rounded, color: AppColors.error),
                  )
                : (isTranscribing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)),
                      )
                    : const Icon(Icons.mic_none_rounded, color: AppColors.textSecondary)),
            onPressed: isTranscribing ? null : _onVoiceTap,
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _inputController,
            builder: (context, value, child) {
              final canSend = value.text.trim().isNotEmpty && !assistantVm.isTyping;
              return Container(
                decoration: BoxDecoration(
                  gradient: canSend ? AppColors.brandGradient : null,
                  color: canSend ? null : AppColors.border,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.send_rounded, size: 18),
                  color: canSend ? Colors.white : AppColors.textSecondary,
                  onPressed: canSend ? () => _onSendPressed(assistantVm) : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
