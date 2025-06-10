import 'note_definitions.dart';

class QuadrantNoteDef {
  final String label;
  final int midiRoot; // The MIDI note for the center-center quadrant

  const QuadrantNoteDef(this.label, this.midiRoot);

  // Returns the MIDI note for a given quadrant (0-8)
  int getMidi(int quadrantIndex) {
    // Quadrant layout:
    // 0 1 2
    // 3 4 5
    // 6 7 8
    int octaveOffset = 0;
    if (quadrantIndex < 3) {
      octaveOffset = 12; // One octave up
    } else if (quadrantIndex > 5) {
      octaveOffset = -12; // One octave down
    }

    int semitoneOffset = 0;
    final col = quadrantIndex % 3;
    if (col == 0) {
      semitoneOffset = -1; // Left column (flat)
    } else if (col == 2) {
      semitoneOffset = 1; // Right column (sharp)
    }

    return midiRoot + octaveOffset + semitoneOffset;
  }
}

// Defines the 5 keys for the pentatonic quadrant keyboard.
const quadrantKeys = <QuadrantNoteDef>[
  QuadrantNoteDef('1', 60), // C4
  QuadrantNoteDef('2', 62), // D4
  QuadrantNoteDef('3', 64), // E4
  QuadrantNoteDef('5', 67), // G4
  QuadrantNoteDef('6', 69), // A4
];
