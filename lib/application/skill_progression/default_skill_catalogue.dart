import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/music/broken_chord_pattern.dart";
import "package:piano_fitness/domain/models/music/scale_types.dart" as music;
import "package:piano_fitness/domain/models/practice/exercise_configuration.dart";
import "package:piano_fitness/domain/models/practice/exercise_tempo_result.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/domain/models/skill_progression/skill_catalogue.dart";
import "package:piano_fitness/domain/services/music_theory/arpeggios.dart";
import "package:piano_fitness/domain/services/music_theory/chord_definitions.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";
import "package:piano_fitness/domain/services/skill_progression/skill_catalogue_validator.dart";

/// The first, deliberately small catalogue backed by existing exercise modes.
abstract final class DefaultSkillCatalogue {
  static final SkillCatalogue catalogue = _create();

  static SkillCatalogue _create() {
    final catalogue = SkillCatalogue(
      id: "piano-fitness-foundations",
      version: 8,
      groups: [
        SkillGraphGroup(
          id: "key-foundations",
          name: "Key Foundations",
          description: "Scales and arpeggios across every key.",
          nodeIds: ["major-scale", "natural-minor", "major-arpeggio"],
          displayOrder: 0,
        ),
        SkillGraphGroup(
          id: "modes",
          name: "Modes",
          description:
              "The remaining major- and minor-scale modes, heard as "
              "variations on the major and natural minor scales.",
          nodeIds: [
            "dorian-mode",
            "phrygian-mode",
            "lydian-mode",
            "mixolydian-mode",
            "locrian-mode",
          ],
          displayOrder: 1,
        ),
        SkillGraphGroup(
          id: "chord-vocabulary",
          name: "Chord Vocabulary",
          description: "Diatonic chords, progressions, and cadences.",
          nodeIds: [
            "diatonic-triads",
            "i-iv-v-i",
            "i-v-vi-iv",
            "i-vi-iv-v",
            "ii-v-i",
            "dominant-cadence",
            "plagal-cadence",
            "half-cadence",
            "deceptive-cadence",
          ],
          displayOrder: 2,
        ),
        SkillGraphGroup(
          id: "core-technique",
          name: "Core Technique & Coordination",
          description: "Chord shapes that extend the foundational triads.",
          nodeIds: [
            "suspended-chords",
            "altered-triads",
            "broken-chord-accompaniment",
          ],
          displayOrder: 3,
        ),
      ],
      nodes: [
        SkillNode(
          id: "major-scale",
          name: "Major scale",
          description:
              "Build secure scale technique in each hand, then coordinate "
              "them together.",
          checkpoints: _scaleCheckpoints("major-scale", music.ScaleType.major),
          proficiencyRule: SkillProficiencyRule(referenceTempoBpm: 90),
          tempoProgression: const TempoProgression(incrementBpm: 5),
        ),
        SkillNode(
          id: "natural-minor",
          name: "Natural minor scale",
          description:
              "Practise the natural minor sound in each hand and together "
              "across every key.",
          checkpoints: _scaleCheckpoints(
            "natural-minor",
            music.ScaleType.minor,
          ),
          proficiencyRule: SkillProficiencyRule(referenceTempoBpm: 90),
          tempoProgression: const TempoProgression(incrementBpm: 5),
          relations: const [
            SkillRelation(
              type: SkillRelationType.recommendedPrerequisite,
              nodeId: "major-scale",
            ),
          ],
        ),
        SkillNode(
          id: "dorian-mode",
          name: "Dorian mode",
          description:
              "Practise the Dorian sound: natural minor with a raised "
              "sixth.",
          checkpoints: _scaleCheckpoints("dorian-mode", music.ScaleType.dorian),
          proficiencyRule: SkillProficiencyRule(referenceTempoBpm: 90),
          tempoProgression: const TempoProgression(incrementBpm: 5),
          relations: const [
            SkillRelation(
              type: SkillRelationType.variation,
              nodeId: "natural-minor",
              description: "Compare with the natural minor sound.",
            ),
          ],
        ),
        SkillNode(
          id: "phrygian-mode",
          name: "Phrygian mode",
          description:
              "Practise the Phrygian sound: minor with a flattened "
              "second.",
          checkpoints: _scaleCheckpoints(
            "phrygian-mode",
            music.ScaleType.phrygian,
          ),
          proficiencyRule: SkillProficiencyRule(referenceTempoBpm: 90),
          tempoProgression: const TempoProgression(incrementBpm: 5),
          relations: const [
            SkillRelation(
              type: SkillRelationType.variation,
              nodeId: "natural-minor",
              description: "Compare with the natural minor sound.",
            ),
          ],
        ),
        SkillNode(
          id: "lydian-mode",
          name: "Lydian mode",
          description: "Practise the Lydian sound: major with a raised fourth.",
          checkpoints: _scaleCheckpoints("lydian-mode", music.ScaleType.lydian),
          proficiencyRule: SkillProficiencyRule(referenceTempoBpm: 90),
          tempoProgression: const TempoProgression(incrementBpm: 5),
          relations: const [
            SkillRelation(
              type: SkillRelationType.variation,
              nodeId: "major-scale",
              description: "Compare with the major scale sound.",
            ),
          ],
        ),
        SkillNode(
          id: "mixolydian-mode",
          name: "Mixolydian mode",
          description:
              "Practise the Mixolydian sound: major with a flattened "
              "seventh.",
          checkpoints: _scaleCheckpoints(
            "mixolydian-mode",
            music.ScaleType.mixolydian,
          ),
          proficiencyRule: SkillProficiencyRule(referenceTempoBpm: 90),
          tempoProgression: const TempoProgression(incrementBpm: 5),
          relations: const [
            SkillRelation(
              type: SkillRelationType.variation,
              nodeId: "major-scale",
              description: "Compare with the major scale sound.",
            ),
          ],
        ),
        SkillNode(
          id: "locrian-mode",
          name: "Locrian mode",
          description:
              "Practise the Locrian sound: minor with a flattened second "
              "and fifth.",
          checkpoints: _scaleCheckpoints(
            "locrian-mode",
            music.ScaleType.locrian,
          ),
          proficiencyRule: SkillProficiencyRule(referenceTempoBpm: 90),
          tempoProgression: const TempoProgression(incrementBpm: 5),
          relations: const [
            SkillRelation(
              type: SkillRelationType.variation,
              nodeId: "natural-minor",
              description: "Compare with the natural minor sound.",
            ),
          ],
        ),
        SkillNode(
          id: "major-arpeggio",
          name: "One-octave major arpeggio",
          description: "Connect chord tones as a smooth broken chord.",
          checkpoints: _arpeggioCheckpoints(),
          proficiencyRule: SkillProficiencyRule(
            referenceTempoBpm: 90,
            supportedTempoMeasurementVersions: {
              TempoMeasurementVersions.declaredStepDurations,
              TempoMeasurementVersions.scaleEighthNotes,
            },
          ),
          tempoProgression: const TempoProgression(incrementBpm: 5),
          relations: const [
            SkillRelation(
              type: SkillRelationType.related,
              nodeId: "major-scale",
            ),
          ],
        ),
        SkillNode(
          id: "diatonic-triads",
          name: "Foundational triads",
          description: "Play the seven triads in order in each major key.",
          checkpoints: _chordsByKeyCheckpoints(),
          proficiencyRule: SkillProficiencyRule(
            referenceTempoBpm: 72,
            supportedTempoMeasurementVersions: {
              TempoMeasurementVersions.declaredStepDurations,
              TempoMeasurementVersions.scaleEighthNotes,
            },
          ),
          tempoProgression: const TempoProgression(incrementBpm: 4),
          relations: const [
            SkillRelation(
              type: SkillRelationType.recommendedPrerequisite,
              nodeId: "major-scale",
            ),
          ],
        ),
        SkillNode(
          id: "i-iv-v-i",
          name: "I–IV–V–I progression",
          description:
              "Establish tonic, move through predominant and dominant, "
              "then resolve home.",
          checkpoints: _progressionCheckpoints("i-iv-v-i", "I - IV - V - I"),
          proficiencyRule: SkillProficiencyRule(
            tempoEvidencePolicy: TempoEvidencePolicy.optional,
            supportedTempoMeasurementVersions: {
              TempoMeasurementVersions.declaredStepDurations,
              TempoMeasurementVersions.scaleEighthNotes,
            },
          ),
          relations: const [
            SkillRelation(
              type: SkillRelationType.appliesIn,
              nodeId: "diatonic-triads",
            ),
          ],
        ),
        SkillNode(
          id: "i-v-vi-iv",
          name: "I–V–vi–IV progression",
          description: "Practise a foundational four-chord pop progression.",
          checkpoints: _progressionCheckpoints("i-v-vi-iv", "I - V - vi - IV"),
          proficiencyRule: SkillProficiencyRule(
            tempoEvidencePolicy: TempoEvidencePolicy.optional,
            supportedTempoMeasurementVersions: {
              TempoMeasurementVersions.declaredStepDurations,
              TempoMeasurementVersions.scaleEighthNotes,
            },
          ),
          relations: const [
            SkillRelation(
              type: SkillRelationType.appliesIn,
              nodeId: "diatonic-triads",
            ),
          ],
        ),
        SkillNode(
          id: "i-vi-iv-v",
          name: "I–vi–IV–V progression",
          description:
              "Practise the classic circle progression with smooth "
              "voice leading.",
          checkpoints: _progressionCheckpoints("i-vi-iv-v", "I - vi - IV - V"),
          proficiencyRule: SkillProficiencyRule(
            tempoEvidencePolicy: TempoEvidencePolicy.optional,
            supportedTempoMeasurementVersions: {
              TempoMeasurementVersions.declaredStepDurations,
              TempoMeasurementVersions.scaleEighthNotes,
            },
          ),
          relations: const [
            SkillRelation(
              type: SkillRelationType.appliesIn,
              nodeId: "diatonic-triads",
            ),
          ],
        ),
        SkillNode(
          id: "ii-v-i",
          name: "ii–V–I progression",
          description: "Practise the fundamental jazz progression.",
          checkpoints: _progressionCheckpoints("ii-v-i", "ii - V - I"),
          proficiencyRule: SkillProficiencyRule(
            tempoEvidencePolicy: TempoEvidencePolicy.optional,
            supportedTempoMeasurementVersions: {
              TempoMeasurementVersions.declaredStepDurations,
              TempoMeasurementVersions.scaleEighthNotes,
            },
          ),
          relations: const [
            SkillRelation(
              type: SkillRelationType.recommendedPrerequisite,
              nodeId: "diatonic-triads",
              description: "Know the seven diatonic triads first.",
            ),
          ],
        ),
        SkillNode(
          id: "dominant-cadence",
          name: "Authentic cadence",
          description: "Resolve V to I through its inversions in every key.",
          checkpoints: _cadenceCheckpoints(),
          proficiencyRule: SkillProficiencyRule(
            tempoEvidencePolicy: TempoEvidencePolicy.notApplicable,
            supportedTempoMeasurementVersions: {},
          ),
          relations: const [
            SkillRelation(
              type: SkillRelationType.recommendedPrerequisite,
              nodeId: "diatonic-triads",
            ),
          ],
        ),
        SkillNode(
          id: "plagal-cadence",
          name: "Plagal cadence",
          description: "Resolve IV to I and hear its gentler arrival.",
          checkpoints: _progressionCheckpoints("plagal-cadence", "IV - I"),
          proficiencyRule: SkillProficiencyRule(
            tempoEvidencePolicy: TempoEvidencePolicy.notApplicable,
            supportedTempoMeasurementVersions: {},
          ),
          relations: const [
            SkillRelation(
              type: SkillRelationType.recommendedPrerequisite,
              nodeId: "diatonic-triads",
            ),
          ],
        ),
        SkillNode(
          id: "half-cadence",
          name: "Half cadence",
          description: "Move from I to V and hear an open, unfinished ending.",
          checkpoints: _progressionCheckpoints("half-cadence", "I - V"),
          proficiencyRule: SkillProficiencyRule(
            tempoEvidencePolicy: TempoEvidencePolicy.notApplicable,
            supportedTempoMeasurementVersions: {},
          ),
          relations: const [
            SkillRelation(
              type: SkillRelationType.recommendedPrerequisite,
              nodeId: "diatonic-triads",
            ),
          ],
        ),
        SkillNode(
          id: "deceptive-cadence",
          name: "Deceptive cadence",
          description:
              "Hear the dominant lead unexpectedly to vi instead of I.",
          checkpoints: _progressionCheckpoints("deceptive-cadence", "V - vi"),
          proficiencyRule: SkillProficiencyRule(
            tempoEvidencePolicy: TempoEvidencePolicy.notApplicable,
            supportedTempoMeasurementVersions: {},
          ),
          relations: const [
            SkillRelation(
              type: SkillRelationType.recommendedPrerequisite,
              nodeId: "diatonic-triads",
            ),
          ],
        ),
        SkillNode(
          id: "suspended-chords",
          name: "Suspended chords",
          description:
              "Hear the open sound of sus2 and sus4 chords across every key.",
          checkpoints: _chordTypeCheckpoints("suspended-chords", {
            ChordType.suspended2: false,
            ChordType.suspended4: false,
          }),
          proficiencyRule: SkillProficiencyRule(
            referenceTempoBpm: 72,
            supportedTempoMeasurementVersions: {
              TempoMeasurementVersions.declaredStepDurations,
              TempoMeasurementVersions.scaleEighthNotes,
            },
          ),
          tempoProgression: const TempoProgression(incrementBpm: 4),
          relations: const [
            SkillRelation(
              type: SkillRelationType.recommendedPrerequisite,
              nodeId: "diatonic-triads",
            ),
          ],
        ),
        SkillNode(
          id: "altered-triads",
          name: "Augmented and diminished triads",
          description:
              "Practise the symmetrical augmented and diminished triad shapes "
              "through their inversions in every key.",
          checkpoints: _chordTypeCheckpoints("altered-triads", {
            ChordType.augmented: true,
            ChordType.diminished: true,
          }),
          proficiencyRule: SkillProficiencyRule(
            referenceTempoBpm: 72,
            supportedTempoMeasurementVersions: {
              TempoMeasurementVersions.declaredStepDurations,
              TempoMeasurementVersions.scaleEighthNotes,
            },
          ),
          tempoProgression: const TempoProgression(incrementBpm: 4),
          relations: const [
            SkillRelation(
              type: SkillRelationType.recommendedPrerequisite,
              nodeId: "diatonic-triads",
            ),
          ],
        ),
        SkillNode(
          id: "broken-chord-accompaniment",
          name: "Broken-chord accompaniment",
          description:
              "Keep a steady left-hand 1–5–3–5 pattern while harmony changes.",
          checkpoints: _brokenChordAccompanimentCheckpoints(),
          proficiencyRule: SkillProficiencyRule(
            referenceTempoBpm: 72,
            supportedTempoMeasurementVersions: {
              TempoMeasurementVersions.declaredStepDurations,
              TempoMeasurementVersions.scaleEighthNotes,
            },
          ),
          tempoProgression: const TempoProgression(incrementBpm: 4),
          relations: const [
            SkillRelation(
              type: SkillRelationType.recommendedPrerequisite,
              nodeId: "i-iv-v-i",
            ),
          ],
        ),
      ],
    );
    SkillCatalogueValidator.validate(catalogue);
    return catalogue;
  }

