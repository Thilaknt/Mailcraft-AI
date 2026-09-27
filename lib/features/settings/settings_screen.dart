import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../viewmodels/compose_viewmodel.dart';
import '../../viewmodels/history_viewmodel.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _enableAnimations = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final composeVm = Provider.of<ComposeViewModel>(context);
    final historyVm = Provider.of<HistoryViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Preferences', style: AppTypography.headlineLarge(primaryText)),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Default Tone', style: AppTypography.bodyLarge(primaryText)),
                      subtitle: Text(composeVm.tone, style: AppTypography.caption(secondaryText)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      onTap: () => _selectDefaultTone(context, composeVm),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Default Language', style: AppTypography.bodyLarge(primaryText)),
                      subtitle: Text(composeVm.language, style: AppTypography.caption(secondaryText)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      onTap: () => _selectDefaultLanguage(context, composeVm),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Animations', style: AppTypography.bodyLarge(primaryText)),
                      subtitle: Text('Enable micro-animations and smooth route transitions', style: AppTypography.caption(secondaryText)),
                      value: _enableAnimations,
                      activeTrackColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() => _enableAnimations = val);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(val ? 'UI animations enabled.' : 'UI animations reduced.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Clear History', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                      subtitle: Text('Delete all saved email drafts from local storage', style: AppTypography.caption(secondaryText)),
                      trailing: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                      onTap: () => _confirmClearHistory(context, historyVm),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('About & Legal', style: AppTypography.headlineMedium(primaryText)),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('About MailCraft AI'),
                    subtitle: Text('Version 1.0.0 • Groq AI Neural Core', style: AppTypography.caption(secondaryText)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => Navigator.of(context).pushNamed('/about'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Privacy & Security'),
                    subtitle: Text('API Keys are kept secure on the backend server', style: AppTypography.caption(secondaryText)),
                    trailing: const Icon(Icons.shield_outlined, size: 18),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Privacy & Security'),
                          content: const Text(
                            'MailCraft AI never exposes Groq API keys to mobile clients.\n\nAll AI communications use secure backend endpoints with encrypted connections.',
                          ),
                          actions: [
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectDefaultTone(BuildContext context, ComposeViewModel vm) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Select Default Tone', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...ComposeViewModel.tones.map(
            (t) => ListTile(
              title: Text(t),
              trailing: vm.tone == t ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
              onTap: () {
                vm.updateTone(t);
                Navigator.of(ctx).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _selectDefaultLanguage(BuildContext context, ComposeViewModel vm) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Select Default Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...ComposeViewModel.languages.map(
            (l) => ListTile(
              title: Text(l),
              trailing: vm.language == l ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
              onTap: () {
                vm.updateLanguage(l);
                Navigator.of(ctx).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearHistory(BuildContext context, HistoryViewModel vm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear History?'),
        content: const Text('This will permanently delete all saved email drafts.'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Clear All'),
            onPressed: () {
              vm.clearHistory();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History cleared successfully.')),
              );
            },
          ),
        ],
      ),
    );
  }
}
