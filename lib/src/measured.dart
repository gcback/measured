part of measured;

class Measured extends SingleChildRenderObjectWidget {
  const Measured({
    Key? key,
    this.border,
    this.backgroundColor,
    this.lineWidth,
    this.lineColor,
    this.padding,
    this.style,
    this.bOutlinedBorder,
    this.onSizeChanged,
    required Widget child,
  }) : super(
          key: key,
          child: child,
        );

  /// Specifies border style.
  final MeasuredBorder? border;

  /// Measured widget's background color.
  final Color? backgroundColor;

  /// Text style to draw in the center of mesaured line.
  final TextStyle? style;

  /// Mesaured line's stroke width.
  final double? lineWidth;

  /// Mesaured line's color.
  final Color? lineColor;

  /// Length off the child's boundary to mesaured lines.
  final double? padding;

  /// Should be visible of the rectangle of box which warp a child.
  final bool? bOutlinedBorder;

  /// Called when a child;s size changes.
  final void Function(Size size)? onSizeChanged;

  @override
  RenderObject createRenderObject(BuildContext context) {
    final theme = Theme.of(context).textTheme.displayMedium!;

    return _RenderSizeReporter(
      border: border ??
          MeasuredBorder(
            top: MeasuredBorderSide(
                color: lineColor ?? theme.color, padding: padding),
            left: MeasuredBorderSide(
                color: lineColor ?? theme.color, padding: padding),
          ),
      backgroundColor: backgroundColor,
      style: style ?? theme.copyWith(fontSize: 10.0),
      lineWidth: lineWidth ?? 0.75,
      lineColor: lineColor ?? theme.color!,
      padding: padding ?? 12.0,
      bOutlinedBorder: bOutlinedBorder ?? false,
      onSizeChanged: onSizeChanged,
    );
  }
}

enum _MeasuredSide {
  top,
  left,
  bottom,
  right,
}

