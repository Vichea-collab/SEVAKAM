import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../widgets/primary_button.dart';
import 'onboarding_page.dart';
import 'auth/customer_auth_page.dart';
import 'auth/provider_auth_page.dart';
import 'auth/forgot_password_flow.dart';

class WelcomePage extends StatelessWidget {
  static const String routeName = '/welcome';

  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background accent
          Positioned(
            top: -rs.dimension(100),
            right: -rs.dimension(50),
            child: Container(
              width: rs.dimension(300),
              height: rs.dimension(300),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x152A62FF), Color(0x002A62FF)],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: rs.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        rs.gapH(40),
                        // Logo and App Name
                        Row(
                          children: [
                            Container(
                              height: rs.dimension(48),
                              width: rs.dimension(48),
                              padding: rs.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  rs.radius(14),
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x14000000),
                                    blurRadius: 16,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Image.asset('assets/images/logo.png'),
                            ),
                            rs.gapW(14),
                            Text(
                              'Sevakam',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: rs.space(0.5),
                                  ),
                            ),
                          ],
                        ),
                        rs.gapH(40),
                        // Value Proposition
                        Text(
                          'Your Home,\nExpertly Cared For.',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontSize: rs.text(
                                  rs.compact ? 32 : 36,
                                  minFactor: 0.96,
                                  maxFactor: 1.08,
                                ),
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        rs.gapH(16),
                        Text(
                          'Book verified professionals for repairs, cleaning, and all your home service needs in one tap.',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.5,
                                fontSize: rs.text(16),
                              ),
                        ),
                        rs.gapH(40),
                        // Feature Graphic
                        Container(
                          width: double.infinity,
                          padding: rs.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.splashStart,
                                AppColors.splashEnd,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(rs.radius(24)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x332A62FF),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: rs.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          rs.radius(8),
                                        ),
                                      ),
                                      child: Text(
                                        'FAST BOOKING',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: Colors.white,
                                              letterSpacing: rs.space(1.2),
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                    rs.gapH(12),
                                    Text(
                                      'Professional\nservices on time',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            height: 1.3,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              rs.gapW(16),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    rs.radius(16),
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x26000000),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    rs.radius(16),
                                  ),
                                  child: Image.asset(
                                    'assets/images/plumber_category.jpg',
                                    height: rs.dimension(80),
                                    width: rs.dimension(80),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        rs.gapH(32),
                        // Other Links
                        Text(
                          'Quick Links (Dev)',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        rs.gapH(12),
                        Wrap(
                          spacing: rs.space(12),
                          runSpacing: rs.space(12),
                          children: [
                            _QuickLinkChip(
                              label: 'Onboarding',
                              onTap: () => Navigator.pushNamed(
                                context,
                                OnboardingPage.routeName,
                              ),
                            ),
                            _QuickLinkChip(
                              label: 'Forgot Password',
                              onTap: () => Navigator.pushNamed(
                                context,
                                ForgotPasswordFlow.routeName,
                              ),
                            ),
                          ],
                        ),
                        rs.gapH(32),
                      ],
                    ),
                  ),
                ),
                // Bottom Action Area
                Container(
                  padding: rs.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PrimaryButton(
                        label: 'Continue as Customer',
                        icon: Icons.person_outline_rounded,
                        onPressed: () => Navigator.pushNamed(
                          context,
                          CustomerAuthPage.routeName,
                        ),
                      ),
                      rs.gapH(12),
                      PrimaryButton(
                        label: 'Join as a Provider',
                        isOutlined: true,
                        icon: Icons.work_outline_rounded,
                        onPressed: () => Navigator.pushNamed(
                          context,
                          ProviderAuthPage.routeName,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickLinkChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickLinkChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(rs.radius(20)),
      child: Container(
        padding: rs.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(rs.radius(20)),
          color: const Color(0xFFF8FAFC),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
