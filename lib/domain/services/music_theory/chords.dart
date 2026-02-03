/// {@template piano_fitness_chords}
/// Chord music theory services for Piano Fitness.
///
/// This barrel export provides convenient access to all chord-related functionality:
/// - [chord_definitions.dart] - Chord types, inversions, and chord info model
/// - [chord_builder.dart] - Chord creation, progressions, and MIDI generation
/// - [chord_by_type.dart] - Chord planing exercises for practicing specific chord types
///
/// Example usage:
/// ```dart
/// import 'package:piano_fitness/domain/services/music_theory/chords.dart';
///
/// // Create a C major chord in first inversion
/// final chord = ChordBuilder.getChord(
///   MusicalNote.c,
///   ChordType.major,
///   ChordInversion.first,
/// );
///
/// // Generate a chord progression in C major
/// final progression = ChordBuilder.getSmoothKeyTriadProgression(
///   Key.c,
///   ScaleType.major,
/// );
/// ```
/// {@endtemplate}
library;

export "chord_builder.dart";
export "chord_by_type.dart";
export "chord_definitions.dart";
