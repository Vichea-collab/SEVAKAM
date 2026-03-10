import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../domain/entities/order.dart';
import '../../state/app_role_state.dart';
import '../../state/profile_settings_state.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/primary_button.dart';

class PaymentPage extends StatefulWidget {
  static const String routeName = '/profile/payment';

  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  PaymentMethod _method = PaymentMethod.cash;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _method = ProfileSettingsState.currentPaymentMethod;
  }

  @override
  Widget build(BuildContext context) {
    final isProvider = AppRoleState.isProvider;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppTopBar(title: 'Payment Method'),
              const SizedBox(height: 12),
              if (!isProvider) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF4FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'For finders, payments are handled directly with providers (Cash preferred). No online payment is required here.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Text(
                'Select preferred method',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    _MethodTile(
                      icon: Icons.payments_outlined,
                      label: 'Cash',
                      selected: _method == PaymentMethod.cash,
                      onTap: () => setState(() => _method = PaymentMethod.cash),
                    ),
                    const SizedBox(height: 10),
                    _MethodTile(
                      icon: Icons.qr_code_scanner_rounded,
                      label: 'Bakong KHQR',
                      selected: _method == PaymentMethod.khqr,
                      onTap: () => setState(() => _method = PaymentMethod.khqr),
                    ),
                    const SizedBox(height: 10),
                    _MethodTile(
                      icon: Icons.credit_card_rounded,
                      label: 'Credit Card',
                      selected: _method == PaymentMethod.creditCard,
                      onTap: () =>
                          setState(() => _method = PaymentMethod.creditCard),
                    ),
                  ],
                ),
              ),
              PrimaryButton(
                label: _saving ? 'Saving...' : 'Save Preferred Method',
                onPressed: _saving ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await ProfileSettingsState.saveCurrentPaymentMethod(_method);
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context);
  }
}

class _MethodTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MethodTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF1FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 20)
            else
              const Icon(Icons.radio_button_off, color: AppColors.divider, size: 20),
          ],
        ),
      ),
    );
  }
}
