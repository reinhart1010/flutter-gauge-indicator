import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
class GaugePointerBorder extends Equatable {
  final Color color;
  final double width;

  const GaugePointerBorder({
    required this.color,
    required this.width,
  }) : assert(width > 0, 'Width must be larger than 0.');

  @override
  List<Object?> get props => [color, width];
}

@immutable
abstract class GaugePointer extends Equatable {
  Path get path;
  Color get backgroundColor;

  /// When null, the pointer border will not be rendered.
  GaugePointerBorder? get border;

  @override
  List<Object?> get props => [backgroundColor, border];
}
