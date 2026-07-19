import "package:collection/collection.dart";
import "package:meta/meta.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/music/midi_note.dart";

/// The physical hand intended to play a [PracticeNote].
enum PracticeHand { left, right }

/// A complete note target within a practice step.
///
/// MIDI input can evaluate [pitch], while [hand] and [fingerNumber] provide
/// pedagogical guidance.
@immutable
class PracticeNote {
  /// Creates a practice note target.
  PracticeNote({
    required this.pitch,
    required this.hand,
    int? fingerNumber,
    Map<String, dynamic>? annotations,
  }) : fingerNumber = _validateFingerNumber(fingerNumber),
       annotations = annotations == null
           ? null
           : Map.unmodifiable(Map<String, dynamic>.from(annotations));

  /// Creates a practice note from JSON.
  factory PracticeNote.fromJson(Map<String, dynamic> json) {
    return PracticeNote(
      pitch: MidiNote(json["midiNote"] as int),
      hand: PracticeHand.values.byName(json["hand"] as String),
      fingerNumber: json["fingerNumber"] as int?,
      annotations: json["annotations"] as Map<String, dynamic>?,
    );
  }

  /// The MIDI pitch to play.
  final MidiNote pitch;

  /// The hand intended to play [pitch].
  final PracticeHand hand;

  /// Optional fingering guidance from 1 (thumb) through 5 (little finger).
  final int? fingerNumber;

  /// Optional note-specific guidance that does not affect MIDI evaluation.
  final Map<String, dynamic>? annotations;

  /// Converts this note to JSON.
  Map<String, dynamic> toJson() {
    return {
      "midiNote": pitch.value,
      "hand": hand.name,
      if (fingerNumber != null) "fingerNumber": fingerNumber,
      if (annotations != null) "annotations": annotations,
    };
  }

  static int? _validateFingerNumber(int? fingerNumber) {
    if (fingerNumber != null && (fingerNumber < 1 || fingerNumber > 5)) {
      throw ArgumentError.value(
        fingerNumber,
        "fingerNumber",
        "must be between 1 and 5",
      );
    }
    return fingerNumber;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PracticeNote &&
        other.pitch == pitch &&
        other.hand == hand &&
        other.fingerNumber == fingerNumber &&
        const DeepCollectionEquality().equals(other.annotations, annotations);
  }

  @override
  int get hashCode => Object.hash(
    pitch,
    hand,
    fingerNumber,
    const DeepCollectionEquality().hash(annotations),
  );

  @override
  String toString() {
    return "PracticeNote(pitch: $pitch, hand: $hand, fingerNumber: $fingerNumber)";
  }
}

/// Converts hand-grouped MIDI pitches into complete practice notes.
///
/// For [HandSelection.both], [pitches] must contain the left-hand voicing
/// followed by an equal-sized right-hand voicing. This matches the existing
/// chord-generation contract. Scales and arpeggios construct their interleaved
/// hand targets directly.
extension HandGroupedMidiNotes on List<MidiNote> {
  /// Creates practice notes with optional index-aligned [fingerNumbers].
  List<PracticeNote> toPracticeNotes({
    required HandSelection handSelection,
    List<int>? fingerNumbers,
  }) {
    if (fingerNumbers != null && fingerNumbers.length != length) {
      throw ArgumentError(
        "fingerNumbers must contain one value per MIDI pitch",
      );
    }
    if (handSelection == HandSelection.both && length.isOdd) {
      throw ArgumentError(
        "Both-hands grouped pitches must contain equally sized hand voicings",
      );
    }

    final handBoundary = length ~/ 2;
    return List<PracticeNote>.unmodifiable(
      List.generate(length, (index) {
        final hand = switch (handSelection) {
          HandSelection.left => PracticeHand.left,
          HandSelection.right => PracticeHand.right,
          HandSelection.both =>
            index < handBoundary ? PracticeHand.left : PracticeHand.right,
        };
        return PracticeNote(
          pitch: this[index],
          hand: hand,
          fingerNumber: fingerNumbers?[index],
        );
      }),
    );
  }
}
