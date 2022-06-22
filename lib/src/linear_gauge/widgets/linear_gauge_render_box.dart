import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gauge_indicator/src/linear_gauge/data/linear_gauge_segment.dart';
import 'package:gauge_indicator/src/linear_gauge/data/thumb_style.dart';

import 'package:gauge_indicator/src/utils/rrect_to_path.dart';

class LinearGaugeRenderBox extends RenderBox {
  double _value;
  double get value => _value;
  set value(double value) {
    if (_value != value) {
      _value = value;
      markNeedsPaint();
    }
  }

  int _max;
  int get max => _max;
  set max(int max) {
    if (_max != max) {
      _max = max;
      markNeedsPaint();
    }
  }

  double _cornerRadius;
  double get cornerRadius => _cornerRadius;
  set cornerRadius(double cornerRadius) {
    if (_cornerRadius != cornerRadius) {
      _cornerRadius = cornerRadius;
      markNeedsPaint();
    }
  }

  double _separatorThickness;
  double get separatorThickness => _separatorThickness;
  set separatorThickness(double separatorThickness) {
    if (_separatorThickness != separatorThickness) {
      _separatorThickness = separatorThickness;
      markNeedsPaint();
    }
  }

  double _minimumSegmentThickness;
  double get minimumSegmentThickness => _minimumSegmentThickness;
  set minimumSegmentThickness(double minimumSegmentThickness) {
    if (_minimumSegmentThickness != minimumSegmentThickness) {
      _minimumSegmentThickness = minimumSegmentThickness;
      markNeedsPaint();
    }
  }

  double _verticalSegmentMargin;
  double get verticalSegmentMargin => _verticalSegmentMargin;
  set verticalSegmentMargin(double verticalSegmentMargin) {
    if (_verticalSegmentMargin != verticalSegmentMargin) {
      _verticalSegmentMargin = verticalSegmentMargin;
      markNeedsPaint();
    }
  }

  Color _backgroundColor;
  Color get backgroundColor => _backgroundColor;
  set backgroundColor(Color backgroundColor) {
    if (_backgroundColor != backgroundColor) {
      _backgroundColor = backgroundColor;
      markNeedsPaint();
    }
  }

  ThumbStyle _thumbStyle;
  ThumbStyle get thumbStyle => _thumbStyle;
  set thumbStyle(ThumbStyle thumbStyle) {
    if (_thumbStyle != thumbStyle) {
      _thumbStyle = thumbStyle;
      markNeedsPaint();
    }
  }

  List<LinearGaugeSegment> _segments;
  List<LinearGaugeSegment> get segments => _segments;
  set segments(List<LinearGaugeSegment> segments) {
    if (_segments != segments) {
      _segments = segments;
      markNeedsPaint();
    }
  }

  double _height;
  double get height => _height;
  set height(double height) {
    if (_height != height) {
      _height = height;
      markNeedsPaint();
    }
  }

  LinearGaugeRenderBox({
    required double value,
    required int max,
    required double separatorThickness,
    required double verticalSegmentMargin,
    required double cornerRadius,
    required double minimumSegmentThickness,
    required double height,
    Color foregroundColor = const Color.fromRGBO(39, 197, 102, 1),
    Color backgroundColor = const Color.fromRGBO(217, 222, 235, 1),
    ThumbStyle thumbStyle = const ThumbStyle(),
    required List<LinearGaugeSegment> segments,
  })  : _value = value,
        _max = max,
        _cornerRadius = cornerRadius,
        _separatorThickness = separatorThickness,
        _verticalSegmentMargin = verticalSegmentMargin,
        _minimumSegmentThickness = minimumSegmentThickness,
        _backgroundColor = backgroundColor,
        _thumbStyle = thumbStyle,
        _segments = segments,
        _height = height,
        assert(max > 0, 'max must be greater than 0'),
        assert(value >= 0 && value <= max, 'Value must be >=0 and <= max'),
        assert(segments.isNotEmpty, 'At least one segment must be defined'),
        assert(height > 0, 'Height must be bigger than 0'),
        assert(verticalSegmentMargin >= 0, 'Vertical margin cant be zero'),
        assert(
          height > verticalSegmentMargin * 2,
          'Height must be bigger than margins, so that segments are visible',
        ),
        assert(value <= max, 'Value should not exceed maximum');

  @override
  void performLayout() {
    size = constraints.constrainDimensions(
      double.infinity,
      height,
    );
  }

  Path _generateSegmentsCutout(
    Offset thumbLeftCenterPoint,
    Offset thumbFullHorizontalOffset,
  ) {
    final separatorCount = _max;

    final separatorsPath = Path();
    for (var i = 0; i < separatorCount - 1; i++) {
      if (i == value - 1) continue;
      final separatorFraction = (i + 1) / separatorCount;

      separatorsPath.addRect(
        Rect.fromCenter(
          center: thumbLeftCenterPoint +
              Offset.lerp(
                Offset.zero,
                thumbFullHorizontalOffset,
                separatorFraction,
              )!,
          width: _separatorThickness,
          height: size.height,
        ),
      );
    }
    return separatorsPath;
  }

