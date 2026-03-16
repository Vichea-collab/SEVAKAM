import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class Responsive {
  const Responsive._(this.size, this.textScaler);

  factory Responsive.of(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Responsive._(mediaQuery.size, mediaQuery.textScaler);
  }

  static const double _baseWidth = 390;
  static const double _minScale = 0.85;
  static const double _maxScale = 1.2;

  final Size size;
  final TextScaler textScaler;

  double get width => size.width;
  double get height => size.height;
  double get shortestSide => math.min(width, height);
  bool get compact => width < 360;
  bool get medium => width >= 600;

  double get _scaleFactor =>
      (shortestSide / _baseWidth).clamp(_minScale, _maxScale);

  double space(double value) => value * _scaleFactor;
  double radius(double value) => value * _scaleFactor;
  double icon(double value) => value * _scaleFactor;

  double text(
    double value, {
    double minFactor = 0.92,
    double maxFactor = 1.12,
  }) {
    final scaled = value * _scaleFactor;
    final min = value * minFactor;
    final max = value * maxFactor;
    return scaled.clamp(min, max);
  }

  double dimension(
    double value, {
    double minFactor = 0.82,
    double maxFactor = 1.2,
  }) {
    final scaled = value * _scaleFactor;
    final min = value * minFactor;
    final max = value * maxFactor;
    return scaled.clamp(min, max);
  }

  EdgeInsets all(double value) => EdgeInsets.all(space(value));

  EdgeInsets symmetric({double horizontal = 0, double vertical = 0}) =>
      EdgeInsets.symmetric(
        horizontal: space(horizontal),
        vertical: space(vertical),
      );

  EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => EdgeInsets.only(
    left: space(left),
    top: space(top),
    right: space(right),
    bottom: space(bottom),
  );

  SizedBox gapH(double value) => SizedBox(height: space(value));
  SizedBox gapW(double value) => SizedBox(width: space(value));
}

extension ResponsiveContext on BuildContext {
  Responsive get rs => Responsive.of(this);
}
