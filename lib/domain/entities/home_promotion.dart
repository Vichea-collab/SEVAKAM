import 'package:flutter/material.dart';

enum HomePromotionTargetType { provider, service, category, search, post, page }

class HomePromotion {
  final String id;
  final String placement;
  final String badgeLabel;
  final String title;
  final String description;
  final String imageUrl;
  final String ctaLabel;
  final HomePromotionTargetType targetType;
  final String targetValue;
  final String query;
  final String category;
  final String city;
  final int sortOrder;
  final bool active;
  final DateTime? startAt;
  final DateTime? endAt;

  const HomePromotion({
    required this.id,
    required this.placement,
    required this.badgeLabel,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.ctaLabel,
    required this.targetType,
    required this.targetValue,
    this.query = '',
    this.category = '',
    this.city = '',
    this.sortOrder = 0,
    this.active = true,
    this.startAt,
    this.endAt,
  });

  factory HomePromotion.fromMap(Map<String, dynamic> row) {
    return HomePromotion(
      id: (row['id'] ?? '').toString(),
      placement: (row['placement'] ?? '').toString(),
      badgeLabel: (row['badgeLabel'] ?? '').toString(),
      title: (row['title'] ?? '').toString(),
      description: (row['description'] ?? row['message'] ?? '').toString(),
      imageUrl: (row['imageUrl'] ?? '').toString(),
      ctaLabel: (row['ctaLabel'] ?? '').toString(),
      targetType: _parseTargetType(row['targetType']),
      targetValue: (row['targetValue'] ?? '').toString(),
      query: (row['query'] ?? '').toString(),
      category: (row['category'] ?? '').toString(),
      city: (row['city'] ?? '').toString(),
      sortOrder: _toInt(row['sortOrder']),
      active: row['active'] != false,
      startAt: _toDate(row['startAt']),
      endAt: _toDate(row['endAt']),
    );
  }

  static HomePromotionTargetType _parseTargetType(dynamic value) {
    switch ((value ?? '').toString().trim().toLowerCase()) {
      case 'provider':
        return HomePromotionTargetType.provider;
      case 'service':
        return HomePromotionTargetType.service;
      case 'category':
        return HomePromotionTargetType.category;
      case 'post':
        return HomePromotionTargetType.post;
      case 'page':
        return HomePromotionTargetType.page;
      case 'search':
      default:
        return HomePromotionTargetType.search;
    }
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse((value ?? '').toString()) ?? 0;
  }

  static DateTime? _toDate(dynamic value) {
    final raw = (value ?? '').toString().trim();
    if (raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}

class HomePromotionPalette {
  final Color from;
  final Color to;

  const HomePromotionPalette({required this.from, required this.to});
}
