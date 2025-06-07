import 'package:flutter/material.dart';
import 'widgets/keyboard_widget.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext ctx) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: SafeArea(child: const KeyboardWidget())),
      );
}