import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:gauge_indicator/src/utils/lerp_double.dart';

@immutable
class GaugeSegment extends Equatable {
  final double from;
  final double to;
  final Color color;

  const GaugeSegment({
    required this.from,
    required this.to,
    required this.color,
  });

  GaugeSegment copyWith({
    final double? from,
    final double? to,
    final Color? color,
  }) =>
      GaugeSegment(
        from: from ?? this.from,
        to: to ?? this.to,
        color: color ?? this.color,
      );

  static GaugeSegment lerp(GaugeSegment begin, GaugeSegment end, double t) =>
      GaugeSegment(
        from: lerpDouble(begin.from, end.from, t),
        to: lerpDouble(begin.to, end.to, t),
        color: Color.lerp(begin.color, end.color, t)!,
      );

  @override
  List<Object?> get props => [from, to, color];
}
