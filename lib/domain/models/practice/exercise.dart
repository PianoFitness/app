import "package:collection/collection.dart";
import "package:meta/meta.dart";
import "package:piano_fitness/domain/models/music/midi_note.dart";
import "package:piano_fitness/domain/models/practice/practice_note.dart";

export "package:piano_fitness/domain/models/practice/practice_note.dart";

/// One onset moment in a practice exercise.
///
/// Every [notes] value is intended to begin together. Sequential material is
/// represented by multiple ordered [PracticeStep] values.
@immutable
class PracticeStep {
  /// Creates a practice step containing one or more complete note targets.
  PracticeStep({
    required List<PracticeNote> notes,
    Map<String, dynamic>? metadata,
  }) : notes = List.unmodifiable(_validateNotes(notes)),
       metadata = metadata == null
           ? null
           : Map.unmodifiable(Map<String, dynamic>.from(metadata));

  /// Creates a practice step from JSON.
  factory PracticeStep.fromJson(Map<String, dynamic> json) {
    return PracticeStep(
      notes: (json["notes"] as List<dynamic>)
          .map((note) => PracticeNote.fromJson(note as Map<String, dynamic>))
          .toList(),
      metadata: json["metadata"] as Map<String, dynamic>?,
    );
  }

  /// Complete note targets intended to begin together.
  ///
  /// List order is deterministic for display and serialization but has no
  /// performance meaning within the step.
  final List<PracticeNote> notes;

  /// Optional information about this onset moment as a whole.
  final Map<String, dynamic>? metadata;

  /// The exact MIDI pitch set expected for this step.
  Set<int> get expectedMidiNotes =>
      Set.unmodifiable(notes.map((note) => note.pitch.value));

  /// MIDI pitches in deterministic note order.
  List<int> get midiNotes =>
      List.unmodifiable(notes.map((note) => note.pitch.value));

  /// Converts this step to JSON.
  Map<String, dynamic> toJson() {
    return {
      "notes": notes.map((note) => note.toJson()).toList(),
      if (metadata != null) "metadata": metadata,
    };
  }

  /// Creates a copy of this step with optional field replacements.
  PracticeStep copyWith({
    List<PracticeNote>? notes,
    Map<String, dynamic>? metadata,
  }) {
    return PracticeStep(
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }

  static List<PracticeNote> _validateNotes(List<PracticeNote> notes) {
    if (notes.isEmpty) {
      throw ArgumentError.value(notes, "notes", "must not be empty");
    }

    final pitches = <int>{};
    final assignedFingers = <(PracticeHand, int)>{};
    for (final note in notes) {
      if (!pitches.add(note.pitch.value)) {
        throw ArgumentError.value(
          note.pitch.value,
          "notes",
          "must not contain duplicate MIDI pitches",
        );
      }
      final fingerNumber = note.fingerNumber;
      if (fingerNumber != null &&
          !assignedFingers.add((note.hand, fingerNumber))) {
        throw ArgumentError.value(
          fingerNumber,
          "notes",
          "a hand cannot assign one finger to multiple notes in a step",
        );
      }
    }
    return notes;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PracticeStep &&
        const ListEquality<PracticeNote>().equals(other.notes, notes) &&
        const DeepCollectionEquality().equals(other.metadata, metadata);
  }

  @override
  int get hashCode => Object.hash(
    const ListEquality<PracticeNote>().hash(notes),
    const DeepCollectionEquality().hash(metadata),
  );

  @override
  String toString() {
    return "PracticeStep(notes: $notes${metadata != null ? ", metadata: $metadata" : ""})";
  }
}

/// A complete practice exercise consisting of ordered onset steps.
@immutable
class PracticeExercise {
  /// Creates a practice exercise.
  PracticeExercise({
    required List<PracticeStep> steps,
    Map<String, dynamic>? metadata,
  }) : steps = List.unmodifiable(steps),
       metadata = metadata == null
           ? null
           : Map.unmodifiable(Map<String, dynamic>.from(metadata));

  /// Creates a practice exercise from JSON.
  factory PracticeExercise.fromJson(Map<String, dynamic> json) {
    return PracticeExercise(
      steps: (json["steps"] as List<dynamic>)
          .map((step) => PracticeStep.fromJson(step as Map<String, dynamic>))
          .toList(),
      metadata: json["metadata"] as Map<String, dynamic>?,
    );
  }

  /// The exercise's onset steps in performance order.
  final List<PracticeStep> steps;

  /// Optional information about the exercise as a whole.
  final Map<String, dynamic>? metadata;

  /// Returns true if this exercise has no steps.
  bool get isEmpty => steps.isEmpty;

  /// Returns true if this exercise has at least one step.
  bool get isNotEmpty => steps.isNotEmpty;

  /// Returns the number of steps in this exercise.
  int get length => steps.length;

  /// Returns all unique MIDI notes used in this exercise.
  Set<MidiNote> getAllNotes() {
    return Set.unmodifiable(
      steps.expand((step) => step.notes).map((note) => note.pitch),
    );
  }

  /// Converts this exercise to JSON.
  Map<String, dynamic> toJson() {
    return {
      "steps": steps.map((step) => step.toJson()).toList(),
      if (metadata != null) "metadata": metadata,
    };
  }

  /// Creates a copy of this exercise with optional field replacements.
  PracticeExercise copyWith({
    List<PracticeStep>? steps,
    Map<String, dynamic>? metadata,
  }) {
    return PracticeExercise(
      steps: steps ?? this.steps,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PracticeExercise &&
        const ListEquality<PracticeStep>().equals(other.steps, steps) &&
        const DeepCollectionEquality().equals(other.metadata, metadata);
  }

  @override
  int get hashCode => Object.hash(
    const ListEquality<PracticeStep>().hash(steps),
    const DeepCollectionEquality().hash(metadata),
  );

  @override
  String toString() {
    return "PracticeExercise(${steps.length} steps${metadata != null ? ", metadata: $metadata" : ""})";
  }
}
