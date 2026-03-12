import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/app_toast.dart';
import '../../../domain/entities/subscription.dart';
import '../../state/subscription_state.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/app_dialog.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage>
    with WidgetsBindingObserver {
  bool _loading = false;
  bool _waitingForCheckout = false;
  String? _lastSessionId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(SubscriptionState.fetchStatus());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When user returns from Stripe Checkout browser, verify and refresh
    if (state == AppLifecycleState.resumed && _waitingForCheckout) {
      _waitingForCheckout = false;
      final sessionId = _lastSessionId;
      _lastSessionId = null;
      _verifyAfterCheckout(sessionId);
    }
  }

  Future<void> _verifyAfterCheckout(String? sessionId) async {
    setState(() => _loading = true);
    await SubscriptionState.refreshAfterCheckout(sessionId: sessionId);
    if (!mounted) return;
    setState(() => _loading = false);

    final tier = SubscriptionState.status.value.tier;
    if (tier != SubscriptionTier.basic) {
      final planName = SubscriptionState.status.value.plan.name;
      AppToast.success(
        context,
        '✨ AMAZING! You are now a $planName subscriber! ✨\nEnjoy your new premium features instantly.',
      );
    } else {
      AppToast.info(context, 'Payment confirmed. We are finalizing your upgrade...');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ValueListenableBuilder<SubscriptionStatus>(
          valueListenable: SubscriptionState.status,
          builder: (context, status, _) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                12,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              children: [
                AppTopBar(
                  title: 'Subscription',
                  actions: [
                    ValueListenableBuilder<bool>(
                      valueListenable: SubscriptionState.loading,
                      builder: (context, isLoading, _) {
                        return IconButton(
                          icon: isLoading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.refresh_rounded, color: AppColors.primary),
                          onPressed: isLoading || _loading ? null : () => SubscriptionState.fetchStatus(),
                          tooltip: 'Refresh status',
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _CurrentPlanCard(status: status),
                const SizedBox(height: 20),
                Text(
                  'Choose Your Plan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ...SubscriptionPlan.all.map(
                  (plan) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _PlanCard(
                      plan: plan,
                      isCurrentPlan: plan.tier == status.tier,
                      onUpgrade: _loading
                          ? null
                          : () => _handleUpgrade(plan.tier),
                      onCancel: plan.tier == status.tier &&
                              status.tier != SubscriptionTier.basic &&
                              !status.isCanceling
                          ? _handleCancel
                          : null,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleUpgrade(SubscriptionTier tier) async {
    if (tier == SubscriptionTier.basic) return;

    setState(() => _loading = true);
    try {
      final result = await SubscriptionState.createCheckoutSession(tier);
      final url = result.url;
      final sessionId = result.sessionId;
      if (url == null || url.isEmpty) {
        if (mounted) {
          AppToast.error(context, 'Could not create checkout session.');
        }
        return;
      }

      final uri = Uri.parse(url);
      bool launched = false;
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}
      if (!launched) {
        try {
          launched = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
        } catch (_) {}
      }
      if (!launched) {
        try {
          launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
        } catch (_) {}
      }

      if (launched) {
        _waitingForCheckout = true;
        _lastSessionId = sessionId;
        if (mounted) {
          AppToast.success(
            context,
            'Complete payment in browser. We will update your plan automatically.',
          );
        }
        unawaited(SubscriptionState.refreshAfterCheckout(sessionId: sessionId));
      } else {
        if (mounted) {
          AppToast.error(context, 'Could not open checkout page.');
        }
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, 'Failed to start checkout. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleCancel() async {
    final confirm = await showAppConfirmDialog(
      context: context,
      icon: Icons.cancel_outlined,
      title: 'Cancel Subscription',
      message:
          'Your plan will remain active until the end of the current billing period. After that, you will be downgraded to the Basic plan.',
      confirmText: 'Cancel Subscription',
      cancelText: 'Keep Plan',
      tone: AppDialogTone.danger,
    );
    if (confirm != true || !mounted) return;

    setState(() => _loading = true);
    final success = await SubscriptionState.cancelSubscription();
    if (mounted) {
      setState(() => _loading = false);
      if (success) {
        AppToast.success(
          context,
          'Subscription will cancel at end of billing period.',
        );
      } else {
        AppToast.error(context, 'Failed to cancel. Try again later.');
      }
    }
  }
}

class _CurrentPlanCard extends StatelessWidget {
  final SubscriptionStatus status;

  const _CurrentPlanCard({required this.status});

  @override
  Widget build(BuildContext context) {
    final plan = status.plan;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            plan.badgeColor,
            plan.badgeColor.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: plan.badgeColor.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(plan.badgeIcon, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              Text(
                plan.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.isCanceling ? 'Canceling' : 'Active',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Usage bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status.usageLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: status.bookingLimit < 0 ? 0 : status.usagePercent,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    status.usagePercent >= 0.9
                        ? const Color(0xFFEF4444)
                        : Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (status.currentPeriodEnd != null) ...[
            const SizedBox(height: 10),
            Text(
              status.isCanceling
                  ? 'Expires: ${_formatDate(status.currentPeriodEnd!)}'
                  : 'Renews: ${_formatDate(status.currentPeriodEnd!)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isCurrentPlan;
  final VoidCallback? onUpgrade;
  final VoidCallback? onCancel;

  const _PlanCard({
    required this.plan,
    required this.isCurrentPlan,
    this.onUpgrade,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isFree = plan.tier == SubscriptionTier.basic;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCurrentPlan ? plan.badgeColor : Theme.of(context).dividerColor,
          width: isCurrentPlan ? 2.5 : 1,
        ),
        boxShadow: isCurrentPlan
            ? [
                BoxShadow(
                  color: plan.badgeColor.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Transform.scale(
        scale: isCurrentPlan ? 1.02 : 1.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: plan.badgeColor.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(17),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: plan.badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(plan.badgeIcon, color: plan.badgeColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          if (isCurrentPlan) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: plan.badgeColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Current',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        plan.tagline,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  plan.priceLabel,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: plan.badgeColor,
                  ),
                ),
              ],
            ),
          ),
          // Annual price
          if (plan.annualPriceLabel.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16, top: 4),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  plan.annualPriceLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: plan.badgeColor.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          // Features
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...plan.features.map((f) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 18,
                          color: plan.badgeColor,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            f,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                // Quality gate
                if (plan.qualityGate != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shield_outlined, size: 16, color: Color(0xFFD97706)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            plan.qualityGate!,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: const Color(0xFF92400E),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // Best For
                if (plan.bestFor.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Best for: ${plan.bestFor}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Action buttons
          if (!isFree || isCurrentPlan)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(
                children: [
                  if (!isCurrentPlan && !isFree)
                    PrimaryButton(
                      label: 'Upgrade to ${plan.name}',
                      icon: Icons.rocket_launch_rounded,
                      onPressed: onUpgrade,
                    ),
                  if (onCancel != null) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onCancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(color: AppColors.danger),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cancel Subscription'),
                      ),
                    ),
                  ],
                ],
              ),
          ),
        ],
      ),
    ),
  );
}
}
