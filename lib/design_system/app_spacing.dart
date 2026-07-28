import 'package:flutter/widgets.dart';

/// Spacing and layout tokens based on a 4px baseline grid.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  /// Standard horizontal page padding.
  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(horizontal: md);

  /// Standard page padding (all sides).
  static const EdgeInsets pagePadding = EdgeInsets.all(md);

  static const SizedBox gapXxs = SizedBox(width: xxs, height: xxs);
  static const SizedBox gapXs = SizedBox(width: xs, height: xs);
  static const SizedBox gapSm = SizedBox(width: sm, height: sm);
  static const SizedBox gapMd = SizedBox(width: md, height: md);
  static const SizedBox gapLg = SizedBox(width: lg, height: lg);
  static const SizedBox gapXl = SizedBox(width: xl, height: xl);

  /// Standard corner radius values.
  static const double radiusSm = 4;
  static const double radiusMd = 8;
  static const double radiusLg = 16;
  static const double radiusFull = 999;
}
