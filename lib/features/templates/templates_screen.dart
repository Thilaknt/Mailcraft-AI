import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/template_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../viewmodels/compose_viewmodel.dart';
import '../../widgets/section_card.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(title: const Text('Email Templates')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: appTemplates.length,
        separatorBuilder: (_, index) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final template = appTemplates[index];
          return SectionCard(
            title: template.title,
            subtitle: template.description,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        template.recipientType,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        template.tone,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accent),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Sample Prompt:', style: AppTypography.caption(secondaryText)),
                const SizedBox(height: 4),
                Text(template.purposeHint, style: AppTypography.bodyMedium(primaryText)),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () {
                    final composeVm = Provider.of<ComposeViewModel>(context, listen: false);
                    composeVm.populateTemplate(
                      targetPurpose: template.purposeHint,
                      targetRecipientType: template.recipientType,
                      targetTone: template.tone,
                      targetLanguage: template.language,
                    );
                    Navigator.of(context).pushNamed(
                      '/generator',
                      arguments: {'mode': 'Template: ${template.title}'},
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Template "${template.title}" loaded into generator.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Center(child: Text('Use Template', style: TextStyle(fontWeight: FontWeight.bold))),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