  Path _createThumbCutout(RRect thumbRRect) {
    final cutoutRRect = thumbRRect.inflate(thumbStyle.strokeWidth);
    return rRectToPath(cutoutRRect);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (size.isEmpty) return;

    final canvas = context.canvas;
    final outerBoundingBox = offset & size;

    // full width of bounding box as offset
    final fullHorizontalOffset = Offset(size.width, 0);
    final centerPoint = outerBoundingBox.center;
    final centerLeft = outerBoundingBox.centerLeft;

    // segments are placed along this axis,
    // its same as above just shrunk by thumb width
    final halfThumbWidth = (thumbStyle.thickness + thumbStyle.strokeWidth) / 2;
    final thumbFullHorizontalOffset =
        fullHorizontalOffset - Offset(halfThumbWidth * 2, 0);
    final thumbLeftCenterPoint = centerLeft + Offset(halfThumbWidth, 0);

    //bounding box of bar, thumb is bigger than this
    final innerBoundingBox = Rect.fromCenter(
      center: centerPoint,
      width: size.width,
      height: size.height - verticalSegmentMargin * 2,
    );

    final roundedInnerBoundingRect = RRect.fromRectAndRadius(
      innerBoundingBox,
      Radius.circular(cornerRadius),
    );

    canvas.save();

    final thumbLerpFraction = value / _max;
    final thumbRect = Rect.fromCenter(
      center: thumbLeftCenterPoint +
          Offset.lerp(
            Offset.zero,
            thumbFullHorizontalOffset,
            thumbLerpFraction,
          )!,
      width: thumbStyle.thickness,
      height: size.height,
    );
    final thumbRRect = RRect.fromRectAndRadius(
      thumbRect,
      Radius.circular(thumbStyle.thickness / 2),
    );

    bool isSeparatorDensityExceeded() {
      if (minimumSegmentThickness == 0) return false;
      final separatorCount = _max - 1;
      final overallSeparatorWidth = separatorThickness * separatorCount;
      final singleSegmentWidth = (size.width - overallSeparatorWidth) / _max;
      return _minimumSegmentThickness > singleSegmentWidth;
    }

    //create cutouts if density ok
    final skipSeparators = isSeparatorDensityExceeded();
    Path? separatorsPath;
    if (!skipSeparators) {
      separatorsPath = _generateSegmentsCutout(
        thumbLeftCenterPoint,
        thumbFullHorizontalOffset,
      );
    }

    Path thumbPath = _createThumbCutout(thumbRRect);
    final rectPath = rRectToPath(roundedInnerBoundingRect);
    final boundingRectWithoutThumb = Path.combine(
      PathOperation.difference,
      rectPath,
      thumbPath,
    );

    //merge separators with rounded rect detailsMask if needed
    final Path detailsMask;
    if (separatorsPath != null) {
      detailsMask = Path.combine(
        PathOperation.difference,
        boundingRectWithoutThumb,
        separatorsPath,
      );
    } else {
      detailsMask = boundingRectWithoutThumb;
    }

    //apply clip
    canvas.clipPath(detailsMask);

    //grey background
    final backgroundPaint = Paint()
      ..color = _backgroundColor
      ..style = PaintingStyle.fill;

    // since the corners and background separators are clipped simply draw rect
    canvas.drawRect(
      innerBoundingBox,
      backgroundPaint,
    );

    // render visible segments
    if (segments.length == 1) {
      final segmentPaint = Paint()
        ..color = segments.first.color
        ..style = PaintingStyle.fill;
      final widthFraction = _value.clamp(0, max) / max;
      final barRect = offset & Size(size.width * widthFraction, size.height);
      canvas.drawRect(barRect, segmentPaint);
    } else {
      for (int i = 0; i < segments.length; i++) {
        final segment = segments[i];

        final from = segments[i].start.toDouble();
        final double to;
        if (i + 1 >= segments.length) {
          // `to` can be potentially infinite with current assumption,
          // so cap it at maximum of either value or max possible value
          to = math.max(max.toDouble(), value.toDouble());
        } else {
          // to is capped at beginning of the next segment
          to = segments[i + 1].start.toDouble();
        }

        final visibleSpan = math.min(to, value) - from;

        // skip invisible part
        if (value < from) continue;
        if (visibleSpan == 0) continue;

        // segment width is calculated depending on visible bar count,
        // since inner bars are shifted depending on thumb width,
        // there has to be added width so that first and last segment reaches
        // the desired bound
        final double additionalWidth;
        if (from == 0 && to == max) {
          additionalWidth = halfThumbWidth * 2;
        } else if (from == 0 || to == max) {
          additionalWidth = halfThumbWidth;
        } else {
          additionalWidth = 0;
        }
        // inner segment should account for
        // thumb margin and previous segment width
        final Offset startOffset;
        if (from == 0) {
          startOffset = centerLeft;
        } else {
          final previousSegmentWidth =
              thumbFullHorizontalOffset.dx * from / max.toDouble();
          startOffset =
              centerLeft + Offset(halfThumbWidth + previousSegmentWidth, 0);
        }
        final segmentWidth = additionalWidth +
            thumbFullHorizontalOffset.dx * visibleSpan / max.toDouble();

        final segmentRect = startOffset - Offset(0, size.height / 2) &
            Size(segmentWidth, size.height);
        final segmentPaint = Paint()
          ..color = segment.color
          ..style = PaintingStyle.fill;
        canvas.drawRect(segmentRect, segmentPaint);
      }
    }
    // go back to full bounding box and draw thumb
    canvas.restore();

    //draw thumb
    final thumbPaint = Paint()
      ..color = thumbStyle.color
      ..style = PaintingStyle.fill;

    canvas.drawRRect(thumbRRect, thumbPaint);
  }
}
