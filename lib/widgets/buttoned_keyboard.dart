import 'dart:async';
import 'package:flutter/material.dart';
import '../services/midi_manager.dart';
import '../utils/buttoned_note_definitions.dart';
import '../utils/constants.dart';

final MidiManager _audio = MidiManager();

class ButtonedKeyboardWidget extends StatefulWidget {
  const ButtonedKeyboardWidget({super.key});

  @override
  State<ButtonedKeyboardWidget> createState() => _ButtonedKeyboardWidgetState();
}

class _ButtonedKeyboardWidgetState extends State<ButtonedKeyboardWidget> {
  // State for sliding and octave
  double _visualOffset = 0.0; // The single source of truth for the keyboard's visual position
  double _prevPos = 0.0; 
  int _octaveShift = 0; // -1 for down, 0 for middle, 1 for up
  bool _isSliding = false;

  // State for multi-touch and pitch modification
  // This map tracks active pointers to their note definitions and timers
  final Map<int, ({ButtonedNoteDef def, Timer? timer})> _activePointers = {};
  // This map tracks the final MIDI note that is actually playing for a given pointer
  final Map<int, int> _playingNotes = {}; 
  bool _sharpPressed = false;
  bool _flatPressed = false;


  void _playNoteForPointer(int pointerId) {
    if (!_activePointers.containsKey(pointerId)) return;

    final noteInfo = _activePointers[pointerId]!;
    noteInfo.timer?.cancel(); // Cancel any pending timer

    int semitoneShift = (_sharpPressed ? 1 : 0) - (_flatPressed ? 1 : 0);
    final midi = noteInfo.def.midi + (_octaveShift * -12) + semitoneShift; ////downward higher
    
    // If a note for this pointer is already playing, stop it first
    if (_playingNotes.containsKey(pointerId)) {
        _audio.noteOff(_playingNotes[pointerId]!);
    }

    _audio.noteOn(midi, 1.0);
    _playingNotes[pointerId] = midi;
    setState(() {});
  }
  
  void _updateAllPlayingNotes() {
     final notesToUpdate = Map<int, ({ButtonedNoteDef def, Timer? timer})>.from(_activePointers);
     notesToUpdate.forEach((pointerId, noteInfo) {
        // Only update notes that are already sounding
        if(_playingNotes.containsKey(pointerId)) {
          _playNoteForPointer(pointerId);
        }
     });
  }

  void _handleNoteDown(int pointerId, ButtonedNoteDef def) {
    final timer = Timer(kPressDelayB, () => _playNoteForPointer(pointerId));
    _activePointers[pointerId] = (def: def, timer: timer);
    setState(() {});
  }

