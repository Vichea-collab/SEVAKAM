import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import 'pressable_scale.dart';

class RoleModeCard extends StatelessWidget {
  final bool isProvider;
  final bool isSwitching;
  final VoidCallback? onSwitch;

  const RoleModeCard({
    super.key,
    required this.isProvider,
    required this.isSwitching,
    required this.onSwitch,
  });

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final theme = Theme.of(context);
    final targetTitle = isProvider ? 'Finder' : 'Provider';

    return Container(
      padding: rs.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(rs.radius(18)),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: const Color(0x140F172A),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: rs.dimension(42),
                width: rs.dimension(42),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.splashStart, AppColors.splashEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(rs.radius(12)),
                ),
                child: Icon(
                  Icons.swap_horiz_rounded,
                  color: Colors.white,
                  size: rs.icon(22),
                ),
              ),
              rs.gapW(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Role Access',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    rs.gapH(2),
                    Text(
                      'Switch between finder and provider workspace.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          rs.gapH(16),
          Row(
            children: [
              Expanded(
                child: _RolePill(
                  icon: Icons.person_search_rounded,
                  label: 'Finder',
                  active: !isProvider,
                ),
              ),
              rs.gapW(10),
              Expanded(
                child: _RolePill(
                  icon: Icons.design_services_rounded,
                  label: 'Provider',
                  active: isProvider,
                ),
              ),
            ],
          ),
          rs.gapH(16),
          SizedBox(
            width: double.infinity,
            child: PressableScale(
              onTap: isSwitching ? null : onSwitch,
              child: ElevatedButton.icon(
                onPressed: isSwitching ? null : onSwitch,
                icon: isSwitching
                    ? SizedBox(
                        height: rs.dimension(18),
                        width: rs.dimension(18),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        isProvider
                            ? Icons.person_search_rounded
                            : Icons.design_services_rounded,
                      ),
                label: Text(
                  isSwitching ? 'Switching...' : 'Switch to $targetTitle',
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: rs.space(14)),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withValues(
                    alpha: 0.6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(rs.radius(14)),
                  ),
                  elevation: 0,
                  textStyle: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RolePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _RolePill({
    required this.icon,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.symmetric(
        horizontal: rs.space(12),
        vertical: rs.space(12),
      ),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFF3F8FF) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(rs.radius(14)),
        border: Border.all(
          color: active ? AppColors.primary : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: rs.icon(18),
            color: active ? AppColors.primary : AppColors.textSecondary,
          ),
          rs.gapW(8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: active ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
          if (active) ...[
            rs.gapW(6),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: rs.space(7),
                vertical: rs.space(3),
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(rs.radius(100)),
              ),
              child: Text(
                'On',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
