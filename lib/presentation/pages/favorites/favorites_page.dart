import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../domain/entities/provider_portal.dart';
import '../../state/favorite_state.dart';
import '../../state/provider_post_state.dart';
import '../../widgets/app_state_panel.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/provider_card.dart';
import '../providers/provider_detail_page.dart';
import '../../../core/utils/page_transition.dart';
import '../../../domain/entities/provider.dart';

class FavoritesPage extends StatelessWidget {
  static const String routeName = '/favorites';

  const FavoritesPage({super.key});

  Future<void> _handleRefresh() async {
    try {
      await ProviderPostState.refreshAllForLookup();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
              child: AppTopBar(title: 'My Favorites'),
            ),
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

                  return ValueListenableBuilder<List<ProviderPostItem>>(
                    valueListenable: ProviderPostState.allPosts,
                    builder: (context, allPosts, _) {
                      final favProviders = favorites.map((uid) {
                        final post = allPosts.firstWhere(
                          (p) => p.providerUid == uid,
                          orElse: () => allPosts.isNotEmpty 
                              ? allPosts.first 
                              : ProviderPostState.posts.value.first,
                        );
                        return ProviderItem.fromPost(post);
                      }).toList();

                      return RefreshIndicator(
                        onRefresh: _handleRefresh,
                        color: AppColors.primary,
                        child: GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.72,
                          ),
                          itemCount: favProviders.length,
                          itemBuilder: (context, index) {
                            final provider = favProviders[index];
                            final heroTag = 'fav-provider-card-${provider.uid}';
                            return ProviderCard(
                              provider: provider,
                              heroTag: heroTag,
                              onDetails: () => Navigator.push(
                                context,
                                slideFadeRoute(ProviderDetailPage(
                                  provider: provider,
                                  heroTag: heroTag,
                                )),
                              ),
                            );
                          },
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
    );
  }
}
