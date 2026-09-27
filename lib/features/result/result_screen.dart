import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/email_models.dart';
import '../../models/history_item.dart';
import '../../services/api_service.dart';
import '../../viewmodels/history_viewmodel.dart';

class ResultScreen extends StatefulWidget {
  final EmailResponseModel response;
  final EmailRequestModel request;

  const ResultScreen({
    super.key,
    required this.response,
    required this.request,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final ApiService _apiService = ApiService();

  late TextEditingController _subjectController;
  late TextEditingController _bodyController;

  late int _qualityScore;
  late String _language;

  bool _isCopySuccess = false;
  bool _isActionLoading = false;
  String? _loadingActionName;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(text: widget.response.subject);
    _bodyController = TextEditingController(text: widget.response.body);
    _qualityScore = widget.response.qualityScore;
    _language = widget.request.language;
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _copyBody() async {
    await Clipboard.setData(ClipboardData(text: _bodyController.text));
    setState(() {
      _isCopySuccess = true;
      _statusMessage = 'Email body copied to clipboard!';
    });
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isCopySuccess = false;
        _statusMessage = null;
      });
    }
  }

  Future<void> _runRefinementAction(
    String actionName,
    Future<EmailResponseModel> Function(EmailRequestModel req) apiCall,
  ) async {
    if (_isActionLoading) return;

    setState(() {
      _isActionLoading = true;
      _loadingActionName = actionName;
      _statusMessage = null;
    });

    try {
      final req = EmailRequestModel(
        senderName: widget.request.senderName,
        senderRole: widget.request.senderRole,
        recipientType: widget.request.recipientType,
        recipientName: widget.request.recipientName,
        purpose: widget.request.purpose,
        tone: widget.request.tone,
        language: widget.request.language,
        additionalContext: widget.request.additionalContext,
        sourceEmail: _bodyController.text,
      );

      final newResponse = await apiCall(req);

      if (!mounted) return;

      setState(() {
        _subjectController.text = newResponse.subject;
        _bodyController.text = newResponse.body;
        _qualityScore = newResponse.qualityScore;
        _statusMessage = '$actionName applied successfully!';
      });

      // Save refined version to history
      final historyVm = Provider.of<HistoryViewModel>(context, listen: false);
      await historyVm.addHistoryItem(
        HistoryItem.fromRequestResponse(req, newResponse),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = e.toString().replaceAll('ApiException: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isActionLoading = false;
          _loadingActionName = null;
        });
      }
    }
  }

  int get _wordCount => _bodyController.text.trim().isEmpty
      ? 0
      : _bodyController.text.trim().split(RegExp(r'\s+')).length;

  int get _charCount => _bodyController.text.length;

  String get _readingTimeFormatted {
    final secs = _wordCount > 0 ? (_wordCount / 200 * 60).round() : 0;
    if (secs < 60) return '${secs}s';
    return '${(secs / 60).ceil()}m';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crafted Email Result'),
        actions: [
          IconButton(
            icon: Icon(
              _isCopySuccess ? Icons.check_circle_rounded : Icons.copy_rounded,
              color: _isCopySuccess ? AppColors.success : null,
            ),
            tooltip: 'Copy Email',
            onPressed: _copyBody,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // AI Quality Score Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI Quality Score', style: AppTypography.caption(secondaryText)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('$_qualityScore', style: AppTypography.headlineLarge(AppColors.primary)),
                          Text('/100', style: AppTypography.bodyMedium(secondaryText)),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_rounded, size: 16, color: AppColors.success),
                        const SizedBox(width: 6),
                        Text(
                          _qualityScore >= 90 ? 'Excellent' : 'Polished',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Main Content Card (Subject & Editable Email Body)
            Card(
              elevation: 0,
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SUBJECT', style: AppTypography.caption(secondaryText)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _subjectController,
                      style: AppTypography.headlineMedium(primaryText),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text('BODY (EDITABLE)', style: AppTypography.caption(secondaryText)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _bodyController,
                      maxLines: null,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: primaryText,
                        fontFamily: 'Inter',
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 18),
                    const Divider(),
                    const SizedBox(height: 12),
                    // Stats Row (Words, Chars, Read Time, Language)
                    Row(
                      children: [
                        _buildInfoChip('Words', '$_wordCount'),
                        const SizedBox(width: 8),
                        _buildInfoChip('Chars', '$_charCount'),
                        const SizedBox(width: 8),
                        _buildInfoChip('Read Time', _readingTimeFormatted),
                        const SizedBox(width: 8),
                        _buildInfoChip('Lang', _language),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Status message
            if (_statusMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _statusMessage!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: primaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 16),

            Text('REFINEMENT ACTIONS', style: AppTypography.caption(secondaryText)),
            const SizedBox(height: 10),

            // Actions Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.2,
              children: [
                _buildActionCard(
                  title: 'Shorten',
                  icon: Icons.compress_rounded,
                  isLoading: _isActionLoading && _loadingActionName == 'Shorten',
                  onTap: () => _runRefinementAction('Shorten', _apiService.shortenEmail),
                ),
                _buildActionCard(
                  title: 'Expand',
                  icon: Icons.expand_rounded,
                  isLoading: _isActionLoading && _loadingActionName == 'Expand',
                  onTap: () => _runRefinementAction('Expand', _apiService.expandEmail),
                ),
                _buildActionCard(
                  title: 'Grammar',
                  icon: Icons.spellcheck_rounded,
                  isLoading: _isActionLoading && _loadingActionName == 'Grammar',
                  onTap: () => _runRefinementAction('Grammar', _apiService.fixGrammar),
                ),
                _buildActionCard(
                  title: 'Rewrite',
                  icon: Icons.edit_note_rounded,
                  isLoading: _isActionLoading && _loadingActionName == 'Rewrite',
                  onTap: () => _runRefinementAction('Rewrite', _apiService.rewriteEmail),
                ),
                _buildActionCard(
                  title: 'Translate',
                  icon: Icons.g_translate_rounded,
                  isLoading: _isActionLoading && _loadingActionName == 'Translate',
                  onTap: () => _runRefinementAction('Translate', _apiService.translateEmail),
                ),
                _buildActionCard(
                  title: 'Regenerate',
                  icon: Icons.refresh_rounded,
                  isLoading: _isActionLoading && _loadingActionName == 'Regenerate',
                  onTap: () => _runRefinementAction('Regenerate', _apiService.regenerateEmail),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.darkSurfaceElevated.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isActionLoading ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.darkSurfaceElevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Row(
            children: [
              isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.primary)),
                    )
                  : Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
