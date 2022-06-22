import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:gauge_indicator/src/utils/apply_aspect_ratio.dart';
import 'package:gauge_indicator/src/utils/get_arc_angle.dart';
import 'package:gauge_indicator/src/utils/get_point_on_circle.dart';
import 'package:gauge_indicator/src/utils/get_sagitta.dart';
import 'dart:math' as math;

class GaugeSizeRatios {
  final double aspectRatio;
  final double radiusFactor;

  double getHeight(double width) => width / aspectRatio;

  double getWidth(double height) => height * aspectRatio;

  double getRadius(Size size) => size.height * radiusFactor;

  GaugeSizeRatios({
    required this.aspectRatio,
    required this.radiusFactor,
  });
}

class GaugeSegmentDefinition {
  final double startAngle;
  final double sweepAngle;
  final Color color;

  GaugeSegmentDefinition({
    required this.startAngle,
    required this.sweepAngle,
    required this.color,
  });
}

class GaugeAxisDefinition {
  /// Describes a cricle placed in the axis center.
  final Rect rect;
  final Path surface;
  final double thickness;
  final List<GaugeSegmentDefinition> segments;

  Offset get center => rect.center;
  double get radius => rect.width / 2;

  bool _needsReposition = false;
  bool get needsRecalculation => _needsReposition;
  void markNeedsRecalculation() {
    _needsReposition = true;
  }

  GaugeAxisDefinition({
    required this.surface,
    required this.rect,
    required this.segments,
    required this.thickness,
  });

  GaugeAxisDefinition shift(Offset offset) => GaugeAxisDefinition(
        surface: surface.shift(offset),
        rect: rect.shift(offset),
        segments: segments,
        thickness: thickness,
      );
}

class GaugeLayout {
  final Rect circleRect;
  final Rect targetRect;
  final Rect sourceRect;

  final double radius;

  const GaugeLayout({
    required this.circleRect,
    required this.targetRect,
    required this.sourceRect,
    required this.radius,
  });

  GaugeLayout shift(Offset offset) => GaugeLayout(
        circleRect: circleRect.shift(offset),
        targetRect: targetRect.shift(offset),
        sourceRect: sourceRect.shift(offset),
        radius: radius,
      );
}

class RadialGaugeRenderBox extends RenderShiftedBox {
  double _min;
  double get min => _min;
  set min(double min) {
    if (_min != min) {
      _min = min;
      _axisDefinition.markNeedsRecalculation();
      markNeedsPaint();
    }
  }

  double _max;
  double get max => _max;
  set max(double max) {
    if (_max != max) {
      _max = max;
      _axisDefinition.markNeedsRecalculation();
      markNeedsPaint();
    }
  }

  double _value;
  double get value => _value;
  set value(double value) {
    if (_value != value) {
      _value = value;
      _axisDefinition.markNeedsRecalculation();
      markNeedsPaint();
    }
  }

  GaugeAxis _axis;
  GaugeAxis get axis => _axis;

  /// Currently, only a single axis is supported.
  set axis(GaugeAxis axis) {
    if (_axis != axis) {
      if (_axis.degrees != axis.degrees ||
          _axis.style.thickness != axis.style.thickness) {
        markNeedsLayout();
      } else {
        _axisDefinition.markNeedsRecalculation();
        markNeedsPaint();
      }
      _axis = axis;
    }
  }

  Alignment _alignment;
  Alignment get alignment => _alignment;
  set alignment(Alignment alignment) {
    if (_alignment != alignment) {
      _alignment = alignment;
      markNeedsLayout();
    }
  }

  double? _radius;
  double? get radius => _radius;
  set radius(double? radius) {
    if (_radius != radius) {
      _radius = radius;
      markNeedsLayout();
    }
  }

  bool _debug;
  bool get debug => _debug;
  set debug(bool debug) {
    if (_debug != debug) {
      _debug = debug;
      markNeedsPaint();
    }
  }

  late GaugeLayout _computedLayout;
  late GaugeAxisDefinition _axisDefinition;

  /// Creates a RenderBox that displays a radial gauge.
  RadialGaugeRenderBox({
    required final double min,
    required final double max,
    required final double value,
    required final GaugeAxis axis,
    required final Alignment alignment,
    required final bool debug,
    required final double? radius,
    RenderBox? child,
  })  : _min = min,
        _max = max,
        _value = value,
        _axis = axis,
        _alignment = alignment,
        _radius = radius,
        _debug = debug,
        super(child);

  @override
  bool get sizedByParent => false;

  /// Calculate gauge indicator ratios.
  ///
  /// Thanks to this method we are able to determine the RenderBox size.
  GaugeSizeRatios _calculateSizeRatios() {
    /// Target rect aspect ratio is determined by the saggita with
    /// some widget related constraints.
    double getBoundingBoxAspectRatio(double heightFactor) {
      const width = 1.0;
      const halfWidth = width / 2;

      /// Bounding box aspect ratio cannot be smaller than half of the width.
      final height = math.max(halfWidth, heightFactor);

      return width / height;
    }

    final degrees = axis.degrees.clamp(10.0, 360.0);

    const radiusFactor = 0.5;
    final heightFactor = getSagitta(degrees, radiusFactor);

    return GaugeSizeRatios(
      aspectRatio: getBoundingBoxAspectRatio(heightFactor),
      radiusFactor: (radiusFactor / heightFactor.clamp(0.5, 1.0)),
    );
  }

