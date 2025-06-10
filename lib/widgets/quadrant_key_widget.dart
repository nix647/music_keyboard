import 'package:flutter/material.dart';
import '../services/midi_manager.dart';
import '../utils/quadrant_note_definitions.dart';

final MidiManager _audio = MidiManager();

class QuadrantKeyWidget extends StatefulWidget {
  final QuadrantNoteDef def;
  const QuadrantKeyWidget(this.def, {super.key});

  @override
  State<QuadrantKeyWidget> createState() => _QuadrantKeyWidgetState();
}

class _QuadrantKeyWidgetState extends State<QuadrantKeyWidget> {
  final List<bool> _pressed = List.filled(9, false);
  int? _lastPlayedMidi;
  // Use a map to track which pointer ID is touching which quadrant
  final Map<int, int> _pointerToQuadrant = {};

  void _onPointerDown(int quadrantIndex, PointerDownEvent event) {
    // Stop any previously playing note from this key
    if (_lastPlayedMidi != null) {
      _audio.noteOff(_lastPlayedMidi!);
    }

    final midi = widget.def.getMidi(quadrantIndex);
    _audio.noteOn(midi, event.pressure.clamp(0.75, 1.0));
    _lastPlayedMidi = midi;
    _pointerToQuadrant[event.pointer] = quadrantIndex; // Track pointer

    setState(() {
      // Only one quadrant can be pressed at a time per key
      _pressed.fillRange(0, _pressed.length, false);
      _pressed[quadrantIndex] = true;
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    // Check if this pointer was the one that triggered a note
    if (_pointerToQuadrant.containsKey(event.pointer)) {
      if (_lastPlayedMidi != null) {
        _audio.noteOff(_lastPlayedMidi!);
        _lastPlayedMidi = null;
      }
      setState(() {
         final quadrantIndex = _pointerToQuadrant[event.pointer];
         if(quadrantIndex != null){
            _pressed[quadrantIndex] = false;
         }
      });
      _pointerToQuadrant.remove(event.pointer); // Untrack pointer
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
     if (_pointerToQuadrant.containsKey(event.pointer)) {
      if (_lastPlayedMidi != null) {
        _audio.noteOff(_lastPlayedMidi!);
        _lastPlayedMidi = null;
      }
      setState(() {
         final quadrantIndex = _pointerToQuadrant[event.pointer];
         if(quadrantIndex != null){
            _pressed[quadrantIndex] = false;
         }
      });
      _pointerToQuadrant.remove(event.pointer);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 0.5),
          color: Colors.white, // Changed from grey to white
        ),
        child: Column(
          children: List.generate(3, (row) {
            return Expanded(
              child: Row(
                children: List.generate(3, (col) {
                  final index = row * 3 + col;
                  return Expanded(
                    child: Listener(
                      onPointerDown: (e) => _onPointerDown(index, e),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 50),
                        decoration: BoxDecoration(
                          color: _pressed[index]
                              ? Colors.blue[300]
                              : Colors.transparent,
                          border: Border.all(color: Colors.black.withOpacity(0.3), width: 0.5)
                        ),
                        alignment: Alignment.center,
                        child: (index == 4)
                            ? Text(
                                widget.def.label,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }
}
