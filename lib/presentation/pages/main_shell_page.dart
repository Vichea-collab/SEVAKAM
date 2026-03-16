import 'package:flutter/material.dart';
import '../state/app_role_state.dart';
import '../widgets/app_bottom_nav.dart';
import 'home/home_page.dart';
import 'notifications/notifications_page.dart';
import 'post/client_post_page.dart';
import 'orders/orders_page.dart';
import 'profile/profile_page.dart';
import 'provider_portal/provider_home_page.dart';
import 'provider_portal/provider_notifications_page.dart';
import 'provider_portal/provider_post_page.dart';
import 'provider_portal/provider_orders_page.dart';
import 'provider_portal/provider_profile_page.dart';

class MainShellPage extends StatefulWidget {
  static const String routeName = '/main';
  static final ValueNotifier<AppBottomTab> activeTab = ValueNotifier(
    AppBottomTab.home,
  );

  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _transitionNonce = 0;

  @override
  void initState() {
    super.initState();
    MainShellPage.activeTab.addListener(_onStateChanged);
    AppRoleState.role.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    MainShellPage.activeTab.removeListener(_onStateChanged);
    AppRoleState.role.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (!mounted) return;
    setState(() => _transitionNonce++);
  }

  @override
  Widget build(BuildContext context) {
    final isProvider = AppRoleState.isProvider;

    final children = isProvider
        ? const [
            ProviderPortalHomePage(),
            ProviderNotificationsPage(),
            ProviderPostPage(),
            ProviderOrdersPage(),
            ProviderProfilePage(),
          ]
        : const [
            HomePage(),
            NotificationsPage(),
            ClientPostPage(),
            OrdersPage(),
            ProfilePage(),
          ];

    return Scaffold(
      body: TweenAnimationBuilder<double>(
        key: ValueKey<String>(
          'main_shell_transition_${isProvider ? 'provider' : 'finder'}_${MainShellPage.activeTab.value.name}_$_transitionNonce',
        ),
        tween: Tween<double>(begin: 0.985, end: 1),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: IndexedStack(
          key: ValueKey('main_shell_${isProvider ? 'provider' : 'finder'}'),
          index: MainShellPage.activeTab.value.index,
          children: children,
        ),
        builder: (context, value, child) {
          final opacity = ((value - 0.985) / 0.015).clamp(0.0, 1.0);
          return Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(0, (1 - value) * 24),
              child: child,
            ),
          );
        },
      ),
      bottomNavigationBar: AppBottomNav(
        current: MainShellPage.activeTab.value,
        onTabChanged: (tab) => MainShellPage.activeTab.value = tab,
      ),
    );
  }
}
