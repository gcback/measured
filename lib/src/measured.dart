part of measured;

class Measured extends SingleChildRenderObjectWidget {
  const Measured({
    Key? key,
    this.borders,
    this.backgroundColor,
    this.width,
    this.color,
    this.padding,
    this.style,
    this.outlined,
    this.onChanged,
    required Widget child,
  }) : super(
          key: key,
          child: child,
        );

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

    return _RenderSizeReporter(
      borders: borders, // ?? [MeasuredBorder.top, MeasuredBorder.left],
      backgroundColor: backgroundColor,
      style: style ?? theme.copyWith(fontSize: 12.0),
      width: width ?? 0.65,
      color: color ?? theme.color!,
      padding: padding ?? 12.0,
      outlined: outlined ?? false,
      onChanged: onChanged,
    );
  }
}

class _RenderSizeReporter extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  _RenderSizeReporter({
    required this.borders,
    required this.backgroundColor,
    required this.style,
    required this.width,
    required this.color,
    required this.padding,
    required this.outlined,
    required this.onChanged,
  });

  final List<MeasuredBorder>? borders;
  final Color? backgroundColor;

  final TextStyle style;
  final double width;
  final Color color;
  final double padding;
  final bool outlined;
  final void Function(Size)? onChanged;

  Size? oldSize;

  @override
  void performLayout() {
    if (child != null) {
      child!.layout(constraints, parentUsesSize: true);
      size = constraints.constrain(child!.size);
    } else {
      size = Size.zero;
    }

    /// Schedules the execution of the registered callback[onChanged] after the frame build is complete.
    if (oldSize != size) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onChanged?.call(size);
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

  final textPainter = TextPainter()..textDirection = TextDirection.ltr;
  final linePainter = Paint();

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      context.paintChild(child!, offset);

      /// [borders] == null, call a onChaned if any
      if (borders == null) return;

      final canvas = context.canvas;
      final rect = offset & size;

      /// Measured widget has a Colored plane if any [backgroundColor].
      if (backgroundColor != null) {
        canvas.drawRect(
          rect,
          linePainter
            ..color = backgroundColor!
            ..style = PaintingStyle.fill,
        );
      }

      /// Draw a rectangle which meets child's size If any [outlined]
      if (outlined) {
        canvas.drawRect(
          rect,
          linePainter
            ..color = color
            ..strokeWidth = width
            ..style = PaintingStyle.stroke,
        );
      }

      /// Draw measured line and length value at top, left, bottom, right.
      ///
      ///   start                end
      ///    |<----- 125.05 ----->|
      ///    |                    |
      ///           ~ ~ ~
      ///    |                    |

      /// set common properties: line's width, color, padding etc
      linePainter.color = color;
      linePainter.strokeWidth = width;

      Rect measuredRect;
      Offset textPadding;
      String text;
      Size textSize;
      TextAlign textAlign = TextAlign.center;
      Offset start, end;

      for (final side in borders!) {
        switch (side) {
          case MeasuredBorder.top:
          case MeasuredBorder.bottom:
            measuredRect = (side == MeasuredBorder.top)
                ? Alignment.topLeft
                    .inscribe(Size(size.width, padding * 2), rect)
                : Alignment.bottomLeft
                    .inscribe(Size(size.width, padding * 2), rect);

            text = rect.width.toStringAsFixed(2);
            textAlign = TextAlign.center;
            textSize = getTextSize(text, textAlign);
            textPadding = Offset(textSize.width / 2 + 4.0, 0);

            start = measuredRect.centerLeft;
            end = measuredRect.centerRight;

          case MeasuredBorder.left:
          case MeasuredBorder.right:
            measuredRect = (side == MeasuredBorder.left)
                ? Alignment.topLeft
                    .inscribe(Size(padding * 2, size.height), rect)
                : Alignment.topRight
                    .inscribe(Size(padding * 2, size.height), rect);

            text = rect.height.toStringAsFixed(2);
            textAlign = (side == MeasuredBorder.left)
                ? TextAlign.left
                : TextAlign.right;
            textSize = getTextSize(text, textAlign);
            textPadding = Offset(0.0, textSize.height / 2 + 4.0);

            start = measuredRect.topCenter;
            end = measuredRect.bottomCenter;
        }

        drawMeasuredText(canvas, text, measuredRect, textSize, textAlign);
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

  /// Get a area to drawing [text]
  Size getTextSize(String text, TextAlign textAlign) {
    textPainter
      ..text = TextSpan(text: text, style: style)
      ..textAlign = textAlign
      ..layout();

    return textPainter.size;
  }

  /// Draw a text with alignment and positioned at textOffset.
  void drawMeasuredText(
    Canvas canvas,
    String text,
    Rect rect,
    Size textSize, [
    TextAlign textAlign = TextAlign.center,
  ]) {
    /// only using in TextAlign.left or TextAlign.right
    final textPadding = padding * 0.5;

    final Rect(topLeft: offset) = switch (textAlign) {
      TextAlign.left => Alignment.centerLeft
          .inscribe(textSize, rect)
          .shift(Offset(textPadding, 0.0)),
      TextAlign.right => Alignment.centerRight
          .inscribe(textSize, rect)
          .shift(Offset(-textPadding, 0.0)),
      _ => Alignment.center.inscribe(textSize, rect),
    };

    textPainter.paint(canvas, offset);
  }
}
