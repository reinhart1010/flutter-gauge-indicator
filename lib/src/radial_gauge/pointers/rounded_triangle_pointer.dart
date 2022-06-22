import 'dart:ui';

import 'package:gauge_indicator/gauge_indicator.dart';

class RoundedTrianglePointer extends GaugePointer {
  final double size;
  @override
  final Path path;
  @override
  final Color backgroundColor;
  @override
  final GaugePointerBorder? border;

  RoundedTrianglePointer({
    required this.size,
    required this.backgroundColor,
    double borderRadius = 2,
    this.border,
  }) : path = roundedPoly([
          VertexDefinition(-size / 2, size * 0.5), // bottom left
          VertexDefinition(size / 2, size * 0.5), // bottom right
          VertexDefinition(0, -size * 0.5), // top center
        ], borderRadius);

  @override
  List<Object?> get props => [size, backgroundColor, border];
}
