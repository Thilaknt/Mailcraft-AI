import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class SparkGlow extends StatelessWidget {
  final double radius;

  const SparkGlow({
    super.key,
    this.radius = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.primaryBlueLight.withValues(alpha: 0.22),
            AppColors.accentViolet.withValues(alpha: 0.06),
            Colors.transparent,
          ],
          stops: const [0, 0.35, 1],
        ),
      ),
    );
  }
}
