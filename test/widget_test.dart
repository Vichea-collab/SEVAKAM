import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:servicefinder/core/constants/app_colors.dart';
import 'package:servicefinder/domain/entities/provider.dart';
import 'package:servicefinder/presentation/pages/auth/customer_auth_page.dart';
import 'package:servicefinder/presentation/pages/auth/provider_auth_page.dart';
import 'package:servicefinder/presentation/pages/welcome_page.dart';
import 'package:servicefinder/presentation/widgets/auth_social_button.dart';
import 'package:servicefinder/presentation/widgets/provider_card.dart';

void main() {
  testWidgets('Welcome page renders core actions', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: WelcomePage()));
    await tester.pump();

    expect(find.text('Continue as Customer'), findsOneWidget);
    expect(find.text('Join as a Provider'), findsOneWidget);
  });

  testWidgets('Customer auth shows provider toggle and Google button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: CustomerAuthPage()));
    await tester.pump();

    expect(find.text('Become a Provider'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('Provider auth shows provider toggle and Google button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ProviderAuthPage()));
    await tester.pump();

    expect(find.text('Become a Provider'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('AuthSocialButton shows loading state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AuthSocialButton(
            label: 'Continue with Google',
            iconAsset: 'assets/images/google_icon.png',
            isLoading: true,
            onPressed: null,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Connecting to Google...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('ProviderCard renders provider badges and CTA', (
    WidgetTester tester,
  ) async {
    const provider = ProviderItem(
      uid: 'provider-1',
      name: 'Luch Vichea',
      role: 'Electrician',
      rating: 4.0,
      imagePath: '',
      accentColor: AppColors.primary,
      isVerified: true,
      subscriptionTier: 'elite',
      services: <String>['Wiring Repair'],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 220,
              height: 320,
              child: ProviderCard(provider: provider),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Luch Vichea'), findsOneWidget);
    expect(find.text('VERIFIED'), findsOneWidget);
    expect(find.text('ELITE'), findsOneWidget);
    expect(find.text('View profile'), findsOneWidget);
  });
}
