// lib/widgets/key_widget.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/note_definitions.dart';
import '../services/midi_manager.dart';

final MidiManager _audio = MidiManager();

class KeyWidget extends StatefulWidget {
  final NoteDef def;
  const KeyWidget(this.def, {super.key});

  @override
  State<KeyWidget> createState() => _KeyWidgetState();
}

class _KeyWidgetState extends State<KeyWidget> {
  bool   _pressed    = false;
  bool   _hasPlayed  = false;   // whether a note already sounded this gesture
  Offset? _start;
  Timer? _downTimer;
  int    _midiNow    = 0;

  // ── helpers ───────────────────────────────────────
  void _play(int midi, double p) {
    if (_hasPlayed) return;                // guard: only once per gesture
    _audio.noteOn(midi, p.clamp(0.75, 1.0));
    _midiNow   = midi;
    _hasPlayed = true;
  }

  void _stop() {
    _downTimer?.cancel();
    if (_midiNow != 0) _audio.noteOff(_midiNow);
    _midiNow   = 0;
  }

  // ── pointer handlers ─────────────────────────────
  void _onDown(PointerDownEvent e) {
    _pressed    = true;
    _hasPlayed  = false;
    _start      = e.position;
    // schedule original note after 100 ms if no slide occurs
    _downTimer = Timer(kPressDelay, () {
      if (!_hasPlayed) _play(widget.def.midi, e.pressure);
    });
    setState(() {});
  }

  void _onMove(PointerMoveEvent e) {
    if (!_pressed || _hasPlayed || _start == null) return;
    final d = e.position - _start!;

    int octave = 0;
    int semi   = 0;

    if (d.dy <= -kSlideSensitivity) octave =  12;   // up
    else if (d.dy >=  kSlideSensitivity) octave = -12; // down

    if (d.dx <= -kSlideSensitivity) semi = -1;      // left
    else if (d.dx >=  kSlideSensitivity) semi =  1; // right

    if (octave != 0 || semi != 0) {
      _downTimer?.cancel();            // cancel delayed tap
      _play(widget.def.midi + octave + semi, e.pressure);
    }
  }

  void _onUp(PointerEvent _) {
    _stop();
    _pressed   = false;
    _hasPlayed = false;
    setState(() {});
  }

  // ── build ─────────────────────────────────────────
  @override
  Widget build(BuildContext ctx) {
    final isWhite = widget.def.color == KeyColor.white;
    final fill = _pressed
        ? (isWhite ? Colors.blue[200]! : const Color.fromARGB(255, 0, 145, 208)!)
              : (isWhite ? Colors.white : const Color.fromARGB(255, 0, 46, 171)!);

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _onDown,
      onPointerMove: _onMove,
      onPointerUp:   _onUp,
      onPointerCancel: _onUp,
      child: Container(
        decoration: BoxDecoration(
          color: fill,
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: isWhite ? null : BorderRadius.circular(4),
        ),
        alignment: Alignment.bottomCenter,
        child: Text(
          widget.def.label,
          style: TextStyle(
            fontSize: isWhite ? 22 : 18,
            color: isWhite ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}   