import 'package:align_positioned/align_positioned.dart';
import 'package:measured/measured.dart';
import 'package:mylib/mylib.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      // showPerformanceOverlay: false,
      home: HomePage(),
    );
  }
}

class HomePage extends HookWidget {
  const HomePage({super.key});

  static String title = 'Home';

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(duration: 1.secs);
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
                              child: Material(
                                child: Ink.image(
                                  width: 150.0 + 100 * controller.value,
                                  height: 100.0 + 100 * (1 - controller.value),
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                    8.image('nature'),
                                  ),
                                  child: const InkWell(
                                    onTap: noop,
                                  ),
                                ),
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
                              child: Image.network(
                                19.image('nature'),
                                fit: BoxFit.cover,
                              ),
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
            const Gap(32.0),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (controller.isAnimating) {
            controller.stop();
          } else {
            controller.repeat(reverse: true);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// class DD extends StatelessWidget {
//   const DD({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = AnimationController(vsync: this);
//     ...
//     ...
//     Measured(
//       child: SizedBox(
//         width: 100.0 + 50.0 * controller.value,
//         height:100.0 + 50.0 * (1 - controller.value),
//         child: Container(
//           color: Colors.red,
//         ),
//       ),
//     );
//   }
// }
