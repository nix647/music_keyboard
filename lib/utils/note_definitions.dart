enum KeyColor { white, black }

class NoteDef {
  final String label;      // "C", "F" … printed on key (optional)
  final int midi;          // e.g. 60 = C4
  final KeyColor color;    // white vs black
  /// for a black key: index of the white key it is anchored AFTER
  final int anchor;
  const NoteDef(this.label, this.midi, this.color, {this.anchor = -1});
}

/// Left → right order of white keys
const whiteRow = <NoteDef>[
  NoteDef('1', 60, KeyColor.white),  // C4
  NoteDef('2', 62, KeyColor.white),  // D4
  NoteDef('3', 64, KeyColor.white),  // E4
  NoteDef('5', 67, KeyColor.white),  // G4
  NoteDef('6', 69, KeyColor.white),  // A4
  NoteDef('1\'', 72, KeyColor.white),  // C5
];

/// Elevated keys
const blackKeys = <NoteDef>[
  NoteDef('4', 65, KeyColor.black, anchor: 2), // after white index 2 (E)
  NoteDef('7', 71, KeyColor.black, anchor: 4), // after white index 4 (A)
];