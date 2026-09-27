import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_logo.dart';

class AppEmptyState extends StatelessWidget {
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final String? aiPromptHint;

  const AppEmptyState({
    super.key,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onActionPressed,
    this.aiPromptHint,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const AppLogo(
              presetSize: AppLogoSize.large,
              enableGlow: true,
            ),
            const SizedBox(height: 24.0),
            Text(
              title,
              style: AppTypography.headlineMedium(primaryTextColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
            Text(
              description,
              style: AppTypography.bodyMedium(secondaryTextColor),
              textAlign: TextAlign.center,
            ),
            if (aiPromptHint != null) ...[
              const SizedBox(height: 20.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 18.0,
                      color: AppColors.accentViolet,
                    ),
                    const SizedBox(width: 8.0),
                    Flexible(
                      child: Text(
                        aiPromptHint!,
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w500,
                          color: primaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: 28.0),
              ElevatedButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.edit_note_rounded, size: 20.0),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
