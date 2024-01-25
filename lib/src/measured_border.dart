part of measured;

/// Specifies the position to display the size of the child widget,
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
    this.padding = 24.0,
  });

  /// measured line color
  final Color? color;

  /// measured line's stroke width
  final double lineWidth;

  /// length off the child's boundary to mesaured lines
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
}

extension DoubleExtensions on double {
  get radians => this * (pi / 180.0);
  get degrees => this * (180.0 / pi);
}

///
extension WidgetExtensions on Widget {
  Widget measured({
    MeasuredBorder? border,
    Color? backgroundColor,
    double? lineWidth,
    Color? lineColor,
    double? padding,
    TextStyle? style,
    bool? bOutlinedBorder,
    void Function(Size size)? onSizeChanged,
  }) =>
      Measured(
        border: border,
        backgroundColor: backgroundColor,
        lineColor: lineColor,
        lineWidth: lineWidth,
        padding: padding,
        style: style,
        bOutlinedBorder: bOutlinedBorder,
        onSizeChanged: onSizeChanged,
        child: this,
      );
}
