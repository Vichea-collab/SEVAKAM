import '../entities/provider_portal.dart';
import '../entities/pagination.dart';

abstract class ProviderPostRepository {
  void setBearerToken(String token);

  Future<PaginatedResult<ProviderPostItem>> loadProviderPosts({
    int page = 1,
    int limit = 10,
  });

  Future<List<DateTime>> loadProviderBlockedDates({
    required String providerUid,
  });

  Future<ProviderPostItem> createProviderPost({
    required String category,
    required List<String> services,
    required String area,
    required String details,
    required bool availableNow,
    List<String> portfolioPhotos = const [],
  });

  Future<ProviderPostItem> updateProviderPost({
    required String postId,
    required String category,
    required List<String> services,
    required String area,
    required String details,
    required bool availableNow,
    List<String> portfolioPhotos = const [],
  });

  Future<void> deleteProviderPost({required String postId});
}
