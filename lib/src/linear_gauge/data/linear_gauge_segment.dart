import 'package:flutter/material.dart';

class LinearGaugeSegment {
  /// You do not define ending value of the segment directly,
  /// it will continue till next segment or to max value
  final int start;

  /// Color of the segment
  final Color color;

  const LinearGaugeSegment({
    this.start = 0,
    this.color = const Color.fromRGBO(39, 197, 102, 1),
  });

  @override
  String toString() => 'Start: $start, color: $color';
}
