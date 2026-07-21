import "package:meta/meta.dart";
import "package:piano_fitness/domain/models/music/chord_tone_pattern.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/domain/services/music_theory/arpeggios.dart";
import "package:piano_fitness/domain/services/music_theory/chord_definitions.dart";
import "package:piano_fitness/domain/services/music_theory/circle_of_fifths.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";
import "package:piano_fitness/domain/models/music/scale_types.dart" as music;

/// Helper class for copyWith to distinguish between
/// "field not provided" and "field explicitly set to null".
///
/// This allows copyWith to clear nullable fields when switching practice modes,
/// preventing stale cross-mode configuration state.
@immutable
class Field<T> {
  /// Creates an unset field (preserves current value in copyWith).
  const Field.unset() : isSet = false, value = null;

  /// Creates a field with an explicit value (updates in copyWith).
  const Field.set(this.value) : isSet = true;

  /// Whether this field has been explicitly set.
  final bool isSet;

  /// The value to set (may be null if explicitly clearing).
  final T? value;
}

/// Immutable configuration for a practice exercise.
///
/// This model unifies configuration across all practice modes while
/// respecting mode-specific requirements through validation.
///
/// Supports JSON serialization for database persistence via [toJson]/[fromJson].
@immutable
class ExerciseConfiguration {
  /// Creates an exercise configuration with the specified parameters.
  ///
  /// Required fields:
  /// - [practiceMode]: The practice mode (scales, chordsByKey, etc.)
  /// - [handSelection]: Which hand(s) to practice with
  ///
  /// Mode-specific required fields (validated via [validate]):
  /// - scales: key, scaleType
  /// - chordsByKey: key, scaleType
  /// - chordsByType: chordType
  /// - arpeggios: musicalNote, arpeggioType
  /// - blockChords: musicalNote, arpeggioType
  /// - chordProgressions: key, chordProgressionId
  ///
  /// See [validate] for complete validation rules.
  const ExerciseConfiguration({
    required this.practiceMode,
    required this.handSelection,
    this.key,
    this.scaleType,
    this.chordType,
    this.includeInversions = false,
    this.includeSeventhChords = false,
    this.musicalNote,
    this.arpeggioType,
    this.arpeggioOctaves = ArpeggioOctaves.one,
    this.pattern = ChordTonePattern.straight,
    this.includeLeftHandRoot = false,
    this.chordProgressionId,
  });

  /// Creates configuration from JSON (for database deserialization).
  ///
  /// Throws [ArgumentError] if required enum values are invalid.
  factory ExerciseConfiguration.fromJson(Map<String, dynamic> json) {
    return ExerciseConfiguration(
      practiceMode: PracticeMode.values.byName(json["practiceMode"] as String),
      handSelection: HandSelection.values.byName(
        json["handSelection"] as String,
      ),
      key: json["key"] != null
          ? music.Key.values.byName(json["key"] as String)
          : null,
      scaleType: json["scaleType"] != null
          ? music.ScaleType.values.byName(json["scaleType"] as String)
          : null,
      chordType: json["chordType"] != null
          ? ChordType.values.byName(json["chordType"] as String)
          : null,
      includeInversions: json["includeInversions"] as bool? ?? false,
      includeSeventhChords: json["includeSeventhChords"] as bool? ?? false,
      musicalNote: json["musicalNote"] != null
          ? MusicalNote.values.byName(json["musicalNote"] as String)
          : null,
      arpeggioType: json["arpeggioType"] != null
          ? ArpeggioType.values.byName(json["arpeggioType"] as String)
          : null,
      arpeggioOctaves: json["arpeggioOctaves"] != null
          ? ArpeggioOctaves.values.byName(json["arpeggioOctaves"] as String)
          : ArpeggioOctaves.one,
      pattern: json["pattern"] != null
          ? ChordTonePattern.values.byName(json["pattern"] as String)
          : ChordTonePattern.straight,
      includeLeftHandRoot: json["includeLeftHandRoot"] as bool? ?? false,
      chordProgressionId: json["chordProgressionId"] as String?,
    );
  }

  /// The practice mode (scales, chordsByKey, chordsByType, arpeggios, chordProgressions).
  final PracticeMode practiceMode;

  /// Which hand(s) to practice with (left, right, both).
  final HandSelection handSelection;

  /// The musical key for key-based modes (scales, chordsByKey, chordProgressions).
  /// Required for: scales, chordsByKey, chordProgressions.
  final music.Key? key;

  /// The scale type for scale-based modes (scales, chordsByKey).
  /// Required for: scales, chordsByKey.
  final music.ScaleType? scaleType;

  /// The chord type for chordsByType mode.
  /// Required for: chordsByType.
  final ChordType? chordType;

  /// Whether to include chord inversions (chordsByType mode).
  /// Default: false.
  final bool includeInversions;

  /// Whether to include seventh chords (chordsByKey mode).
  /// Default: false.
  final bool includeSeventhChords;

