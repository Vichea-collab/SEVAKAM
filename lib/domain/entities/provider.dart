import 'package:flutter/material.dart';
import '../../core/utils/category_utils.dart';
import 'provider_portal.dart';

class ProviderItem {
  final String uid;
  final String name;
  final String bio;
  final String role;
  final double rating;
  final String imagePath;
  final Color accentColor;
  final List<String> services;
  final bool isVerified;
  final String subscriptionTier;
  final double? latitude;
  final double? longitude;
  final List<DateTime> blockedDates;
  final List<String> portfolioPhotos;

  const ProviderItem({
    required this.uid,
    required this.name,
    required this.role,
    this.bio = '',
    required this.rating,
    required this.imagePath,
    required this.accentColor,
    this.services = const <String>[],
    this.isVerified = false,
    this.subscriptionTier = 'basic',
    this.latitude,
    this.longitude,
    this.blockedDates = const [],
    this.portfolioPhotos = const [],
  });

  factory ProviderItem.fromPost(ProviderPostItem post) {
    final role = post.category.trim().isEmpty ? 'Cleaner' : post.category;
    return ProviderItem(
      uid: post.providerUid,
      name: post.providerName.trim().isEmpty ? 'Service Provider' : post.providerName,
      bio: post.providerBio,
      role: role,
      rating: post.rating,
      imagePath: post.avatarPath,
      accentColor: accentForCategory(role),
      services: post.serviceList,
      isVerified: post.isVerified,
      subscriptionTier: post.subscriptionTier,
      blockedDates: post.blockedDates,
      portfolioPhotos: post.portfolioPhotos,
      latitude: post.latitude,
      longitude: post.longitude,
    );
  }

  ProviderItem copyWith({
    String? uid,
    String? name,
    String? role,
    String? bio,
    double? rating,
    String? imagePath,
    Color? accentColor,
    List<String>? services,
    String? subscriptionTier,
    bool? isVerified,
    List<DateTime>? blockedDates,
    List<String>? portfolioPhotos,
  }) {
    return ProviderItem(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      role: role ?? this.role,
      bio: bio ?? this.bio,
      rating: rating ?? this.rating,
      imagePath: imagePath ?? this.imagePath,
      accentColor: accentColor ?? this.accentColor,
      services: services ?? this.services,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      isVerified: isVerified ?? this.isVerified,
      blockedDates: blockedDates ?? this.blockedDates,
      portfolioPhotos: portfolioPhotos ?? this.portfolioPhotos,
    );
  }
}

class ProviderSection {
  final String title;
  final String category;
  final List<ProviderItem> providers;

  const ProviderSection({
    required this.title,
    required this.category,
    required this.providers,
  });
}
