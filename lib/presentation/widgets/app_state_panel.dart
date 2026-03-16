import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';

enum AppStatePanelType { loading, empty, error }

class AppStatePanel extends StatelessWidget {
  final AppStatePanelType type;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? lottieUrl;

  const AppStatePanel({
    super.key,
    required this.type,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.lottieUrl,
  });

  const AppStatePanel.loading({
    super.key,
    this.title = 'Loading data...',
    this.message,
    this.lottieUrl,
  }) : type = AppStatePanelType.loading,
       actionLabel = null,
       onAction = null;

  const AppStatePanel.empty({
    super.key,
    this.title = 'No data available',
    this.message,
    this.lottieUrl,
  }) : type = AppStatePanelType.empty,
       actionLabel = null,
       onAction = null;

  const AppStatePanel.error({
    super.key,
    this.title = 'Something went wrong',
    this.message,
    this.actionLabel = 'Try again',
    required this.onAction,
    this.lottieUrl,
  }) : type = AppStatePanelType.error;

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final visual = _visualFor(type);
    final panel = Container(
      width: double.infinity,
      padding: rs.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(rs.radius(16)),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (lottieUrl != null)
            Padding(
              padding: EdgeInsets.only(bottom: rs.space(12)),
              child: Lottie.network(
                lottieUrl!,
                height: rs.dimension(120),
                repeat: true,
              ),
            )
          else
            Container(
              width: rs.dimension(46),
              height: rs.dimension(46),
              decoration: BoxDecoration(
                color: visual.background,
                borderRadius: BorderRadius.circular(rs.radius(14)),
              ),
              child: Icon(
                visual.icon,
                color: visual.foreground,
                size: rs.icon(24),
              ),
            ),
          rs.gapH(10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          if ((message ?? '').trim().isNotEmpty) ...[
            rs.gapH(4),
            Text(
              message!.trim(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
          if (type == AppStatePanelType.loading && lottieUrl == null) ...[
            rs.gapH(12),
            SizedBox(
              width: rs.dimension(18),
              height: rs.dimension(18),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
          if (type == AppStatePanelType.error && onAction != null) ...[
            rs.gapH(12),
            OutlinedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(actionLabel ?? 'Try again'),
            ),
          ],
        ],
      ),
    );

    if (type == AppStatePanelType.loading) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: rs.dimension(460)),
          child: panel,
        ),
      );
    }
    return panel;
  }

  _StatePanelVisual _visualFor(AppStatePanelType nextType) {
    switch (nextType) {
      case AppStatePanelType.loading:
        return const _StatePanelVisual(
          icon: Icons.hourglass_top_rounded,
          background: Color(0xFFEAF1FF),
          foreground: AppColors.primary,
        );
      case AppStatePanelType.empty:
        return const _StatePanelVisual(
          icon: Icons.inbox_rounded,
          background: Color(0xFFF3F5F9),
          foreground: AppColors.textSecondary,
        );
      case AppStatePanelType.error:
        return const _StatePanelVisual(
          icon: Icons.warning_amber_rounded,
          background: Color(0xFFFFF4ED),
          foreground: AppColors.warning,
        );
    }
  }
}

class _StatePanelVisual {
  final IconData icon;
  final Color background;
  final Color foreground;

  const _StatePanelVisual({
    required this.icon,
    required this.background,
    required this.foreground,
  });
}
