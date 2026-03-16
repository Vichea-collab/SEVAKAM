import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';

class AuthSocialButton extends StatelessWidget {
  final String label;
  final String iconAsset;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AuthSocialButton({
    super.key,
    required this.label,
    required this.iconAsset,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style:
            OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.textPrimary,
              padding: EdgeInsets.symmetric(
                horizontal: rs.space(16),
                vertical: rs.space(14),
              ),
              side: const BorderSide(color: Color(0xFFD9E1EC)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(rs.radius(18)),
              ),
            ).copyWith(
              overlayColor: WidgetStateProperty.all(
                AppColors.primary.withValues(alpha: 0.05),
              ),
            ),
        child: Row(
          children: [
            Container(
              width: rs.dimension(26),
              height: rs.dimension(26),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(rs.radius(999)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(iconAsset, fit: BoxFit.cover),
            ),
            SizedBox(width: rs.space(12)),
            Expanded(
              child: Text(
                isLoading ? 'Connecting to Google...' : label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            SizedBox(
              width: rs.dimension(24),
              height: rs.dimension(24),
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(2),
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    )
                  : Icon(
                      Icons.arrow_forward_rounded,
                      size: rs.icon(18),
                      color: AppColors.textSecondary,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
