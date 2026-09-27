import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_logo.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About MailCraft AI'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Official Primary Brand Hero Logo
            const AppLogo(
              presetSize: AppLogoSize.large,
              showTitle: true,
              showTagline: true,
              layout: Axis.vertical,
              enableGlow: true,
            ),

            const SizedBox(height: 24.0),

            // App Description Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      AppConstants.appDescription,
                      style: AppTypography.bodyLarge(primaryTextColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16.0),
                    const Divider(),
                    const SizedBox(height: 12.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildFeatureBadge(context, 'Fast AI', Icons.bolt_rounded),
                        _buildFeatureBadge(context, 'Smart Tones', Icons.psychology_rounded),
                        _buildFeatureBadge(context, 'Secure', Icons.security_rounded),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20.0),

            // Version Specs Card
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  children: [
                    _buildInfoRow(context, 'Application Name', AppConstants.appName),
                    const Divider(height: 20.0),
                    _buildInfoRow(context, 'Tagline', AppConstants.tagline),
                    const Divider(height: 20.0),
                    _buildInfoRow(context, 'Version', 'v${AppConstants.appVersion}'),
                    const Divider(height: 20.0),
                    _buildInfoRow(context, 'Primary Product', 'AI Email Assistant'),
                    const Divider(height: 20.0),
                    _buildInfoRow(context, 'Engine', 'MailCraft Neural Core'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32.0),

            Text(
              AppConstants.copyrightNotice,
              style: AppTypography.caption(secondaryTextColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureBadge(BuildContext context, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryBlueLight, size: 22.0),
        ),
        const SizedBox(height: 6.0),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.0,
            color: secondaryTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.0,
            color: primaryTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
