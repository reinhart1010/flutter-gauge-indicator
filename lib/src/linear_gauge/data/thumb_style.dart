import 'package:flutter/material.dart';

class ThumbStyle {
  /// Width of the infill
  final double thickness;

  /// Width of the outer cutout mask
  final double strokeWidth;

  /// Infill color
  final Color color;

  const ThumbStyle({
    this.thickness = 6.0,
    this.strokeWidth = 1.5,
    this.color = Colors.white,
  });
}
