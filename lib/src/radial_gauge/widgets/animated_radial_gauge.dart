import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gauge_indicator/gauge_indicator.dart';

typedef GaugeLabelBuilder = Widget Function(
  BuildContext context,
  Widget? child,
  double value,
);

/// Animated [RadialGauge] widget.
class AnimatedRadialGauge extends ImplicitlyAnimatedWidget {
  /// The value from which the widget animation will start to [value].
  final double initialValue;
  final double min;
  final double max;
  final double value;
  final GaugeAxis axis;
  final Alignment alignment;
  final bool debug;
  final double? radius;
  final Widget? child;
  final GaugeLabelBuilder builder;

  const AnimatedRadialGauge({
    Key? key,
    this.initialValue = 0.0,
    required Duration duration,
    required this.min,
    required this.max,
    required this.value,
    required this.builder,
    this.axis = const GaugeAxis(),
    Curve curve = Curves.linear,
    this.alignment = Alignment.center,
    this.radius,
    this.debug = false,
    this.child,
    VoidCallback? onEnd,
  }) : super(
          key: key,
          duration: duration,
          curve: curve,
          onEnd: onEnd,
        );

  @override
  AnimatedWidgetBaseState<AnimatedRadialGauge> createState() =>
      _AnimatedRadialGaugeState();
}

class _AnimatedRadialGaugeState
    extends AnimatedWidgetBaseState<AnimatedRadialGauge> {
  bool _isInitialAnimation = true;

  Tween<double>? _valueTween;
  GaugeAxisTween? _axisTween;

  @override
  void initState() {
    super.initState();
    controller
      ..value = 0.0
      ..forward().whenCompleteOrCancel(() {
        _isInitialAnimation = false;
      });
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _axisTween = visitor(
      _axisTween,
      widget.axis,
      (dynamic value) => GaugeAxisTween(
        begin: value as GaugeAxis,
        end: value,
      ),
    ) as GaugeAxisTween;
    _valueTween = visitor(
      _valueTween,
      widget.value,
      (dynamic value) => Tween<double>(
        begin: widget.initialValue,
        end: widget.value,
      ),
    ) as Tween<double>;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Builder(
        builder: (context) {
          final value =
              _valueTween!.evaluate(animation).clamp(widget.min, widget.max);
          final computedAxis = _axisTween!.evaluate(animation)!.flatten();

          final axis = computedAxis.transform(
            range: GaugeRange(widget.min, widget.max),
            progress: controller.value,
            value: value,
            isInitial: _isInitialAnimation,
          );

          return RadialGauge(
            debug: widget.debug,
            value: value,
            max: widget.max,
            min: widget.min,
            radius: widget.radius,
            alignment: widget.alignment,
            axis: axis,
            child: widget.builder(context, widget.child, value),
          );
        },
      ),
    );
  }
}
