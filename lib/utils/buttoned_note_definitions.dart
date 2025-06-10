import 'package:flutter/material.dart';

/// Defines a single note button for the ButtonedKeyboard.
class ButtonedNoteDef {
  final String label;
  final int midi;

  const ButtonedNoteDef(this.label, this.midi);
}

/// The 6 main notes for the keyboard, based on your drawing.
const buttonedKeys = <ButtonedNoteDef>[
  ButtonedNoteDef('1', 60), // C4
  ButtonedNoteDef('2', 62), // D4
  ButtonedNoteDef('3', 64), // E4
  ButtonedNoteDef('5', 67), // G4
  ButtonedNoteDef('6', 69), // A4
  ButtonedNoteDef('7', 71), // B4
];
