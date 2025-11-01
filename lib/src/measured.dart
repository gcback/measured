part of '../measured.dart';

class Measured extends SingleChildRenderObjectWidget {
  const Measured({
    super.key,
    this.borders,
    this.backgroundColor,
    this.width,
    this.color,
    this.padding,
    this.style,
    this.outlined,
    this.onChanged,
    required Widget super.child,
  });

  /// Specifies border style.
  final List<MeasuredBorder>? borders;

  /// Measured widget's background color.
  final Color? backgroundColor;

  /// Text style to draw in the center of mesaured line.
  final TextStyle? style;

  /// Mesaured line's stroke width.
  final double? width;

  /// Mesaured line's color.
  final Color? color;

  /// Length off the child's boundary to mesaured lines.
  final double? padding;

  /// Should be visible of the rectangle of box which warp a child.
  final bool? outlined;

  /// Called when a child;s size changes.
  final void Function(Size size)? onChanged;

  @override
  RenderObject createRenderObject(BuildContext context) {
    final theme = Theme.of(context).textTheme.displayMedium!;

    return RenderSizeReporter(
      borders: borders ?? MeasuredBorder.topLeft,
      backgroundColor: backgroundColor,
      style: style ?? theme.copyWith(fontSize: 12.0),
      width: width ?? 0.65,
      color: color ?? theme.color!,
      padding: padding ?? 12.0,
      outlined: outlined ?? true,
      onChanged: onChanged,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderSizeReporter renderObject,
  ) {
    // assert(borders != null, '[borders] should not be null');

    renderObject
      ..borders = borders ?? MeasuredBorder.topLeft
      ..backgroundColor = backgroundColor
      ..color = color
      ..padding = padding
      ..width = width
      ..style = style
      ..outlined = outlined
      ..onChanged = onChanged;
  }
}

class RenderSizeReporter extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  RenderSizeReporter({
    required List<MeasuredBorder> borders,
    Color? backgroundColor,
    required bool outlined,
    required double padding,
    required TextStyle style,
    required double width,
    required Color color,
    required void Function(Size)? onChanged,
  })  : _borders = borders,
        _outlined = outlined,
        _backgroundColor = backgroundColor,
        _color = color,
        _padding = padding,
        _width = width,
        _style = style,
        _onChanged = onChanged;

  List<MeasuredBorder> _borders;
  bool _outlined;
  Color? _backgroundColor;
  TextStyle _style;
  double _width;
  Color _color;
  double _padding;
  void Function(Size)? _onChanged;

  set style(TextStyle? value) {
    if (value != null) {
      _style = value;
      markNeedsPaint();
    }
  }

  set padding(double? value) {
    if (value != null) {
      _padding = value;
      markNeedsPaint();
    }
  }

  set width(double? value) {
    if (value != null) {
      _width = value;
      markNeedsPaint();
    }
  }

  set backgroundColor(Color? value) {
    if (value != null) {
      _backgroundColor = value;
      markNeedsPaint();
    }
  }

  set color(Color? value) {
    if (value != null) {
      _color = value;
      markNeedsPaint();
    }
  }

  set borders(List<MeasuredBorder>? value) {
    if (value != null) {
      _borders = value;
      markNeedsPaint();
    }
  }

  set outlined(bool? value) {
    if (value != null) {
      _outlined = value;
      markNeedsPaint();
    }
  }

  set onChanged(void Function(Size)? value) {
    if (value != null) {
      _onChanged = value;
      markNeedsPaint();
    }
  }

  ///

  Size? oldSize;

