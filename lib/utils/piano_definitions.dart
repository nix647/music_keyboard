import 'note_definitions.dart';

const pianoWhiteRow = <NoteDef>[
  NoteDef('E3', 52, KeyColor.white),
  NoteDef('F3', 53, KeyColor.white),
  NoteDef('G3', 55, KeyColor.white),
  NoteDef('A3', 57, KeyColor.white),
  NoteDef('B3', 59, KeyColor.white),
  NoteDef('C4', 60, KeyColor.white),
  NoteDef('D4', 62, KeyColor.white),
  NoteDef('E4', 64, KeyColor.white),
  NoteDef('F4', 65, KeyColor.white),
  NoteDef('G4', 67, KeyColor.white),
  NoteDef('A4', 69, KeyColor.white),
  NoteDef('B4', 71, KeyColor.white),
  NoteDef('C5', 72, KeyColor.white),
];

const pianoBlackKeys = <NoteDef>[
  NoteDef('', 54, KeyColor.black, anchor: 1), // F#3 after F3
  NoteDef('', 56, KeyColor.black, anchor: 2), // G#3 after G3
  NoteDef('', 58, KeyColor.black, anchor: 3), // A#3 after A3
  NoteDef('', 61, KeyColor.black, anchor: 5), // C#4 after C4
  NoteDef('', 63, KeyColor.black, anchor: 6), // D#4 after D4
  NoteDef('', 66, KeyColor.black, anchor: 8), // F#4 after F4
  NoteDef('', 68, KeyColor.black, anchor: 9), // G#4 after G4
  NoteDef('', 70, KeyColor.black, anchor: 10), // A#4 after A4
];
