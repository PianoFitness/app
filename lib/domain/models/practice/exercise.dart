import "package:flutter/foundation.dart";

/// The type of input expected for a practice step.
///
/// Determines how notes should be played and validated during practice.
enum StepType {
  /// All notes in the step must be played simultaneously (e.g., chords).
  simultaneous,

  /// Notes in the step are played one at a time in sequence (e.g., single-hand scales).
  sequential,

  /// Notes form pairs that should be played together (e.g., both-hands scales/arpeggios).
  /// Each pair of notes should be played simultaneously, then the next pair, etc.
  paired,
}

/// A single step in a practice exercise.
///
/// Represents one or more notes to be played, along with metadata
/// about how they should be played and what they represent.
@immutable
class PracticeStep {
  /// Creates a practice step.
  ///
  /// The [notes] list contains MIDI note numbers (0-127) that should be
  /// played in this step. How they are played depends on [type]:
  /// - [StepType.simultaneous]: All notes played together (chord)
  /// - [StepType.sequential]: Each note played one after another
  /// - [StepType.paired]: Notes are paired (e.g., [left1, right1, left2, right2])
  const PracticeStep({required this.notes, required this.type, this.metadata});

  /// Creates a practice step from a JSON map.
  factory PracticeStep.fromJson(Map<String, dynamic> json) {
    return PracticeStep(
      notes: (json["notes"] as List<dynamic>).cast<int>(),
      type: StepType.values.byName(json["type"] as String),
      metadata: json["metadata"] as Map<String, dynamic>?,
    );
  }

  /// The MIDI note numbers to be played in this step.
  final List<int> notes;

  /// How the notes should be played (simultaneously, sequentially, or in pairs).
  final StepType type;

  /// Optional metadata about this step.
  ///
  /// Can include information like:
  /// - `chordName`: Name of the chord (e.g., "C Major")
  /// - `scaleDegree`: Scale degree number (e.g., "1", "2", "3")
  /// - `inversion`: Chord inversion (e.g., "root", "first", "second")
  /// - `description`: Human-readable description
  final Map<String, dynamic>? metadata;

  /// Converts this step to a JSON map for serialization.
  Map<String, dynamic> toJson() {
    return {
      "notes": notes,
      "type": type.name,
      if (metadata != null) "metadata": metadata,
    };
  }

  /// Creates a copy of this step with optional field replacements.
  PracticeStep copyWith({
    List<int>? notes,
    StepType? type,
    Map<String, dynamic>? metadata,
  }) {
    return PracticeStep(
      notes: notes ?? this.notes,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PracticeStep &&
        listEquals(other.notes, notes) &&
        other.type == type &&
        mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode => Object.hash(Object.hashAll(notes), type, metadata);

  @override
  String toString() {
    return "PracticeStep(notes: $notes, type: $type${metadata != null ? ", metadata: $metadata" : ""})";
  }
}

/// A complete practice exercise consisting of multiple steps.
///
/// This is the unified representation for all practice exercise types
/// (scales, arpeggios, chords, chord progressions). Each exercise is
/// a sequence of steps to be completed in order.
@immutable
class PracticeExercise {
  /// Creates a practice exercise.
  ///
  /// The [steps] list defines the sequence of notes to practice.
  /// Optional [metadata] can store information about the exercise as a whole.
  const PracticeExercise({required this.steps, this.metadata});

  /// Creates a practice exercise from a JSON map.
  factory PracticeExercise.fromJson(Map<String, dynamic> json) {
    return PracticeExercise(
      steps: (json["steps"] as List<dynamic>)
          .map((step) => PracticeStep.fromJson(step as Map<String, dynamic>))
          .toList(),
      metadata: json["metadata"] as Map<String, dynamic>?,
    );
  }

  /// The steps that make up this exercise, in order.
  final List<PracticeStep> steps;

  /// Optional metadata about the exercise as a whole.
  ///
  /// Can include information like:
  /// - `exerciseType`: Type of exercise (e.g., "scale", "arpeggio", "chord progression")
  /// - `key`: Musical key (e.g., "C", "D♭", "F#")
  /// - `mode`: Scale mode or chord quality (e.g., "major", "minor", "dorian")
  /// - `difficulty`: Difficulty level
  /// - `description`: Human-readable description
  final Map<String, dynamic>? metadata;

  /// Returns true if this exercise has no steps.
  bool get isEmpty => steps.isEmpty;

  /// Returns true if this exercise has at least one step.
  bool get isNotEmpty => steps.isNotEmpty;

  /// Returns the number of steps in this exercise.
  int get length => steps.length;

  /// Returns all unique MIDI notes used in this exercise.
  ///
  /// This is useful for calculating the piano keyboard range needed
  /// to display the exercise.
  Set<int> getAllNotes() {
    final allNotes = <int>{};
    for (final step in steps) {
      allNotes.addAll(step.notes);
    }
    return allNotes;
  }

  /// Converts this exercise to a JSON map for serialization.
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
        listEquals(other.steps, steps) &&
        mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode => Object.hash(Object.hashAll(steps), metadata);

  @override
  String toString() {
    return "PracticeExercise(${steps.length} steps${metadata != null ? ", metadata: $metadata" : ""})";
  }
}
