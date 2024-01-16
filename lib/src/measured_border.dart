part of measured;

/// Specifies the position to display the size of the child widget,
///   and requires specifying [MeasuredBorderSide] for necessary information.
///
/// MeasuredBorder
class MeasuredBorder {
  const MeasuredBorder({
    this.top,
    this.left,
    this.right,
    this.bottom,
  });

  final MeasuredBorderSide? top;
  final MeasuredBorderSide? bottom;
  final MeasuredBorderSide? left;
  final MeasuredBorderSide? right;
}

class MeasuredBorderSide {
  const MeasuredBorderSide({
    this.color = Colors.white,
    this.lineWidth = 0.65,
    this.padding = 12.0,
  });

  // tapeline color
  final Color? color;

  // tapeline stroke line lineWidth
  final double lineWidth;

  // length off the child's boundary to tapeline
  final double? padding;

  MeasuredBorderSide copyWith({
    Color? color,
    double? lineWidth,
    double? padding,
  }) =>
      MeasuredBorderSide(
        color: color ?? this.color,
        lineWidth: lineWidth ?? this.lineWidth,
        padding: padding ?? this.padding,
      );
  // static const MeasuredBorderSide none = MeasuredBorderSide();
}

extension DoubleExtensions on double {
  get radians => this * (pi / 180.0);
  get degrees => this * (180.0 / pi);
}
