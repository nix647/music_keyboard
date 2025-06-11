import 'package:flutter/material.dart';
import '../utils/note_definitions.dart';
import 'key_widget.dart';
import '../services/midi_manager.dart';

class KeyboardWidget extends StatefulWidget {
  final double widthScale;
  final double heightScale;

  const KeyboardWidget({
    this.widthScale = 1.0,
    this.heightScale = 1.0,
    super.key,
  });

  @override
  State<KeyboardWidget> createState() => _KState();
}

class _KState extends State<KeyboardWidget> {

  @override
  Widget build(BuildContext ctx) => LayoutBuilder(
        builder: (ctx, c) {
          // Calculate the desired size of the keyboard based on scale factors.
          final keyboardWidth = c.maxWidth * widget.widthScale;
          final keyboardHeight = c.maxHeight * widget.heightScale;

          // Calculate individual key sizes based on the new keyboard dimensions.
          final whiteW = keyboardWidth / whiteRow.length;
          final blackW = whiteW * 1;
          final blackH = keyboardHeight * .55;

          // Center the keyboard within the available space.
          return Center(
            child: SizedBox(
              width: keyboardWidth,
              height: keyboardHeight,
              child: Stack(
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
              ),
            ),
          );
        },
      );
}
