import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/page_transition.dart';
import '../../../domain/entities/provider.dart';
import '../../state/provider_post_state.dart';
import '../../widgets/provider_card.dart';
import 'provider_detail_page.dart';

class ProviderCategoryPage extends StatefulWidget {
  final ProviderSection section;

  const ProviderCategoryPage({super.key, required this.section});

  @override
  State<ProviderCategoryPage> createState() => _ProviderCategoryPageState();
}

class _ProviderCategoryPageState extends State<ProviderCategoryPage> {
  Future<void> _handleRefresh() async {
    try {
      await ProviderPostState.refreshAllForLookup();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x10000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.section.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      '${widget.section.providers.length} providers',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  color: AppColors.primary,
                  child: GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: widget.section.providers.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: 0.64,
                    ),
                    itemBuilder: (context, index) {
                      final provider = widget.section.providers[index];
                      final heroTag = 'provider-card-${widget.section.category}-${provider.uid}';
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
