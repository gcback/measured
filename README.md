# Measured

This widget displays the actual width and height every time the size of the child widget changes.

| ![image](https://github.com/gcback/measured/assets/10203092/728bc126-6a8e-423b-8ebd-56e085c41f14) | ![agif](https://github.com/gcback/measured/assets/10203092/b6366afc-78dc-4464-8e5f-c1d4863dd855) |
| ------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |

###

# Introduction

- We can check how the size changes when the screen layout or the arrangement of widgets changes
- Conversely, we can determine the appropriate size on the screen and use it as a reference for UX and UI design.
- We can register a callback to be executed when the size of a child widget changes.

###

# Getting started

In your library add the following import:

```dart
import 'package:measured/measured.dart';
```

Then you just have to add a `Measured` which wrap a `child` widget whose size change you want to monitor.

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

or
...
/// using in Widget extension
SizedBox(
    width: 100.0 + 50.0 * controller.value,
    height:100.0 + 50.0 * (1 - controller.value),
    child: Container(
      color: Colors.red,
    ),
  ).measured(
    borders: const [
      MeasuredBorder.right,
      MeasuredBorder.bottom,
    ],
    onChanged(
      () => {}
    ),
  )
```

### Parameters

#### borders

- Specify the left, right, top, and bottom where the size will be displayed.
- If not set, the default value is **[MeasuredBorder.top, MeasuredBorder.left]**, in shortly **MeasuredBorder.topleft**.

#### onChanged

- Executes the registered callback every time the size of the child widget changes.

#### outlined

- Draws a rectangular border that fits the size of the child widget.

#### width, color

- Measuring line's stroke width and color

#### padding

- Specify the gap between the location where the size will be displayed and the border.

###

# Changelog

- Please check the [Changelog](https://pub.dev/packages/measured/changelog) page to know what's recently changed.

###

# Contributions

Feel free to contribute to this project.

If you find a bug or want a feature, but don't know how to fix/implement it, please fill an [issue](https://github.com/gcback/measured/issues).
If you fixed a bug or implemented a feature, please send a [pull request](https://github.com/gcback/measured/pulls).
