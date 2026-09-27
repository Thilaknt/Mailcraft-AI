import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_logo.dart';
import '../../viewmodels/compose_viewmodel.dart';
import '../navigation/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  final bool isDarkMode;
  final ValueChanged<int>? onNavigateToTab;

  const HomeScreen({
    super.key,
    this.onToggleTheme,
    this.isDarkMode = true,
    this.onNavigateToTab,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedDrawerIndex = 0;

  void _navigateToGenerator(BuildContext context, {String? mode, String? recipientType}) {
    if (recipientType != null) {
      final composeVm = Provider.of<ComposeViewModel>(context, listen: false);
      composeVm.updateRecipientType(recipientType);
    }

    Navigator.of(context).pushNamed(
      '/generator',
      arguments: {'mode': mode},
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      drawer: AppDrawer(
        selectedIndex: _selectedDrawerIndex,
        isDarkMode: widget.isDarkMode,
        onToggleTheme: widget.onToggleTheme,
        onDestinationSelected: (index) {
          setState(() {
            _selectedDrawerIndex = index;
          });
        },
      ),
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const AppLogo(
              presetSize: AppLogoSize.small,
              showTitle: false,
              layout: Axis.horizontal,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'MailCraft AI',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryText,
                  ),
                ),
                Text(
                  'Intelligent Email Assistant',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: secondaryText,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // AI Status Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            margin: const EdgeInsets.only(right: 6),
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
                  'Groq AI Online',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HERO SECTION
            Stack(
              children: [
                // Background Gradient Glow
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.0),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                          AppColors.accent.withValues(alpha: isDark ? 0.15 : 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22.0),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Write better emails.\nLet AI handle the words.',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                          color: primaryText,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        'Generate natural, personalized emails for any situation in seconds.',
                        style: TextStyle(
                          fontSize: 14.0,
                          height: 1.4,
                          color: secondaryText,
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // 2. PRIMARY CTA BUTTONS
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 48.0,
                              child: ElevatedButton.icon(
                                onPressed: () => _navigateToGenerator(context),
                                icon: const Icon(Icons.auto_awesome_rounded, size: 20.0),
                                label: const Text(
                                  'Generator',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SizedBox(
                              height: 48.0,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  if (widget.onNavigateToTab != null) {
                                    widget.onNavigateToTab!(1);
                                  } else {
                                    Navigator.of(context).pushNamed('/assistant');
                                  }
                                },
                                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20.0),
                                label: const Text(
                                  'AI Assistant',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryText,
                                  side: BorderSide(
                                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28.0),

            // 3. QUICK ACTIONS: "What can I do?"
            _buildSectionHeader('What can I do?', primaryText),
            const SizedBox(height: 14.0),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.45,
              children: [
                _buildActionCard(
                  context,
                  title: 'Generate',
                  subtitle: 'Create an email from scratch.',
                  icon: Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                  onTap: () => _navigateToGenerator(context, mode: 'Generate'),
                ),
                _buildActionCard(
                  context,
                  title: 'Rewrite',
                  subtitle: 'Rewrite an existing email.',
                  icon: Icons.edit_note_rounded,
                  color: AppColors.accent,
                  onTap: () => _navigateToGenerator(context, mode: 'Rewrite'),
                ),
                _buildActionCard(
                  context,
                  title: 'Improve',
                  subtitle: 'Fix grammar and clarity.',
                  icon: Icons.spellcheck_rounded,
                  color: AppColors.success,
                  onTap: () => _navigateToGenerator(context, mode: 'Improve'),
                ),
                _buildActionCard(
                  context,
                  title: 'Translate',
                  subtitle: 'Translate to another language.',
                  icon: Icons.g_translate_rounded,
                  color: AppColors.sparkCyan,
                  onTap: () => _navigateToGenerator(context, mode: 'Translate'),
                ),
              ],
            ),

            const SizedBox(height: 28.0),

            // 4. USE CASES: "Write for any situation"
            _buildSectionHeader('Write for any situation', primaryText),
            const SizedBox(height: 14.0),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildUseCaseChip(context, 'Job Application', 'HR Manager', Icons.work_outline_rounded),
                  _buildUseCaseChip(context, 'College / Professor', 'Professor', Icons.school_outlined),
                  _buildUseCaseChip(context, 'Client Communication', 'Client', Icons.business_center_outlined),
                  _buildUseCaseChip(context, 'Friends & Family', 'Friend', Icons.people_outline_rounded),
                  _buildUseCaseChip(context, 'Meeting Request', 'Manager', Icons.calendar_today_rounded),
                  _buildUseCaseChip(context, 'Leave Request', 'Manager', Icons.time_to_leave_rounded),
                  _buildUseCaseChip(context, 'Thank You', 'Colleague', Icons.volunteer_activism_rounded),
                  _buildUseCaseChip(context, 'Follow-up', 'Client', Icons.mark_email_read_rounded),
                ],
              ),
            ),

            const SizedBox(height: 28.0),

            // 5. HOW IT WORKS
            _buildSectionHeader('How it works', primaryText),
            const SizedBox(height: 14.0),
            Container(
              padding: const EdgeInsets.all(18.0),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  _buildStepRow(context, '01', 'Tell us what you need', 'Enter the sender, recipient, and the purpose of your email.'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(height: 1),
                  ),
                  _buildStepRow(context, '02', 'Choose your audience & tone', 'Select from 15 tones and 16 languages for tailored communication.'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(height: 1),
                  ),
                  _buildStepRow(context, '03', 'Let AI craft the email', 'Get a structured, polished email ready to copy, edit, or refine.'),
                ],
              ),
            ),

            const SizedBox(height: 28.0),

            // 6. POWERED BY AI FOOTER
            Container(
              padding: const EdgeInsets.all(18.0),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.psychology_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Powered by AI',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: primaryText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Personalized writing based on your recipient, purpose, tone, and language.',
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 17.0,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: secondaryText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUseCaseChip(
    BuildContext context,
    String label,
    String recipientType,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: ActionChip(
        avatar: Icon(icon, size: 16, color: AppColors.primary),
        label: Text(label),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: primaryText,
        ),
        onPressed: () => _navigateToGenerator(context, recipientType: recipientType),
      ),
    );
  }

  Widget _buildStepRow(
    BuildContext context,
    String stepNumber,
    String title,
    String description,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            stepNumber,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryText,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryText,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
