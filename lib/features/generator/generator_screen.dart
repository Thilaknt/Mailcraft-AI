import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/history_item.dart';
import '../../services/api_service.dart';
import '../../viewmodels/compose_viewmodel.dart';
import '../../viewmodels/history_viewmodel.dart';

class GeneratorScreen extends StatefulWidget {
  final String? initialMode;

  const GeneratorScreen({
    super.key,
    this.initialMode,
  });

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  final _apiService = ApiService();

  late TextEditingController _senderNameController;
  late TextEditingController _senderRoleController;
  late TextEditingController _recipientNameController;
  late TextEditingController _purposeController;
  late TextEditingController _contextController;

  bool _isGenerating = false;
  bool _isContextExpanded = false;
  bool _showValidationErrors = false;

  @override
  void initState() {
    super.initState();
    final composeVm = Provider.of<ComposeViewModel>(context, listen: false);
    _senderNameController = TextEditingController(text: composeVm.senderName);
    _senderRoleController = TextEditingController(text: composeVm.senderRole);
    _recipientNameController = TextEditingController(text: composeVm.recipientName);
    _purposeController = TextEditingController(text: composeVm.purpose);
    _contextController = TextEditingController(text: composeVm.additionalContext);

    _purposeController.addListener(() {
      setState(() {});
    });

    if (composeVm.additionalContext.isNotEmpty) {
      _isContextExpanded = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final composeVm = Provider.of<ComposeViewModel>(context);
    if (_senderNameController.text != composeVm.senderName) {
      _senderNameController.text = composeVm.senderName;
    }
    if (_senderRoleController.text != composeVm.senderRole) {
      _senderRoleController.text = composeVm.senderRole;
    }
    if (_recipientNameController.text != composeVm.recipientName) {
      _recipientNameController.text = composeVm.recipientName;
    }
    if (_purposeController.text != composeVm.purpose) {
      _purposeController.text = composeVm.purpose;
    }
    if (_contextController.text != composeVm.additionalContext) {
      _contextController.text = composeVm.additionalContext;
    }
  }

  @override
  void dispose() {
    _senderNameController.dispose();
    _senderRoleController.dispose();
    _recipientNameController.dispose();
    _purposeController.dispose();
    _contextController.dispose();
    super.dispose();
  }

  Future<void> _handleGenerateEmail() async {
    final composeVm = Provider.of<ComposeViewModel>(context, listen: false);

    setState(() {
      _showValidationErrors = true;
    });

    if (!composeVm.isValid) {
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final isServerHealthy = await _apiService.checkHealth();
      if (!isServerHealthy) {
        throw ApiException('AI server is unreachable. Please verify FastAPI backend is running.');
      }

      final request = composeVm.buildRequest();
      final response = await _apiService.generateEmail(request);

      if (!mounted) return;

      final historyVm = Provider.of<HistoryViewModel>(context, listen: false);
      final historyItem = HistoryItem.fromRequestResponse(request, response);
      await historyVm.addHistoryItem(historyItem);

      if (!mounted) return;
      setState(() => _isGenerating = false);

      Navigator.of(context).pushNamed(
        '/result',
        arguments: {
          'request': request,
          'response': response,
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGenerating = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('ApiException: ', '')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back to Home',
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacementNamed('/');
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'MailCraft AI',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Generator',
              style: TextStyle(fontSize: 12, color: secondaryText, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 3, backgroundColor: AppColors.success),
                SizedBox(width: 6),
                Text(
                  'Groq AI',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Consumer<ComposeViewModel>(
        builder: (context, composeVm, child) {
          final isSenderEmpty = composeVm.senderName.trim().isEmpty;
          final isRecipientTypeEmpty = composeVm.recipientType.trim().isEmpty;
          final isPurposeEmpty = composeVm.purpose.trim().isEmpty;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mode indicator banner if arrived from quick actions
                if (widget.initialMode != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome_rounded, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Mode: ${widget.initialMode}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ],

                // Generator Main Form Card
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SECTION 1: SENDER
                      _buildSectionHeader('SENDER', Icons.person_outline_rounded, primaryText),
                      const SizedBox(height: 12.0),

                      // Sender Name *
                      _buildFieldLabel('Sender Name *', primaryText),
                      const SizedBox(height: 6.0),
                      TextField(
                        controller: _senderNameController,
                        style: TextStyle(color: primaryText),
                        decoration: _inputDecoration(
                          hint: 'e.g. Tiger',
                          isDark: isDark,
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                          errorText: _showValidationErrors && isSenderEmpty
                              ? 'Tell us who is writing the email.'
                              : null,
                        ),
                        onChanged: composeVm.updateSenderName,
                      ),

                      const SizedBox(height: 14.0),

                      // Sender Role / Relationship
                      _buildFieldLabel('Sender Role / Relationship (Optional)', primaryText),
                      const SizedBox(height: 6.0),
                      TextField(
                        controller: _senderRoleController,
                        style: TextStyle(color: primaryText),
                        decoration: _inputDecoration(
                          hint: 'e.g. Engineering Student',
                          isDark: isDark,
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                        ),
                        onChanged: composeVm.updateSenderRole,
                      ),

                      const SizedBox(height: 22.0),
                      const Divider(),
                      const SizedBox(height: 16.0),

                      // SECTION 2: RECIPIENT
                      _buildSectionHeader('RECIPIENT', Icons.alternate_email_rounded, primaryText),
                      const SizedBox(height: 12.0),

                      // Recipient Type *
                      _buildFieldLabel('Recipient Type *', primaryText),
                      const SizedBox(height: 6.0),
                      DropdownButtonFormField<String>(
                        initialValue: composeVm.recipientType,
                        dropdownColor: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                        style: TextStyle(color: primaryText, fontSize: 14.0, fontWeight: FontWeight.w600),
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down_rounded),
                        decoration: _inputDecoration(
                          hint: 'Select Recipient Type',
                          isDark: isDark,
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                          errorText: _showValidationErrors && isRecipientTypeEmpty
                              ? 'Choose a recipient type.'
                              : null,
                        ),
                        items: ComposeViewModel.recipientTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) composeVm.updateRecipientType(val);
                        },
                      ),

                      const SizedBox(height: 14.0),

                      // Recipient Name
                      _buildFieldLabel('Recipient Name (Optional)', primaryText),
                      const SizedBox(height: 6.0),
                      TextField(
                        controller: _recipientNameController,
                        style: TextStyle(color: primaryText),
                        decoration: _inputDecoration(
                          hint: 'e.g. Rahul, Dr. Sharma, Sarah Jenkins',
                          isDark: isDark,
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                        ),
                        onChanged: composeVm.updateRecipientName,
                      ),

                      const SizedBox(height: 22.0),
                      const Divider(),
                      const SizedBox(height: 16.0),

                      // SECTION 3: PURPOSE / INSTRUCTION *
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildFieldLabel('Purpose / Instruction *', primaryText),
                          Text(
                            '${_purposeController.text.length} / 500',
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                              color: _purposeController.text.length > 500
                                  ? AppColors.error
                                  : secondaryText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6.0),
                      TextField(
                        controller: _purposeController,
                        maxLines: 4,
                        maxLength: 500,
                        style: TextStyle(color: primaryText),
                        decoration: _inputDecoration(
                          hint: 'Describe what you want to communicate...\n\nExample: Request my professor for a two-day extension on my project submission because I need additional time to complete testing.',
                          isDark: isDark,
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                          errorText: _showValidationErrors && isPurposeEmpty
                              ? 'Describe what you want to communicate.'
                              : null,
                        ).copyWith(counterText: ''),
                        onChanged: composeVm.updatePurpose,
                      ),

                      const SizedBox(height: 18.0),

                      // SECTION 4: TONE *
                      _buildFieldLabel('Tone *', primaryText),
                      const SizedBox(height: 6.0),
                      DropdownButtonFormField<String>(
                        initialValue: composeVm.tone,
                        dropdownColor: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                        style: TextStyle(color: primaryText, fontSize: 14.0, fontWeight: FontWeight.w600),
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down_rounded),
                        decoration: _inputDecoration(
                          hint: 'Select Tone',
                          isDark: isDark,
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                        ),
                        items: ComposeViewModel.tones.map((t) {
                          return DropdownMenuItem<String>(
                            value: t,
                            child: Text(t, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) composeVm.updateTone(val);
                        },
                      ),

                      const SizedBox(height: 18.0),

                      // SECTION 5: OUTPUT LANGUAGE *
                      _buildFieldLabel('Output Language *', primaryText),
                      const SizedBox(height: 6.0),
                      DropdownButtonFormField<String>(
                        initialValue: composeVm.language,
                        dropdownColor: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                        style: TextStyle(color: primaryText, fontSize: 14.0, fontWeight: FontWeight.w600),
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down_rounded),
                        decoration: _inputDecoration(
                          hint: 'Select Language',
                          isDark: isDark,
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                          prefixIcon: const Icon(Icons.language_rounded, size: 20, color: AppColors.primary),
                        ),
                        items: ComposeViewModel.languages.map((lang) {
                          return DropdownMenuItem<String>(
                            value: lang,
                            child: Text(lang, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) composeVm.updateLanguage(val);
                        },
                      ),

                      const SizedBox(height: 18.0),

                      // SECTION 6: ADDITIONAL CONTEXT (EXPANDABLE)
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isContextExpanded = !_isContextExpanded;
                          });
                        },
                        borderRadius: BorderRadius.circular(12.0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                          child: Row(
                            children: [
                              Icon(
                                _isContextExpanded
                                    ? Icons.remove_circle_outline_rounded
                                    : Icons.add_circle_outline_rounded,
                                size: 20,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isContextExpanded ? 'Hide additional context' : '+ Add additional context',
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: TextField(
                            controller: _contextController,
                            maxLines: 3,
                            style: TextStyle(color: primaryText),
                            decoration: _inputDecoration(
                              hint: 'Add deadlines, important details, names, or other information...',
                              isDark: isDark,
                              primaryText: primaryText,
                              secondaryText: secondaryText,
                            ),
                            onChanged: composeVm.updateAdditionalContext,
                          ),
                        ),
                        crossFadeState: _isContextExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 300),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24.0),

                // GENERATE ACTION BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 54.0,
                  child: ElevatedButton(
                    onPressed: _isGenerating ? null : _handleGenerateEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                    child: _isGenerating
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Crafting your email...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.auto_awesome_rounded, size: 22),
                              SizedBox(width: 10),
                              Text(
                                'Generate Email with AI',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 32.0),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.1,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required bool isDark,
    required Color primaryText,
    required Color secondaryText,
    Widget? prefixIcon,
    String? errorText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: secondaryText.withValues(alpha: 0.65), fontSize: 13.5),
      prefixIcon: prefixIcon,
      errorText: errorText,
      errorStyle: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w600),
      filled: true,
      fillColor: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.0),
        borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.0),
        borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.0),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.0),
        borderSide: const BorderSide(color: AppColors.error, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.0),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }
}
