import "package:meta/meta.dart";

/// An inclusive range of MIDI note numbers to display on a [PianoKeyboard].
///
/// Replaces the third-party `piano` package's `NoteRange` type; this app
/// only ever needs the two MIDI bounds, not the package's note-position
/// enumeration machinery.
@immutable
class MidiNoteRange {
  /// Creates a range covering [fromMidi] to [toMidi], inclusive.
  const MidiNoteRange({required this.fromMidi, required this.toMidi})
    : assert(
        fromMidi <= toMidi,
        "fromMidi ($fromMidi) must be <= toMidi ($toMidi)",
      );

  /// The lowest MIDI note number in the range (inclusive).
  final int fromMidi;

  /// The highest MIDI note number in the range (inclusive).
  final int toMidi;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidiNoteRange &&
          runtimeType == other.runtimeType &&
          fromMidi == other.fromMidi &&
          toMidi == other.toMidi;

  @override
  int get hashCode => Object.hash(fromMidi, toMidi);

  @override
  String toString() => "MidiNoteRange($fromMidi-$toMidi)";
}
