import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_logo.dart';

class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;
  final VoidCallback? onToggleTheme;
  final bool isDarkMode;

  const AppDrawer({
    super.key,
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.onToggleTheme,
    this.isDarkMode = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Drawer(
      backgroundColor: surfaceColor,
      child: Column(
        children: [
          // Drawer Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20.0, 56.0, 20.0, 24.0),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppLogo(
                  presetSize: AppLogoSize.medium,
                  showTitle: true,
                  showTagline: true,
                  layout: Axis.horizontal,
                ),
                const SizedBox(height: 16.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(radius: 3, backgroundColor: AppColors.success),
                      SizedBox(width: 6.0),
                      Text(
                        'Groq AI Online',
                        style: TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Drawer Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
              children: [
                ListTile(
                  leading: const Icon(Icons.home_rounded, size: 22.0),
                  title: const Text('Home Landing'),
                  selected: selectedIndex == 0,
                  onTap: () {
                    Navigator.pop(context);
                    if (onDestinationSelected != null) {
                      onDestinationSelected!(0);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.auto_awesome_rounded, size: 22.0, color: AppColors.primary),
                  title: const Text('Create an Email'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).pushNamed('/generator');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.dashboard_customize_rounded, size: 22.0),
                  title: const Text('Email Templates'),
                  selected: selectedIndex == 1,
                  onTap: () {
                    Navigator.pop(context);
                    if (onDestinationSelected != null) {
                      onDestinationSelected!(1);
                    } else {
                      Navigator.of(context).pushNamed('/templates');
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history_rounded, size: 22.0),
                  title: const Text('Email History'),
                  selected: selectedIndex == 2,
                  onTap: () {
                    Navigator.pop(context);
                    if (onDestinationSelected != null) {
                      onDestinationSelected!(2);
                    } else {
                      Navigator.of(context).pushNamed('/history');
                    }
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(),
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined, size: 22.0),
                  title: const Text('Settings'),
                  selected: selectedIndex == 3,
                  onTap: () {
                    Navigator.pop(context);
                    if (onDestinationSelected != null) {
                      onDestinationSelected!(3);
                    } else {
                      Navigator.of(context).pushNamed('/settings');
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded, size: 22.0),
                  title: Text('About ${AppConstants.appName}'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).pushNamed('/about');
                  },
                ),
              ],
            ),
          ),

          // Drawer Footer with Theme Toggle
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      size: 20.0,
                      color: secondaryTextColor,
                    ),
                    const SizedBox(width: 10.0),
                    Text(
                      isDarkMode ? 'Dark Theme' : 'Light Theme',
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w500,
                        color: primaryTextColor,
                      ),
                    ),
                  ],
                ),
                if (onToggleTheme != null)
                  Switch.adaptive(
                    value: isDarkMode,
                    onChanged: (val) => onToggleTheme!(),
                    activeTrackColor: AppColors.primary,
                    activeThumbColor: Colors.white,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
