import 'package:flutter/material.dart';
import 'package:gauge_indicator/src/linear_gauge/data/linear_gauge_segment.dart';
import 'package:gauge_indicator/src/linear_gauge/data/thumb_style.dart';
import 'package:gauge_indicator/src/linear_gauge/widgets/linear_gauge_render_box.dart';

class LinearGauge extends LeafRenderObjectWidget {
  /// Value of the gauge, for special cases we allow doubles
  final double value;

  /// Maximum value constrained to integer for special edge case evasion
  final int max;

  /// How rounded are supposed to be the corners
  final double cornerRadius;

  /// Width of separators dividing bar into individual segments
  final double separatorThickness;

  /// How much space do you want on the vertical axis of segments,
  /// does not affect thumb height
  final double verticalSegmentMargin;

  /// You can prevent widget from displaying dividers
  /// when there is a lot of very thin segments,
  /// if segment is thinner than this value, no separators will
  /// be rendered
  final double minimumSegmentThickness;

  /// You can specify the desired height of the widget
  final double height;

  /// Color of the full width background rect
  final Color backgroundColor;

  ///Allows styling the gauge thumb
  final ThumbStyle thumbStyle;

  /// You can define many color ranges on the axis,
  /// if you do not pass any semgent here it will put one by default
  final List<LinearGaugeSegment> segments;

  const LinearGauge({
    required this.value,
    required this.max,
    this.cornerRadius = 8.0,
    this.separatorThickness = 2,
    this.verticalSegmentMargin = 2,
    this.minimumSegmentThickness = 0,
    this.height = 48,
    this.backgroundColor = const Color.fromRGBO(217, 222, 235, 1),
    this.thumbStyle = const ThumbStyle(),
    this.segments = const [LinearGaugeSegment()],
    Key? key,
  }) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) => LinearGaugeRenderBox(
        value: value,
        max: max,
        cornerRadius: cornerRadius,
        separatorThickness: separatorThickness,
        verticalSegmentMargin: verticalSegmentMargin,
        minimumSegmentThickness: minimumSegmentThickness,
        height: height,
        backgroundColor: backgroundColor,
        thumbStyle: thumbStyle,
        segments: segments,
      );

  @override
  void updateRenderObject(
      BuildContext context, covariant LinearGaugeRenderBox renderObject) {
    renderObject
      ..value = value
      ..max = max
      ..cornerRadius = cornerRadius
      ..separatorThickness = separatorThickness
      ..verticalSegmentMargin = verticalSegmentMargin
      ..minimumSegmentThickness = minimumSegmentThickness
      ..backgroundColor = backgroundColor
      ..thumbStyle = thumbStyle
      ..segments = segments;
  }
}
