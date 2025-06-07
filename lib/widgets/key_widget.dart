import 'package:flutter/material.dart';
import '../utils/note_definitions.dart';
import '../services/midi_manager.dart';

typedef PressureCb = void Function(double p);

final MidiManager audioManager = MidiManager();   // ✅ a singleton variable

class KeyWidget extends StatelessWidget {
  final NoteDef def;
  const KeyWidget(this.def, {super.key});

  @override
  Widget build(BuildContext ctx) {
    final isWhite = def.color == KeyColor.white;
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (e) => _down(e.pressure),
      onPointerMove: (e) => _down(e.pressure),
      onPointerUp: (_) => _up(),
      onPointerCancel: (_) => _up(),
      child: Container(
        decoration: BoxDecoration(
          color: isWhite ? Colors.white : Colors.grey[800],
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: isWhite ? null : BorderRadius.circular(4),
        ),
        alignment: Alignment.bottomCenter,
        child: Text(def.label,
            style: TextStyle(
              fontSize: isWhite ? 22 : 18,
              color: isWhite ? Colors.black : Colors.white,
            )),
      ),
    );
  }

  void _down(double p) => audioManager.noteOn(def.midi, p);
  void _up() => audioManager.noteOff(def.midi);
}