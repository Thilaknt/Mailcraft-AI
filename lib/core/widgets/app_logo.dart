import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum AppLogoSize {
  small(28.0),
  medium(44.0),
  large(72.0),
  hero(120.0);

  final double dimension;
  const AppLogoSize(this.dimension);
}

class AppLogo extends StatelessWidget {
  final double? size;
  final AppLogoSize? presetSize;
  final bool showTitle;
  final bool showTagline;
  final Axis layout;
  final bool enableGlow;
  final VoidCallback? onTap;

  const AppLogo({
    super.key,
    this.size,
    this.presetSize = AppLogoSize.medium,
    this.showTitle = false,
    this.showTagline = false,
    this.layout = Axis.horizontal,
    this.enableGlow = false,
    this.onTap,
  });

  double get _dimension => size ?? (presetSize?.dimension ?? 44.0);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    Widget logoImage = Image.asset(
      AppConstants.logoAssetPath,
      width: _dimension,
      height: _dimension,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      isAntiAlias: true,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: _dimension,
          height: _dimension,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_dimension * 0.22),
            gradient: AppColors.brandGradient,
          ),
          child: Icon(
            Icons.mark_email_unread_rounded,
            size: _dimension * 0.5,
            color: Colors.white,
          ),
        );
      },
    );

    if (enableGlow) {
      logoImage = Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: _dimension * 1.35,
            height: _dimension * 1.35,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.logoAuraGradient,
            ),
          ),
          logoImage,
        ],
      );
    }

    Widget content;
    if (!showTitle && !showTagline) {
      content = logoImage;
    } else {
      final textChildren = <Widget>[
        if (showTitle)
          Text(
            AppConstants.appName,
            style: _dimension > 60
                ? AppTypography.displayHero(primaryTextColor)
                : (_dimension > 35
                    ? AppTypography.headlineMedium(primaryTextColor)
                    : AppTypography.titleMedium(primaryTextColor)),
          ),
        if (showTagline) ...[
          const SizedBox(height: 3.0),
          Text(
            AppConstants.tagline,
            style: AppTypography.tagline(secondaryTextColor),
            textAlign: layout == Axis.vertical ? TextAlign.center : TextAlign.start,
          ),
        ],
      ];

      if (layout == Axis.horizontal) {
        content = Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            logoImage,
            SizedBox(width: _dimension * 0.3),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: textChildren,
            ),
          ],
        );
      } else {
        content = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            logoImage,
            SizedBox(height: _dimension * 0.2),
            ...textChildren,
          ],
        );
      }
    }

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: content,
        ),
      );
    }

    return content;
  }
}
