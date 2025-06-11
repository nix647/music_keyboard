import 'dart:io';                               // <-- add this
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_midi_pro/flutter_midi_pro.dart';

class MidiManager {
  static final _i = MidiManager._();
  factory MidiManager() => _i;
  MidiManager._();

  final MidiPro _midi = MidiPro();
  int? _sfId; // sound‑font id after loading
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return; // avoid re-loading the sound font

    // 1. Load the bundled SF2 bytes
    final data = await rootBundle.load('assets/sf2/Piano.sf2');

    // 2. Write to a real file in the temporary directory (iOS needs a file path)
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/piano.sf2');
    await file.writeAsBytes(data.buffer.asUint8List(), flush: true);

    // 3. Ask the engine to load that sound‑font
    _sfId = await _midi.loadSoundfont(path: file.path, bank: 0, program: 0);
    print('sfId = $_sfId');

    _initialized = true;
  }

  void noteOn(int midi, double pressure) {
    print('noteOn: $midi, $pressure');
    if (_sfId == null) return;
    final vel = (pressure * 127).clamp(15, 127).toInt();
    _midi.playNote(sfId: _sfId!, channel: 0, key: midi, velocity: vel);
  }

  void noteOff(int midi) {
    if (_sfId == null) return;
    _midi.stopNote(sfId: _sfId!, channel: 0, key: midi);
  }
}