  @override
  void performLayout() {
    if (child != null) {
      child!.layout(constraints, parentUsesSize: true);
      size = constraints.constrain(child!.size);
    } else {
      size = Size.zero;
    }

    /// Schedules the execution of the registered callback[onChanged]
    ///   after the frame build is complete.
    if (oldSize != size) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onChanged?.call(size);
      });
      oldSize = size;
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (size.contains(position)) {
      return child!.hitTest(result, position: position);
    }
    return false;
  }

  final linePainter = Paint();

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      context.paintChild(child!, offset);

      final canvas = context.canvas;
      final rect = offset & size;

      /// Measured widget has a Colored plane if any [backgroundColor].
      if (_backgroundColor != null) {
        canvas.drawRect(
          rect,
          linePainter
            ..color = _backgroundColor!
            ..style = PaintingStyle.fill,
        );
      }

      /// Draw a rectangle which meets child's size If any [outlined]
      if (_outlined) {
        canvas.drawRect(
          rect,
          linePainter
            ..color = _color
            ..strokeWidth = _width
            ..style = PaintingStyle.stroke,
        );
      }

      /// [borders] == null, call a onChaned if any
      if (_borders.isEmpty) return;

      /// Draw measured line and length value at top, left, bottom, right.
      ///
      ///   start                end
      ///    |<----- 125.05 ----->|
      ///    |                    |
      ///           ~ ~ ~
      ///    |                    |

      /// set common properties: line's width, color, padding etc
      linePainter.color = _color;
      linePainter.strokeWidth = _width;

      final textPainter = TextPainter()
        ..textDirection = TextDirection.ltr
        ..textAlign = TextAlign.center;

      Rect measuredRect;
      Offset textPadding;
      String text;
      Alignment textAlignment;
      Offset start, end;

      for (final side in _borders) {
        switch (side) {
          case MeasuredBorder.top:
          case MeasuredBorder.bottom:
            measuredRect = (side == MeasuredBorder.top)
                ? Alignment.topLeft
                    .inscribe(Size(size.width, _padding * 2), rect)
                : Alignment.bottomLeft
                    .inscribe(Size(size.width, _padding * 2), rect);
            text = rect.width.toStringAsFixed(2);
            textAlignment = Alignment.center;

            drawMeasuredText(
                canvas, textPainter, text, measuredRect, textAlignment);

            textPadding = Offset(textPainter.size.width / 2 + 4.0, 0);
            start = measuredRect.centerLeft;
            end = measuredRect.centerRight;

          case MeasuredBorder.left:
          case MeasuredBorder.right:
            measuredRect = (side == MeasuredBorder.left)
                ? Alignment.topLeft
                    .inscribe(Size(_padding * 2, size.height), rect)
                : Alignment.topRight
                    .inscribe(Size(_padding * 2, size.height), rect);
            text = ' ${rect.height.toStringAsFixed(2)} ';
            textAlignment = (side == MeasuredBorder.left)
                ? Alignment.centerLeft
                : Alignment.centerRight;

            drawMeasuredText(
                canvas, textPainter, text, measuredRect, textAlignment);

            textPadding = Offset(0.0, textPainter.size.height / 2 + 4.0);

            start = measuredRect.topCenter;
            end = measuredRect.bottomCenter;
        }

        drawMeasuredLine(
            canvas,
            start,
            measuredRect.center - textPadding,
            side == MeasuredBorder.top || side == MeasuredBorder.bottom
                ? MeasuredBorder.left
                : MeasuredBorder.top);
        drawMeasuredLine(
            canvas,
            measuredRect.center + textPadding,
            end,
            side == MeasuredBorder.top || side == MeasuredBorder.bottom
                ? MeasuredBorder.right
                : MeasuredBorder.bottom);
      }

      textPainter.dispose();
    }
  }

  /// Lines are drawn on both sides of the text.
  ///
  ///   - Each line touches the boundary of the maxAxis.
  drawMeasuredLine(Canvas canvas, Offset a, Offset b, MeasuredBorder side) {
    canvas.drawLine(a, b, linePainter);

    final (start, end, center) = switch (side) {
      == MeasuredBorder.left => (
          a + Offset.fromDirection(-30.0.radians, 8.0),
          a + Offset.fromDirection(30.0.radians, 8.0),
          a
        ),
      == MeasuredBorder.right => (
          b + Offset.fromDirection((-180.0 + 30.0).radians, 8.0),
          b + Offset.fromDirection((180.0 - 30.0).radians, 8.0),
          b
        ),
      == MeasuredBorder.top => (
          a + Offset.fromDirection(60.0.radians, 8.0),
          a + Offset.fromDirection((-180.0 - 60.0).radians, 8.0),
          a,
        ),
      == MeasuredBorder.bottom => (
          b + Offset.fromDirection(-60.0.radians, 8.0),
          b + Offset.fromDirection((-90.0 - 30.0).radians, 8.0),
          b,
        ),
      _ => (Offset.zero, Offset.zero, Offset.zero),
    };

    /// Draw a symbol; '⋀', '⋁', '<', '>'.
    canvas.drawLine(start, center, linePainter);
    canvas.drawLine(end, center, linePainter);
  }

  /// Draw a text with alignment and positioned at textOffset.
  void drawMeasuredText(
    Canvas canvas,
    TextPainter textPainter,
    String text,
    Rect rect,
    Alignment alignment,
  ) {
    textPainter
      ..text = TextSpan(text: text, style: _style)
      ..layout();

    /// Get the position Offset where the text will be placed in the [rect].
    final offset = alignment.inscribe(textPainter.size, rect).topLeft;

    /// Paints the text and releases the resources of the [textPainter] object.
    textPainter.paint(canvas, offset);
  }
}