  void _handleNoteUp(int pointerId) {
    if (_activePointers.containsKey(pointerId)) {
      _activePointers[pointerId]?.timer?.cancel();
      _activePointers.remove(pointerId);
    }
    if (_playingNotes.containsKey(pointerId)) {
      _audio.noteOff(_playingNotes[pointerId]!);
      _playingNotes.remove(pointerId);
    }
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (details) {
         if (_activePointers.isNotEmpty || _sharpPressed || _flatPressed) {
           _isSliding = true;
         }
      },
      onHorizontalDragUpdate: (details) {
        if (_isSliding) {
          setState(() {
            _visualOffset += details.delta.dx;
            double moveDist = _visualOffset - _prevPos;

            int newOctaveShift = _octaveShift;
            if (moveDist.abs() >= slideThreshold) {
              newOctaveShift += moveDist.sign.toInt() * (moveDist.abs() / slideThreshold).floor();
              newOctaveShift = newOctaveShift <= -1 ? -1 : newOctaveShift >= 1 ? 1 : 0;
            } 

            if (newOctaveShift != _octaveShift) {
                _octaveShift = newOctaveShift;
                _prevPos = newOctaveShift * slideThreshold;
            }
          });
        }
      },
      onHorizontalDragEnd: (details) {
        if (_isSliding) {
          _isSliding = false;
          setState(() {
            if (_octaveShift == 1) {
              _visualOffset = slideThreshold;
            } else if (_octaveShift == -1) {
              _visualOffset = -slideThreshold;
            } else {
              _visualOffset = 0;
            }
          });
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: Offset(_visualOffset, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildModifierBox(isFlat: true),
                const SizedBox(width: 40),
                _buildNoteButtons(),
                Transform.translate(
                  offset: const Offset(-20, 0),
                  child: _buildModifierBox(isFlat: false),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildModifierBox({required bool isFlat}) {
    final isPressed = isFlat ? _flatPressed : _sharpPressed;
    return Listener(
      onPointerDown: (event) {
        setState(() {
          if (isFlat) _flatPressed = true; else _sharpPressed = true;
           _updateAllPlayingNotes();
        });
      },
      onPointerUp: (event) {
        setState(() {
          if (isFlat) _flatPressed = false; else _sharpPressed = false;
          _updateAllPlayingNotes();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 204,
        height: 560,
        decoration: BoxDecoration(
          color: isPressed ? Colors.blue[300] : Colors.grey[300],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black54, width: 2),
           boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            isFlat ? 'b' : '#',
            style: const TextStyle(fontSize: 62, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildNoteButtons() {
    const buttonSize = 117.0;
    const hSpacing = 25.0; 
    const vSpacing = 40.0; // Wider vertical gap
    
    const totalWidth = (buttonSize * 3) + (hSpacing * 2) + (buttonSize / 2) + (hSpacing / 2);

    return SizedBox(
      width: totalWidth,
      height: (buttonSize * 2) + vSpacing,
      child: Stack(
        clipBehavior: Clip.none, 
        children: [
          // Bottom Row (1, 2, 3)
          Positioned(top: buttonSize + vSpacing, left: 0, child: _buildNoteButton(buttonedKeys[0])),
          Positioned(top: buttonSize + vSpacing, left: buttonSize + hSpacing, child: _buildNoteButton(buttonedKeys[1])),
          Positioned(top: buttonSize + vSpacing, left: (buttonSize + hSpacing) * 2, child: _buildNoteButton(buttonedKeys[2])),
          
          // Top Row (5, 6, 7) - Correct diagonal layout
          Positioned(top: 0, left: (buttonSize + hSpacing) * 0.3, child: _buildNoteButton(buttonedKeys[3])),
          Positioned(top: 0, left: (buttonSize + hSpacing) * 1.3, child: _buildNoteButton(buttonedKeys[4])),
          Positioned(top: 0, left: (buttonSize + hSpacing) * 2.3, child: _buildNoteButton(buttonedKeys[5])),
        ],
      ),
    );
  }

  Widget _buildNoteButton(ButtonedNoteDef def) {
    // A button is "active" if any pointer is currently on it, even if the sound is delayed
    final bool isActive = _activePointers.values.any((info) => info.def == def);
    
    String label = def.label;
    if (_octaveShift == -1) { //downward higher
      label = '˙\n${def.label}';
    } else if (_octaveShift == 1) {
      label = '${def.label}\n.';
    }

    return Listener(
      onPointerDown: (event) => _handleNoteDown(event.pointer, def),
      onPointerUp: (event) => _handleNoteUp(event.pointer),
      onPointerCancel: (event) => _handleNoteUp(event.pointer),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 117,
        height: 117,
        decoration: BoxDecoration(
          // Show pressed state if either the note is active OR the modifier is active while the note is playing
          color: (isActive || (_playingNotes.values.any((midi) => (midi%12) == (def.midi%12)) && (_sharpPressed || _flatPressed))) ? Colors.blue[300] : Colors.grey[300],
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isActive ? 0.1 : 0.3),
              spreadRadius: isActive ? 1 : 2,
              blurRadius: isActive ? 3 : 5,
              offset: isActive ? const Offset(0, 1) : const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
      ),
    );
  }
}
