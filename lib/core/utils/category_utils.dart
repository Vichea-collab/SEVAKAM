import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

IconData iconForCategory(String name) {
  final key = name.toLowerCase().trim();
  if (key.contains('plumb')) return Icons.plumbing_rounded;
  if (key.contains('elect')) return Icons.bolt_rounded;
  if (key.contains('clean')) return Icons.cleaning_services_rounded;
  if (key.contains('appliance') || key.contains('ac') || key.contains('cool')) {
    return Icons.ac_unit_rounded;
  }
  if (key.contains('paint')) return Icons.format_paint_rounded;
  if (key.contains('garden')) return Icons.yard_rounded;
  if (key.contains('move') || key.contains('shift')) {
    return Icons.local_shipping_rounded;
  }
  return Icons.handyman_rounded;
}

Color accentForCategory(String name) {
  final key = name.toLowerCase().trim();
  if (key.contains('plumb')) return const Color(0xFF0EA5E9);
  if (key.contains('elect')) return const Color(0xFFF59E0B);
  if (key.contains('clean')) return const Color(0xFF10B981);
  if (key.contains('appliance') || key.contains('ac') || key.contains('cool')) {
    return const Color(0xFF6366F1);
  }
  if (key.contains('paint')) return const Color(0xFFEC4899);
  if (key.contains('garden')) return const Color(0xFF84CC16);
  if (key.contains('move')) return const Color(0xFF64748B);
  return AppColors.primary;
}
