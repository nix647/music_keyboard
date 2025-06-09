import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/keyboard_widget.dart';
import 'widgets/piano_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Allow either landscape side
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext ctx) => MaterialApp(
        debugShowCheckedModeBanner: false,
        // ⬇️ force‑rotate UI if OS is still portrait
        builder: (context, child) {
          final orientation = MediaQuery.of(context).orientation;
          if (orientation == Orientation.portrait) {
            // rotate 90° clockwise so the widgets are laid out wide
            return RotatedBox(quarterTurns: 1, child: child);
          }
          return child!;
        },
        home: const HomePage(),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _piano = false;
  void _toggle() => setState(() => _piano = !_piano);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: _piano ? const PianoWidget()
                              : const KeyboardWidget(),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.flip_camera_android),
                  tooltip: 'Switch Keyboard',
                  onPressed: _toggle,
                ),
              ),
            ],
          ),
        ),
      );
}