  Iterable<GaugeSegmentDefinition> _calculateAxisSegments(
    Tween<double> gaugeDegreesTween,
    double radius,
  ) sync* {
    final separator = getArcAngle(axis.style.segmentSpacing, radius) / 2;

    for (var i = 0; i < axis.segments.length; i++) {
      final segment = axis.segments[i];

      final from = (segment.from - min) / (max - min);
      final startAngle = gaugeDegreesTween.transform(from);

      final to = (segment.to - min) / (max - min);
      final endAngle = gaugeDegreesTween.transform(to);
      final sweepAngle = endAngle - startAngle;

      final isLast = (i + 1) == axis.segments.length;
      final isFirst = i == 0;
      final trimStart = isFirst ? 0 : -separator;
      final trimEnd = isFirst && isLast
          ? 0
          : isFirst || isLast
              ? separator
              : separator * 2;

      yield GaugeSegmentDefinition(
        startAngle: toRadians(startAngle) - trimStart,
        sweepAngle: toRadians(sweepAngle) - trimEnd,
        color: segment.color,
      );
    }
  }

  GaugeAxisDefinition _calculateAxisDefinition(GaugeLayout layout) {
    final clampedRadius = layout.radius;
    final degrees = axis.degrees.clamp(10.0, 360.0);

    /// We are shifting arc angles to center it horizontally.
    final angleShift = (degrees - 180) / 2;
    final gaugeDegreesTween = Tween<double>(
      begin: -180.0 - angleShift,
      end: 0.0 + angleShift,
    );

    final circleCenter = layout.circleRect.center;

    final thickness = axis.style.thickness;
    final halfThickness = thickness / 2;

    /// Can be helpful for multiple axes support.
    // final from = (axis.min - min) / (max - min);
    const from = 0.0;
    final startAngle = gaugeDegreesTween.transform(from);

    // final to = (axis.max - min) / (max - min);
    const to = 1.0;
    final endAngle = gaugeDegreesTween.transform(to);

    final innerRadius = clampedRadius - thickness;
    final centerRadius = clampedRadius - halfThickness;
    final outerRadius = clampedRadius;

    final cornerAngle = getArcAngle(halfThickness, centerRadius);

    final axisStartAngle = toRadians(startAngle) + cornerAngle;
    final axisEndAngle = toRadians(endAngle) - cornerAngle;

    final startOuterPoint =
        getPointOnCircle(circleCenter, axisStartAngle, outerRadius);
    final endOuterPoint =
        getPointOnCircle(circleCenter, axisEndAngle, outerRadius);
    final endInnerPoint =
        getPointOnCircle(circleCenter, axisEndAngle, innerRadius);
    final startInnerPoint =
        getPointOnCircle(circleCenter, axisStartAngle, innerRadius);

    final axisSurface = Path()
      ..moveTo(startOuterPoint.dx, startOuterPoint.dy)
      ..arcToPoint(
        endOuterPoint,
        largeArc: degrees > 180.0 - halfThickness,
        radius: Radius.circular(outerRadius),
      )
      ..arcToPoint(
        endInnerPoint,
        radius: Radius.circular(halfThickness),
      )
      ..arcToPoint(
        startInnerPoint,
        largeArc: degrees > 180.0 + halfThickness * 2,
        radius: Radius.circular(innerRadius),
        clockwise: false,
      )
      ..arcToPoint(
        startOuterPoint,
        radius: Radius.circular(halfThickness),
      );

    final axisRect = Rect.fromCircle(
      center: layout.targetRect.topCenter + Offset(0.0, clampedRadius),
      radius: centerRadius,
    );

    return GaugeAxisDefinition(
      surface: axisSurface,
      rect: axisRect,
      thickness: thickness,
      segments: _calculateAxisSegments(
        gaugeDegreesTween,
        centerRadius,
      ).toList(),
    );
  }

  GaugeLayout _layout(Size size, GaugeSizeRatios ratios) {
    final sourceRect = Offset.zero & size;

    if (!sourceRect.isFinite) {
      throw StateError(
        'Wrap a gauge widget with a SizedBox.',
      );
    }

    final targetSize = applyAspectRatio(sourceRect, ratios.aspectRatio);

    /// Cannot draw larger indicator than available space
    final clampedRadius = ratios.getRadius(targetSize);

    /// Rect of a visible gauge part
    final targetRect = alignment.inscribe(targetSize, sourceRect);

    /// Gauge circle rect
    final circleRect = Rect.fromCircle(
      center: targetRect.topCenter + Offset(0.0, clampedRadius),
      radius: clampedRadius,
    );

    return GaugeLayout(
      circleRect: circleRect,
      targetRect: targetRect,
      sourceRect: sourceRect,
      radius: clampedRadius,
    );
  }

