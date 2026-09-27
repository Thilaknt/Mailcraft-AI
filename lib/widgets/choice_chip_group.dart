import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class ChoiceChipGroup extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;
  final int maxRows;

  const ChoiceChipGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.maxRows = 2,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor = AppColors.primaryBlueLight;
    final unselectedColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final selectedText = isDark ? Colors.white : Colors.white;
    final unselectedText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options
          .map(
            (option) => ChoiceChip(
              label: Text(option, style: AppTypography.bodyMedium(option == selected ? selectedText : unselectedText)),
              selected: option == selected,
              onSelected: (_) => onChanged(option),
              selectedColor: selectedColor,
              backgroundColor: unselectedColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          )
          .toList(),
    );
  }
}
