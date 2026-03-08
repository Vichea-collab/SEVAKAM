import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/category_utils.dart';
import '../../state/favorite_state.dart';
import '../../state/provider_post_state.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/app_state_panel.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/provider_card.dart';
import '../providers/provider_detail_page.dart';
import '../../../core/utils/page_transition.dart';
import '../../../domain/entities/provider.dart';
import '../../../domain/entities/provider_portal.dart';

class FavoritesPage extends StatelessWidget {
  static const String routeName = '/favorites';

  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const AppTopBar(title: 'My Favorites'),
              const SizedBox(height: 12),
              Expanded(
                child: ValueListenableBuilder<Set<String>>(
                  valueListenable: FavoriteState.favoriteUids,
                  builder: (context, favorites, _) {
                    if (favorites.isEmpty) {
                      return const Center(
                        child: AppStatePanel.empty(
                          title: 'No favorites yet',
                          message: 'Heart your favorite providers to see them here.',
                        ),
                      );
                    }

                    // Look up provider details from allPosts
                    final allPosts = ProviderPostState.allPosts.value;
                    final favProviders = favorites.map((uid) {
                      final post = allPosts.firstWhere(
                        (p) => p.providerUid == uid,
                        orElse: () => ProviderPostItem(
                          id: '',
                          providerUid: uid,
                          providerName: 'Provider',
                          providerType: 'individual',
                          providerCompanyName: '',
                          providerMaxWorkers: 1,
                          category: 'Cleaner',
                          service: 'Cleaning',
                          services: ['Cleaning'],
                          area: 'Phnom Penh',
                          details: '',
                          ratePerHour: 12,
                          availableNow: true,
                          timeLabel: '',
                          avatarPath: 'assets/images/profile.jpg',
                        ),
                      );
                      return _providerFromPost(post);
                    }).toList();

                    return ListView.separated(
                      itemCount: favProviders.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final provider = favProviders[index];
                        return ProviderCard(
                          provider: provider,
                          onDetails: () => Navigator.push(
                            context,
                            slideFadeRoute(ProviderDetailPage(provider: provider)),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(current: AppBottomTab.home),
    );
  }

  ProviderItem _providerFromPost(ProviderPostItem value) {
    final role = value.category.trim().isEmpty ? 'Cleaner' : value.category;
    return ProviderItem(
      uid: value.providerUid,
      name: value.providerName,
      role: role,
      rating: 4.8,
      imagePath: value.avatarPath,
      accentColor: accentForCategory(role),
      services: value.serviceList,
      providerType: value.providerType,
      companyName: value.providerCompanyName,
      maxWorkers: value.providerMaxWorkers,
    );
  }
}
