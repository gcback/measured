import 'dart:math';
import 'package:align_positioned/align_positioned.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:measured/measured.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends HookWidget {
  const HomePage({super.key});

  static String title = 'Home';

  @override
  Widget build(BuildContext context) {
    final controller =
        useAnimationController(duration: const Duration(seconds: 1));
    final align = useMemoized(() {
      return controller.drive(
          AlignmentTween(begin: Alignment.topRight, end: Alignment.bottomLeft));
    });
    useAnimation(align);
    final length = useState('');

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return Measured(
                  child: Container(
                    width: 300.0 + 80.0 * controller.value,
                    height: 400.0 + 150.0 * controller.value,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AlignPositioned(
                          alignment: align.value,
                          child: Transform.rotate(
                            angle: controller.value * 2 * pi,
                            child: Measured(
                              backgroundColor: Colors.green.withAlpha(120),
                              lineColor: Colors.yellow,
                              lineWidth: 5.0,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.bold),
                              bOutlinedBorder: true,
                              onSizeChanged: (size) {
                                length.value = size.toString();
                              },
                              child: SizedBox(
                                width: 150.0 + 100 * controller.value,
                                height: 100.0 + 100 * (1 - controller.value),
                                child: const FlutterLogo(),
                              ),
                            ),
                          ),
                        ),
                        AlignPositioned(
                          alignment: Alignment.bottomRight,
                          child: Measured(
                            bOutlinedBorder: true,
                            child: SizedBox(
                              width: 150.0 + 60.0 * (1 - controller.value),
                              height: 80.0 + 30.0 * (1 - controller.value),
                              child: const FlutterLogo(),
                            ),
                          ),
                        ),
                        AlignPositioned(
                          alignment: Alignment.center,
                          child: Text(length.value.toString(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (controller.isAnimating) {
            controller.stop();
          } else {
            controller.repeat(
              reverse: true,
              period: const Duration(seconds: 1),
            );
          }
        },
        child: Icon(
            controller.isAnimating ? Icons.pause : Icons.play_arrow_rounded),
      ),
    );
  }
}
