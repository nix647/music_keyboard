import 'package:flutter/material.dart';
import '../utils/piano_definitions.dart';
import 'key_widget.dart';
import '../services/midi_manager.dart';

class PianoWidget extends StatefulWidget {
  const PianoWidget({super.key});
  @override
  State<PianoWidget> createState() => _PState();
}

class _PState extends State<PianoWidget> {

  @override
  Widget build(BuildContext ctx) => LayoutBuilder(
        builder: (ctx, c) {
          final w = c.maxWidth;
          final h = c.maxHeight;
          final whiteW = w / pianoWhiteRow.length;
          final blackW = whiteW * 0.7;
          final blackH = h * .55;
          return Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final def in pianoWhiteRow)
                    SizedBox(width: whiteW, child: KeyWidget(def, enableSliding: false)),
                ],
              ),
              for (final def in pianoBlackKeys)
                Positioned(
                  left: whiteW * def.anchor + whiteW - blackW / 2,
                  width: blackW,
                  height: blackH,
                  child: KeyWidget(def, enableSliding: false),
                ),
            ],
          );
        },
      );
}