  @override
  void performLayout() {
    final ratios = _calculateSizeRatios();

    final radiusBasedSize = radius != null
        ? Size(radius! * 2, ratios.getHeight(radius! * 2))
        : null;

    if (constraints.isTight) {
      size = constraints.smallest;
    } else if (constraints.hasTightHeight) {
      final height = constraints.minHeight;
      size = constraints.constrain(radiusBasedSize ??
          Size(
            ratios.getWidth(height),
            height,
          ));
    } else if (constraints.hasTightWidth) {
      final width = constraints.minWidth;
      size = constraints.constrain(radiusBasedSize ??
          Size(
            width,
            ratios.getHeight(width),
          ));
    } else {
      size = constraints.constrain(radiusBasedSize ?? Size.zero);
    }

    _computedLayout = _layout(size, ratios);
    _axisDefinition = _calculateAxisDefinition(_computedLayout);

    if (child != null) {
      final innerCircleRadius =
          (_computedLayout.radius - axis.style.thickness) / 2 * math.sqrt2;
      final circleRect = Rect.fromCircle(
        center: _computedLayout.circleRect.center,
        radius: innerCircleRadius,
      );
      final childRect = circleRect.intersect(_computedLayout.targetRect);
      final innerCircleConstraints = BoxConstraints.loose(childRect.size);
      final verticalAligment =
          1 - (((childRect.height / circleRect.height) - 0.5) * 2);

      child!.layout(innerCircleConstraints, parentUsesSize: true);
      final childParentData = child!.parentData! as BoxParentData;
      final alignedChildRect =
          Alignment(0.0, verticalAligment).inscribe(child!.size, childRect);
      childParentData.offset = Offset(
        alignedChildRect.left - _computedLayout.sourceRect.left,
        alignedChildRect.top - _computedLayout.sourceRect.top,
      );
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);

    /// No space, nothing to paint.
    if (size.isEmpty) return;

    if (_axisDefinition.needsRecalculation) {
      _axisDefinition = _calculateAxisDefinition(_computedLayout);
    }

    final canvas = context.canvas;
    final layout = _computedLayout.shift(offset);
    final axisDefinition = _axisDefinition.shift(offset);

    assert(() {
      if (debug) {
        canvas.drawRect(
          layout.sourceRect,
          Paint()..color = Colors.blue.withOpacity(0.1),
        );
        canvas.drawRect(
          layout.targetRect,
          Paint()..color = Colors.red.withOpacity(0.1),
        );
        canvas.drawRect(
          layout.circleRect,
          Paint()..color = Colors.green.withOpacity(0.1),
        );
      }
      return true;
    }(), 'Debug view');

    canvas.save();
    canvas.clipPath(axisDefinition.surface);

    final paint = Paint()
      ..color = axis.style.background ?? Colors.transparent
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    canvas.drawPath(axisDefinition.surface, paint);

    for (var i = 0; i < axisDefinition.segments.length; i++) {
      final segment = axisDefinition.segments[i];

      final paint = Paint()
        ..strokeWidth = axisDefinition.thickness
        ..color = segment.color
        ..style = PaintingStyle.stroke;

      canvas.drawArc(
        axisDefinition.rect,
        segment.startAngle,
        segment.sweepAngle,
        false,
        paint,
      );
    }
    canvas.restore();

    /// Draw a pointer

    final pointer = axis.pointer;
    if (pointer != null) {
      final degrees = axis.degrees.clamp(10.0, 360.0);

      final center = axisDefinition.center;
      final innerRadius = axisDefinition.radius - axisDefinition.thickness / 2;

      final progress = value / max;
      final rotation = progress * degrees - degrees / 2;
      final transformation = rotateOverOrigin(
        matrix: Matrix4.translationValues(
          center.dx,
          center.dy - innerRadius,
          0.0,
        ),
        origin: Offset(0.0, innerRadius),
        rotation: toRadians(rotation),
      );

      final path = pointer.path.transform(transformation.storage);

      final fillPaint = Paint()
        ..color = pointer.backgroundColor
        ..style = PaintingStyle.fill;

      canvas.drawPath(path, fillPaint);

      final border = pointer.border;
      if (border != null && border.width > 0) {
        final strokePaint = Paint()
          ..strokeWidth = math.max(border.width, 0)
          ..color = border.color
          ..style = PaintingStyle.stroke;
        canvas.drawPath(path, strokePaint);
      }
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('min', min));
    properties.add(DoubleProperty('max', max));
    properties.add(DoubleProperty('value', value));
    properties.add(DiagnosticsProperty<GaugeAxis>('axis', axis));
    properties.add(DiagnosticsProperty<bool>('debug', debug));
    properties.add(DoubleProperty('radius', radius));
  }
}