  static List<SkillCheckpoint> _scaleCheckpoints(
    String nodeId,
    music.ScaleType scaleType,
  ) {
    return music.Key.values
        .map((key) {
          ExerciseConfiguration configuration(HandSelection hand) =>
              ExerciseConfiguration(
                practiceMode: PracticeMode.scales,
                handSelection: hand,
                key: key,
                scaleType: scaleType,
              );
          final exercises = [
            SkillExercise(
              id: "$nodeId-${key.name}-left",
              name: "${key.displayName} ${scaleType.name}, left hand",
              configuration: configuration(HandSelection.left),
            ),
            SkillExercise(
              id: "$nodeId-${key.name}-right",
              name: "${key.displayName} ${scaleType.name}, right hand",
              configuration: configuration(HandSelection.right),
            ),
            SkillExercise(
              id: "$nodeId-${key.name}-both",
              name: "${key.displayName} ${scaleType.name}, hands together",
              configuration: configuration(HandSelection.both),
            ),
          ];
          return SkillCheckpoint(
            id: "$nodeId-${key.name}",
            name: "${key.displayName} ${scaleType.name}",
            exercises: exercises,
          );
        })
        .toList(growable: false);
  }

  static List<SkillCheckpoint> _arpeggioCheckpoints() {
    return music.Key.values
        .map((key) {
          final root = NoteUtils.keyToMusicalNote(key);
          return SkillCheckpoint(
            id: "major-arpeggio-${key.name}",
            name: "${key.displayName} major",
            exercises: [
              SkillExercise(
                id: "major-arpeggio-${key.name}",
                name: "${key.displayName} major arpeggio",
                configuration: ExerciseConfiguration(
                  practiceMode: PracticeMode.arpeggios,
                  handSelection: HandSelection.both,
                  musicalNote: root,
                  arpeggioType: ArpeggioType.major,
                ),
              ),
            ],
          );
        })
        .toList(growable: false);
  }

