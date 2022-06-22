import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gauge_indicator/gauge_indicator.dart';

class AnimatedLinearGauge extends ImplicitlyAnimatedWidget {
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

  const AnimatedLinearGauge({
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
    required Duration duration,
    Curve curve = Curves.linear,
    VoidCallback? onEnd,
    Key? key,
  }) : super(
          key: key,
          duration: duration,
          curve: curve,
          onEnd: onEnd,
        );

  @override
  AnimatedWidgetBaseState<AnimatedLinearGauge> createState() =>
      _AnimatedLinearGaugeState();
}

class _AnimatedLinearGaugeState
    extends AnimatedWidgetBaseState<AnimatedLinearGauge> {
  Tween<double>? _valueTween;

  @override
  void initState() {
    super.initState();
    controller
      ..value = 0.0
      ..forward();
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _valueTween = visitor(
      _valueTween,
      widget.value,
      (_) => Tween<double>(
        begin: 0,
        end: widget.value,
      ),
    ) as Tween<double>;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Builder(builder: (context) {
        final value =
            _valueTween!.evaluate(animation).clamp(0, widget.max).toDouble();

        return LinearGauge(
          value: value,
          max: widget.max,
          cornerRadius: widget.cornerRadius,
          separatorThickness: widget.separatorThickness,
          verticalSegmentMargin: widget.verticalSegmentMargin,
          minimumSegmentThickness: widget.minimumSegmentThickness,
          height: widget.height,
          backgroundColor: widget.backgroundColor,
          thumbStyle: widget.thumbStyle,
          segments: widget.segments,
        );
      }),
    );
  }
}
