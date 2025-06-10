import 'package:flutter/material.dart';
import '../utils/quadrant_note_definitions.dart';
import 'quadrant_key_widget.dart';
import '../services/midi_manager.dart';

class QuadrantKeyboardWidget extends StatefulWidget {
  final double widthScale;
  final double heightScale;

  const QuadrantKeyboardWidget({
    this.widthScale = 1.0,
    this.heightScale = 1.0,
    super.key,
  });

  @override
  State<QuadrantKeyboardWidget> createState() => _QuadrantKeyboardWidgetState();
}

class _QuadrantKeyboardWidgetState extends State<QuadrantKeyboardWidget> {
  @override
  void initState() {
    super.initState();
    MidiManager().init();
  }

  @override
  Widget build(BuildContext ctx) => LayoutBuilder(
        builder: (ctx, c) {
          final keyboardWidth = c.maxWidth * widget.widthScale;
          final keyboardHeight = c.maxHeight * widget.heightScale;

          return Center(
            child: SizedBox(
              width: keyboardWidth,
              height: keyboardHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final def in quadrantKeys)
                    Expanded(
                      child: QuadrantKeyWidget(def),
                    ),
                ],
              ),
            ),
          );
        },
      );
}
