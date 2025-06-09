import 'package:flutter/material.dart';
import '../utils/note_definitions.dart';
import 'key_widget.dart';
import '../services/midi_manager.dart';

class KeyboardWidget extends StatefulWidget {
  const KeyboardWidget({super.key});
  @override State<KeyboardWidget> createState() => _KState();
}

class _KState extends State<KeyboardWidget> {
  @override void initState() { super.initState(); MidiManager().init(); }

  @override
  Widget build(BuildContext ctx) => LayoutBuilder(
        builder: (ctx, c) {
          final w = c.maxWidth;
          final h = c.maxHeight;
          final whiteW = w / whiteRow.length;
          final blackW = whiteW * 1;
          final blackH = h * .55;
          return Stack(
            children: [
              // white layer
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final def in whiteRow)
                    SizedBox(width: whiteW, child: KeyWidget(def)),
                ],
              ),
              // black layer
              for (final def in blackKeys)
                Positioned(
                  left: whiteW * def.anchor + whiteW - blackW / 2,
                  width: blackW,
                  height: blackH,
                  child: KeyWidget(def),
                ),
            ],
          );
        },
      );
}