class _RenderSizeReporter extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  _RenderSizeReporter({
    required this.border,
    required this.backgroundColor,
    required this.style,
    required this.lineWidth,
    required this.lineColor,
    required this.padding,
    required this.bOutlinedBorder,
    required this.onSizeChanged,
  });

  final MeasuredBorder border;
  final Color? backgroundColor;

  final TextStyle style;
  final double lineWidth;
  final Color lineColor;
  final double padding;
  final bool bOutlinedBorder;
  final void Function(Size)? onSizeChanged;

  Size? oldSize;

  @override
  void performLayout() {
    if (child != null) {
      child!.layout(constraints, parentUsesSize: true);
      size = constraints.constrain(child!.size);
    } else {
      size = Size.zero;
    }

    /// Schedules the execution of the registered callback[onSizeChanged] after the frame build is complete.
    if (oldSize != size) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onSizeChanged?.call(size);
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

      final canvas = context.canvas;
      final rect = offset & size;
      Rect localRect;

      /// Measured widget has a Colored plane if any [backgroundColor].
      if (backgroundColor != null) {
        canvas.drawRect(
          rect,
          linePainter
            ..color = backgroundColor!
            ..style = PaintingStyle.fill,
        );
      }

      /// Draw a rectangle which meets child's size.
      if (bOutlinedBorder) {
        canvas.drawRect(
          rect,
          linePainter
            ..color = lineColor
            ..strokeWidth = lineWidth
            ..style = PaintingStyle.stroke,
        );
      }

      /// Draw measured line at top.
      ///
      /// Ex)
      ///    |<----- 125.05 ----->|
      ///    |                    |
      ///           ~ ~ ~
      ///    |                    |
      ///
      if (border.top != null) {
        localRect =
            rect.topLeft & Size(size.width, border.top!.padding ?? padding * 2);

        final textSize = drawMeasuredText(
          canvas,
          rect.width.toStringAsFixed(2),
          localRect.center,
        );

        linePainter.color = border.top!.color ?? lineColor;
        linePainter.strokeWidth = border.top!.lineWidth;

        drawMeasuredLine(
          canvas,
          localRect.centerLeft,
          localRect.center - Offset(textSize.width / 2 + 4.0, 0),
          _MeasuredSide.left,
        );
        drawMeasuredLine(
          canvas,
          localRect.center + Offset(textSize.width / 2 + 4.0, 0),
          localRect.centerRight,
          _MeasuredSide.right,
        );
      }

      // Draw measured line at left.
      if (border.left != null) {
        localRect = rect.topLeft &
            Size(border.left!.padding ?? padding * 2, size.height);

        final textSize = drawMeasuredText(
          canvas,
          rect.height.toStringAsFixed(2),
          localRect.center + Offset(border.left!.padding ?? padding, 0.0),
        );

        linePainter.color = border.left!.color ?? lineColor;
        linePainter.strokeWidth = border.left!.lineWidth;

        drawMeasuredLine(
          canvas,
          localRect.topCenter,
          localRect.center - Offset(0.0, textSize.height / 2 + 4.0),
          _MeasuredSide.top,
        );
        drawMeasuredLine(
          canvas,
          localRect.center + Offset(0.0, textSize.height / 2 + 4.0),
          localRect.bottomCenter,
          _MeasuredSide.bottom,
        );
      }

      /// Draw measured line at right.
      if (border.right != null) {
        localRect = (rect.topRight &
                Size(border.right!.padding ?? padding * 2, size.height))
            .translate(-(border.right!.padding ?? padding * 2), 0.0);

        final textSize = drawMeasuredText(
          canvas,
          rect.height.toStringAsFixed(2),
          localRect.center + Offset(-(border.right!.padding ?? padding), 0.0),
        );

        linePainter.color = border.right!.color ?? lineColor;
        linePainter.strokeWidth = border.right!.lineWidth;

        drawMeasuredLine(
          canvas,
          localRect.topCenter,
          localRect.center - Offset(0.0, textSize.height / 2 + 4.0),
          _MeasuredSide.top,
        );
        drawMeasuredLine(
          canvas,
          localRect.center + Offset(0.0, textSize.height / 2 + 4.0),
          localRect.bottomCenter,
          _MeasuredSide.bottom,
        );
      }

      /// Draw measured line at bottom.
      if (border.bottom != null) {
        localRect = (rect.bottomLeft &
                Size(size.width, border.bottom!.padding ?? padding * 2))
            .translate(0.0, -(border.bottom!.padding ?? padding * 2));

        final textSize = drawMeasuredText(
          canvas,
          rect.width.toStringAsFixed(2),
          localRect.center,
        );

        linePainter.color = border.bottom!.color ?? lineColor;
        linePainter.strokeWidth = border.bottom!.lineWidth;

        drawMeasuredLine(
          canvas,
          localRect.centerLeft,
          localRect.center - Offset(textSize.width / 2 + 4.0, 0.0),
          _MeasuredSide.left,
        );
        drawMeasuredLine(
          canvas,
          localRect.center + Offset(textSize.width / 2 + 4.0, 0.0),
          localRect.centerRight,
          _MeasuredSide.right,
        );
      }
    }
  }

  /// Lines are drawn on both sides of the text.
  /// 
  ///   - Each line touches the boundary of the maxAxis.
  drawMeasuredLine(Canvas canvas, Offset a, Offset b, _MeasuredSide side) {
    canvas.drawLine(a, b, linePainter);

    final (a0, a1, middle) = switch (side) {
      == _MeasuredSide.left => (
          a + Offset.fromDirection(-30.0.radians, 8.0),
          a + Offset.fromDirection(30.0.radians, 8.0),
          a
        ),
      == _MeasuredSide.right => (
          b + Offset.fromDirection((-180.0 + 30.0).radians, 8.0),
          b + Offset.fromDirection((180.0 - 30.0).radians, 8.0),
          b
        ),
      == _MeasuredSide.top => (
          a + Offset.fromDirection(60.0.radians, 8.0),
          a + Offset.fromDirection((-180.0 - 60.0).radians, 8.0),
          a,
        ),
      == _MeasuredSide.bottom => (
          b + Offset.fromDirection(-60.0.radians, 8.0),
          b + Offset.fromDirection((-90.0 - 30.0).radians, 8.0),
          b,
        ),
      _ => (Offset.zero, Offset.zero, Offset.zero),
    };

    /// Draw a symbol; '⋀', '⋁', '<', '>'.

    canvas.drawLine(a0, middle, linePainter);
    canvas.drawLine(a1, middle, linePainter);
  }

  /// Draw a text with alignment and positioned at textOffset.
  Size drawMeasuredText(
    Canvas canvas,
    String text,
    Offset textOffset, [
    TextAlign textAlign = TextAlign.center,
  ]) {
    textPainter
      ..text = TextSpan(text: text, style: style)
      ..textAlign = textAlign
      ..layout();

    final offset = switch (textAlign) {
      TextAlign.center => Offset(
          textOffset.dx - textPainter.width / 2,
          textOffset.dy - textPainter.height / 2,
        ),
      TextAlign.left => Offset(
          textOffset.dx,
          textOffset.dy - textPainter.height / 2,
        ),
      _ => textOffset,
    };

    textPainter.paint(canvas, offset);
    return Size(textPainter.width, textPainter.height);
  }
}
