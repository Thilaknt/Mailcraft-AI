import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/email_models.dart';
import '../../viewmodels/history_viewmodel.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        Provider.of<HistoryViewModel>(context, listen: false).loadHistory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          Consumer<HistoryViewModel>(
            builder: (context, vm, _) {
              if (!vm.hasHistory) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_sweep_rounded),
                tooltip: 'Clear History',
                onPressed: () => _confirmClearHistory(context, vm),
              );
            },
          ),
        ],
      ),
      body: Consumer<HistoryViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!vm.hasHistory) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_rounded, size: 64, color: secondaryText.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text('No emails yet', style: AppTypography.headlineMedium(primaryText)),
                    const SizedBox(height: 8),
                    Text(
                      'Your generated emails will appear here.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium(secondaryText),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: vm.historyItems.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = vm.historyItems[index];
              final words = item.body.trim().isEmpty ? 0 : item.body.trim().split(RegExp(r'\s+')).length;
              final chars = item.body.length;
              final readSecs = words > 0 ? (words / 200 * 60).round().clamp(5, 3600) : 5;

              return Card(
                color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    final req = EmailRequestModel(
                      senderName: item.senderName,
                      senderRole: item.senderRole,
                      recipientType: item.recipientType,
                      recipientName: item.recipientName,
                      purpose: item.purpose,
                      tone: item.tone,
                      language: item.language,
                    );
                    final res = EmailResponseModel(
                      subject: item.subject,
                      body: item.body,
                      qualityScore: 94,
                      wordCount: words,
                      characterCount: chars,
                      readingTimeSeconds: readSecs,
                    );
                    Navigator.of(context).pushNamed(
                      '/result',
                      arguments: {'request': req, 'response': res},
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                item.subject.isNotEmpty ? item.subject : item.purpose,
                                style: AppTypography.headlineMedium(primaryText),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                item.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                                color: item.isFavorite ? AppColors.warning : secondaryText,
                                size: 22,
                              ),
                              onPressed: () => vm.toggleFavorite(item.id),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${item.senderName.isNotEmpty ? "From: ${item.senderName} • " : ""}${item.recipientType} • ${item.tone} • ${item.language}',
                          style: AppTypography.caption(secondaryText),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item.body,
                          style: AppTypography.bodyMedium(secondaryText),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDate(item.createdAt),
                              style: AppTypography.caption(secondaryText),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.primary),
                                  tooltip: 'Copy Body',
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: item.body));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Email copied to clipboard!')),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                  tooltip: 'Delete',
                                  onPressed: () => vm.deleteHistoryItem(item.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
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
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
