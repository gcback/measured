# Measured

This widget displays the actual width and height every time the size of the child widget changes.

### Introduction

- We can check how the size changes when the screen layout or the arrangement of widgets changes
- Conversely, we can determine the appropriate size on the screen and use it as a reference for UX and UI design.
- We can register a callback to be executed when the size of a child widget changes.
###
# Getting started

In your library add the following import:

```dart
import 'package:measured/measured.dart';
```

Then you just have to add a `Measured` which wrap a `child` to that wraps around the widget whose size change you want to monitor.

```dart
final controller = AnimationController(vsync: this);
...
...
Measured(
  child: SizedBox(
    width: 100.0 + 50.0 * controller.value,
    height:100.0 + 50.0 * (1 - controller.value),
    child: Container(
      color: Colors.red,
    ),
  ),
)
```

### Parameters

#### border
- Specify the left, right, top, and bottom where the size will be displayed.

#### onSizeChanged
- Executes the registered callback every time the size of the child widget changes.

#### bOutlinedBorder
- Draws a rectangular border that fits the size of the child widget.

#### lineWidth, lineColor
- Measuring line's stroke width and color
#### padding
- Specify the gap between the location where the size will be displayed and the border.

###
# Changelog
- Please check the Changelog page to know what's recently changed.


###
# Contributions
Feel free to contribute to this project.

If you find a bug or want a feature, but don't know how to fix/implement it, please fill an [issue]().
If you fixed a bug or implemented a feature, please send a [pull request]().