  /// The root note for arpeggios and blockChords modes.
  /// Required for: arpeggios, blockChords.
  final MusicalNote? musicalNote;

  /// The arpeggio/chord type for arpeggios and blockChords modes.
  /// Required for: arpeggios, blockChords.
  final ArpeggioType? arpeggioType;

  /// Number of octaves for arpeggio patterns (arpeggios mode).
  /// Default: ArpeggioOctaves.one.
  final ArpeggioOctaves arpeggioOctaves;

  /// The chord-tone pattern (arpeggios and blockChords modes): root
  /// position each octave, or continuously rotating through inversions.
  /// Default: ChordTonePattern.straight.
  final ChordTonePattern pattern;

  /// Whether the left hand taps the chord root for hand-independence
  /// practice (arpeggios and blockChords modes, right hand only — a no-op
  /// otherwise). Default: false.
  final bool includeLeftHandRoot;

  /// The chord progression identifier (chordProgressions mode).
  /// Maps to ChordProgression.name (e.g., "I - V", "I - ♭VII").
  /// Required for: chordProgressions.
  final String? chordProgressionId;

  /// Converts configuration to JSON (for database serialization).
  ///
  /// Omits fields with default values to minimize JSON size:
  /// - includeInversions (default: false)
  /// - includeSeventhChords (default: false)
  /// - arpeggioOctaves (default: one)
  Map<String, dynamic> toJson() {
    return {
      "practiceMode": practiceMode.name,
      "handSelection": handSelection.name,
      if (key != null) "key": key!.name,
      if (scaleType != null) "scaleType": scaleType!.name,
      if (chordType != null) "chordType": chordType!.name,
      if (includeInversions) "includeInversions": includeInversions,
      if (includeSeventhChords) "includeSeventhChords": includeSeventhChords,
      if (musicalNote != null) "musicalNote": musicalNote!.name,
      if (arpeggioType != null) "arpeggioType": arpeggioType!.name,
      if (arpeggioOctaves != ArpeggioOctaves.one)
        "arpeggioOctaves": arpeggioOctaves.name,
      if (pattern != ChordTonePattern.straight) "pattern": pattern.name,
      if (includeLeftHandRoot) "includeLeftHandRoot": includeLeftHandRoot,
      if (chordProgressionId != null) "chordProgressionId": chordProgressionId,
    };
  }

  /// Validates that required fields are present for the configured practice mode.
  ///
  /// Throws [ArgumentError] if required fields are missing.
  ///
  /// Validation rules by practice mode:
  /// - scales: requires key, scaleType
  /// - chordsByKey: requires key, scaleType
  /// - chordsByType: requires chordType
  /// - arpeggios: requires musicalNote, arpeggioType
  /// - blockChords: requires musicalNote, arpeggioType
  /// - chordProgressions: requires key, chordProgressionId
  /// - dominantCadence: requires key
  void validate() {
    switch (practiceMode) {
      case PracticeMode.scales:
        if (key == null) {
          throw ArgumentError("key is required for scales mode");
        }
        if (scaleType == null) {
          throw ArgumentError("scaleType is required for scales mode");
        }
        break;

      case PracticeMode.chordsByKey:
        if (key == null) {
          throw ArgumentError("key is required for chordsByKey mode");
        }
        if (scaleType == null) {
          throw ArgumentError("scaleType is required for chordsByKey mode");
        }
        break;

      case PracticeMode.chordsByType:
        if (chordType == null) {
          throw ArgumentError("chordType is required for chordsByType mode");
        }
        break;

      case PracticeMode.arpeggios:
        if (musicalNote == null) {
          throw ArgumentError("musicalNote is required for arpeggios mode");
        }
        if (arpeggioType == null) {
          throw ArgumentError("arpeggioType is required for arpeggios mode");
        }
        break;

      case PracticeMode.blockChords:
        if (musicalNote == null) {
          throw ArgumentError("musicalNote is required for blockChords mode");
        }
        if (arpeggioType == null) {
          throw ArgumentError("arpeggioType is required for blockChords mode");
        }
        break;

      case PracticeMode.chordProgressions:
        if (key == null) {
          throw ArgumentError("key is required for chordProgressions mode");
        }
        if (chordProgressionId == null) {
          throw ArgumentError(
            "chordProgressionId is required for chordProgressions mode",
          );
        }
        break;

      case PracticeMode.dominantCadence:
        if (key == null) {
          throw ArgumentError("key is required for dominantCadence mode");
        }
        break;
    }
  }

