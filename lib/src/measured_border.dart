part of '../measured.dart';

enum MeasuredBorder {
  top,
  left,
  bottom,
  right;

  static get topLeft => <MeasuredBorder>[top, left];
  static get bottomRight => <MeasuredBorder>[bottom, right];
  static get all => <MeasuredBorder>[top, left, bottom, right];
  static get none => <MeasuredBorder>[];
}

extension DoubleExtensions on double {
  get radians => this * (pi / 180.0);
  get degrees => this * (180.0 / pi);
}

///
extension WidgetExtensions on Widget {
  Widget measured({
    List<MeasuredBorder>? borders,
    Color? backgroundColor,
    double? width,
    Color? color,
    double? padding,
    TextStyle? style,
    bool? outlined,
    void Function(Size size)? onChanged,
  }) =>
      Measured(
        borders: borders,
        backgroundColor: backgroundColor,
        color: color,
        width: width,
        padding: padding,
        style: style,
        outlined: outlined,
        onChanged: onChanged,
        child: this,
      );
}