  static List<SkillCheckpoint> _chordsByKeyCheckpoints() {
    return music.Key.values
        .map((key) {
          return SkillCheckpoint(
            id: "diatonic-triads-${key.name}",
            name: "${key.displayName} major",
            exercises: [
              SkillExercise(
                id: "diatonic-triads-${key.name}",
                name: "${key.displayName} major diatonic triads",
                configuration: ExerciseConfiguration(
                  practiceMode: PracticeMode.chordsByKey,
                  handSelection: HandSelection.both,
                  key: key,
                  scaleType: music.ScaleType.major,
                ),
              ),
            ],
          );
        })
        .toList(growable: false);
  }

  static List<SkillCheckpoint> _chordTypeCheckpoints(
    String nodeId,
    Map<ChordType, bool> chordTypes,
  ) {
    return chordTypes.entries
        .map((entry) {
          final chordType = entry.key;
          final includeInversions = entry.value;
          return SkillCheckpoint(
            id: "$nodeId-${chordType.name}",
            name: chordType.shortName,
            exercises: [
              SkillExercise(
                id: "$nodeId-${chordType.name}",
                name: "${chordType.shortName} in all keys",
                configuration: ExerciseConfiguration(
                  practiceMode: PracticeMode.chordsByType,
                  handSelection: HandSelection.both,
                  chordType: chordType,
                  includeInversions: includeInversions,
                ),
              ),
            ],
          );
        })
        .toList(growable: false);
  }