  /// Creates a copy with modified fields (copyWith pattern for immutability).
  ///
  /// Uses [Field] wrapper for nullable fields to distinguish between
  /// "field not provided" and "field explicitly set to null".
  /// This prevents stale cross-mode state when switching practice modes.
  ///
  /// Example: Clear chordProgressionId when switching from chordProgressions mode:
  /// ```dart
  /// config.copyWith(
  ///   practiceMode: PracticeMode.scales,
  ///   chordProgressionId: const Field.set(null),
  /// )
  /// ```
  ExerciseConfiguration copyWith({
    PracticeMode? practiceMode,
    HandSelection? handSelection,
    Field<music.Key>? key,
    Field<music.ScaleType>? scaleType,
    Field<ChordType>? chordType,
    bool? includeInversions,
    bool? includeSeventhChords,
    Field<MusicalNote>? musicalNote,
    Field<ArpeggioType>? arpeggioType,
    ArpeggioOctaves? arpeggioOctaves,
    ChordTonePattern? pattern,
    bool? includeLeftHandRoot,
    Field<String>? chordProgressionId,
  }) {
    return ExerciseConfiguration(
      practiceMode: practiceMode ?? this.practiceMode,
      handSelection: handSelection ?? this.handSelection,
      key: key != null && key.isSet ? key.value : this.key,
      scaleType: scaleType != null && scaleType.isSet
          ? scaleType.value
          : this.scaleType,
      chordType: chordType != null && chordType.isSet
          ? chordType.value
          : this.chordType,
      includeInversions: includeInversions ?? this.includeInversions,
      includeSeventhChords: includeSeventhChords ?? this.includeSeventhChords,
      musicalNote: musicalNote != null && musicalNote.isSet
          ? musicalNote.value
          : this.musicalNote,
      arpeggioType: arpeggioType != null && arpeggioType.isSet
          ? arpeggioType.value
          : this.arpeggioType,
      arpeggioOctaves: arpeggioOctaves ?? this.arpeggioOctaves,
      pattern: pattern ?? this.pattern,
      includeLeftHandRoot: includeLeftHandRoot ?? this.includeLeftHandRoot,
      chordProgressionId: chordProgressionId != null && chordProgressionId.isSet
          ? chordProgressionId.value
          : this.chordProgressionId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseConfiguration &&
          runtimeType == other.runtimeType &&
          practiceMode == other.practiceMode &&
          handSelection == other.handSelection &&
          key == other.key &&
          scaleType == other.scaleType &&
          chordType == other.chordType &&
          includeInversions == other.includeInversions &&
          includeSeventhChords == other.includeSeventhChords &&
          musicalNote == other.musicalNote &&
          arpeggioType == other.arpeggioType &&
          arpeggioOctaves == other.arpeggioOctaves &&
          pattern == other.pattern &&
          includeLeftHandRoot == other.includeLeftHandRoot &&
          chordProgressionId == other.chordProgressionId;

  @override
  int get hashCode => Object.hash(
    practiceMode,
    handSelection,
    key,
    scaleType,
    chordType,
    includeInversions,
    includeSeventhChords,
    musicalNote,
    arpeggioType,
    arpeggioOctaves,
    pattern,
    includeLeftHandRoot,
    chordProgressionId,
  );

  /// Progresses to the next key in the circle of fifths.
  ///
  /// For arpeggios and block chords modes, this also updates the root note to
  /// match the new key.
  ExerciseConfiguration nextInCircleOfFifths() {
    if (key == null) return this;
    final nextKey = CircleOfFifths.getNextKey(key!);

    if (practiceMode == PracticeMode.arpeggios ||
        practiceMode == PracticeMode.blockChords) {
      return copyWith(
        key: Field.set(nextKey),
        musicalNote: Field.set(NoteUtils.keyToMusicalNote(nextKey)),
      );
    } else {
      return copyWith(key: Field.set(nextKey));
    }
  }

  /// Returns a new configuration with the specified mode and sensible defaults
  /// applied for any fields required by that mode.
  ExerciseConfiguration withMode(PracticeMode newMode) {
    var newConfig = copyWith(
      practiceMode: newMode,
      key: const Field.set(null),
      scaleType: const Field.set(null),
      chordType: const Field.set(null),
      musicalNote: const Field.set(null),
      arpeggioType: const Field.set(null),
      chordProgressionId: const Field.set(null),
    );

    switch (newMode) {
      case PracticeMode.scales:
      case PracticeMode.chordsByKey:
        newConfig = newConfig.copyWith(
          key: Field.set(key ?? music.Key.c),
          scaleType: Field.set(scaleType ?? music.ScaleType.major),
        );
        break;
      case PracticeMode.chordsByType:
        newConfig = newConfig.copyWith(
          chordType: Field.set(chordType ?? ChordType.major),
        );
        break;
      case PracticeMode.arpeggios:
      case PracticeMode.blockChords:
        newConfig = newConfig.copyWith(
          musicalNote: Field.set(musicalNote ?? MusicalNote.c),
          arpeggioType: Field.set(arpeggioType ?? ArpeggioType.major),
        );
        break;
      case PracticeMode.chordProgressions:
        newConfig = newConfig.copyWith(
          key: Field.set(key ?? music.Key.c),
          chordProgressionId: Field.set(chordProgressionId ?? "I - V"),
        );
        break;
      case PracticeMode.dominantCadence:
        newConfig = newConfig.copyWith(
          key: Field.set(key ?? music.Key.c),
        );
        break;
    }
    return newConfig;
  }
}
