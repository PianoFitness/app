import 'package:flutter_test/flutter_test.dart';
import 'package:piano/piano.dart';

void main() {
  test('Test NoteRange API', () {
    // Test different NoteRange constructors
    final range1 = NoteRange.forClefs([Clef.Treble, Clef.Bass]);
    print('forClefs range: ${range1.toString()}');

    // Try to find other constructors
    final noteC4 = NotePosition(note: Note.C, octave: 4);
    final noteC6 = NotePosition(note: Note.C, octave: 6);

    try {
      // Test if we can create from positions
      final range2 = NoteRange(from: noteC4, to: noteC6);
      print('Range from positions: ${range2.toString()}');
    } catch (e) {
      print('NoteRange(from:, to:) error: $e');
    }

    // Let's see what methods are available
    print('NoteRange type: ${range1.runtimeType}');
  });
}