  static List<SkillCheckpoint> _brokenChordAccompanimentCheckpoints() {
    const progressionId = "I - IV - V - I";
    const pattern = BrokenChordPattern.rootFifthThirdFifth;
    return music.Key.values
        .map((key) {
          return SkillCheckpoint(
            id: "broken-chord-accompaniment-${key.name}",
            name: "${key.displayName} major",
            exercises: [
              SkillExercise(
                id: "broken-chord-accompaniment-${key.name}",
                name: "${key.displayName}: 1–5–3–5 accompaniment",
                configuration: ExerciseConfiguration(
                  practiceMode: PracticeMode.brokenChordAccompaniment,
                  handSelection: HandSelection.both,
                  key: key,
                  chordProgressionId: progressionId,
                  brokenChordPattern: pattern,
                ),
              ),
            ],
          );
        })
        .toList(growable: false);
  }

  static List<SkillCheckpoint> _progressionCheckpoints(
    String nodeId,
    String chordProgressionId,
  ) {
    final displayLabel = chordProgressionId.replaceAll(" - ", "–");
    return music.Key.values
        .map((key) {
          return SkillCheckpoint(
            id: "$nodeId-${key.name}",
            name: "${key.displayName} major",
            exercises: [
              SkillExercise(
                id: "$nodeId-${key.name}",
                name: "${key.displayName}: $displayLabel",
                configuration: ExerciseConfiguration(
                  practiceMode: PracticeMode.chordProgressions,
                  handSelection: HandSelection.both,
                  key: key,
                  chordProgressionId: chordProgressionId,
                ),
              ),
            ],
          );
        })
        .toList(growable: false);
  }

  static List<SkillCheckpoint> _cadenceCheckpoints() {
    return music.Key.values
        .map((key) {
          return SkillCheckpoint(
            id: "dominant-cadence-${key.name}",
            name: "${key.displayName} major",
            exercises: [
              SkillExercise(
                id: "dominant-cadence-${key.name}",
                name: "${key.displayName}: V–I cadence",
                configuration: ExerciseConfiguration(
                  practiceMode: PracticeMode.dominantCadence,
                  handSelection: HandSelection.both,
                  key: key,
                ),
              ),
            ],
          );
        })
        .toList(growable: false);
  }
}
