import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/keyboard_widget.dart';
import 'widgets/piano_widget.dart';
import 'widgets/quadrant_keyboard_widget.dart';
import 'widgets/buttoned_keyboard.dart'; // Import the new keyboard
import 'services/midi_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Allow either landscape side
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Load the sound font once at startup
  await MidiManager().init();

  runApp(const App());
}

// Enum to manage the different keyboard modes
enum KeyboardMode { piano, pentatonic, quadrant, buttoned }

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
  KeyboardMode _mode = KeyboardMode.pentatonic;
  double _widthScale = 1.0;
  double _heightScale = 1.0;

  void _cycleKeyboard() {
    setState(() {
      final nextIndex = (_mode.index + 1) % KeyboardMode.values.length;
      _mode = KeyboardMode.values[nextIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget keyboardArea;
    switch (_mode) {
      case KeyboardMode.piano:
        keyboardArea = const PianoWidget();
        break;
      case KeyboardMode.pentatonic:
        keyboardArea = KeyboardWidget(
          widthScale: _widthScale,
          heightScale: _heightScale,
        );
        break;
      case KeyboardMode.quadrant:
        keyboardArea = QuadrantKeyboardWidget(
          widthScale: _widthScale,
          heightScale: _heightScale,
        );
        break;
      case KeyboardMode.buttoned:
        keyboardArea = const ButtonedKeyboardWidget();
        break;
    }

    // Determine if the sliders should be visible
    final showSliders = _mode == KeyboardMode.pentatonic || _mode == KeyboardMode.quadrant;


    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: keyboardArea,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.flip_camera_android),
                      tooltip: 'Switch Keyboard',
                      onPressed: _cycleKeyboard,
                    ),
                  ),
                ],
              ),
            ),
            if (showSliders) _buildControlSliders(),
          ],
        ),
      ),
    );
  }

  Widget _buildControlSliders() {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          const Text('Width:', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Slider(
              value: _widthScale,
              min: 0.1,
              max: 1.0,
              divisions: 9,
              label: _widthScale.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  _widthScale = value;
                });
              },
            ),
          ),
          const SizedBox(width: 24),
          const Text('Height:', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Slider(
              value: _heightScale,
              min: 0.1,
              max: 1.0,
              divisions: 9,
              label: _heightScale.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  _heightScale = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
