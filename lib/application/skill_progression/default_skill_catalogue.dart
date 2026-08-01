import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/music/scale_types.dart" as music;
import "package:piano_fitness/domain/models/practice/exercise_configuration.dart";
import "package:piano_fitness/domain/models/practice/exercise_tempo_result.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/domain/models/skill_progression/skill_catalogue.dart";
import "package:piano_fitness/domain/services/music_theory/arpeggios.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";
import "package:piano_fitness/domain/services/skill_progression/skill_catalogue_validator.dart";

/// The first, deliberately small catalogue backed by existing exercise modes.
abstract final class DefaultSkillCatalogue {
  static final SkillCatalogue catalogue = _create();

  static SkillCatalogue _create() {
    final catalogue = SkillCatalogue(
      id: "piano-fitness-foundations",
      version: 2,
      groups: const [
        SkillGraphGroup(
          id: "key-foundations",
          name: "Key Foundations",
          description: "Scales and arpeggios across every key.",
          nodeIds: [
            "major-scale-apart",
            "major-scale",
            "natural-minor",
            "major-arpeggio",
          ],
          displayOrder: 0,
        ),
        SkillGraphGroup(
          id: "chord-vocabulary",
          name: "Chord Vocabulary",
          description: "Diatonic chords, progressions, and cadences.",
          nodeIds: ["diatonic-triads", "i-v-vi-iv", "dominant-cadence"],
          displayOrder: 1,
        ),
      ],
      nodes: [
        SkillNode(
          id: "major-scale-apart",
          name: "Major scale, hands apart",
          description: "Build secure scale technique one hand at a time.",
          checkpoints: _scaleCheckpoints(
            "major-scale-apart",
            music.ScaleType.major,
            handsApart: true,
          ),
          proficiencyRule: const SkillProficiencyRule(referenceTempoBpm: 100),
          tempoProgression: const TempoProgression(incrementBpm: 5),
        ),
        SkillNode(
          id: "major-scale",
          name: "Major scale, hands together",
          description: "Coordinate both hands through every major scale.",
          checkpoints: _scaleCheckpoints("major-scale", music.ScaleType.major),
          proficiencyRule: const SkillProficiencyRule(referenceTempoBpm: 90),
          tempoProgression: const TempoProgression(incrementBpm: 5),
          relations: const [
            SkillRelation(
              type: SkillRelationType.recommendedPrerequisite,
              nodeId: "major-scale-apart",
              description: "Secure each hand separately first.",
            ),
          ],
        ),
        SkillNode(
          id: "natural-minor",
          name: "Natural minor scale, hands together",
          description: "Practise the natural minor sound across every key.",
          checkpoints: _scaleCheckpoints(
            "natural-minor",
            music.ScaleType.minor,
          ),
          proficiencyRule: const SkillProficiencyRule(referenceTempoBpm: 90),
          tempoProgression: const TempoProgression(incrementBpm: 5),
          relations: const [
            SkillRelation(
              type: SkillRelationType.recommendedPrerequisite,
              nodeId: "major-scale",
            ),
          ],
        ),
        SkillNode(
          id: "major-arpeggio",
          name: "One-octave major arpeggio",
          description: "Connect chord tones as a smooth broken chord.",
          checkpoints: _arpeggioCheckpoints(),
          proficiencyRule: const SkillProficiencyRule(
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
          name: "Diatonic triads",
          description: "Play the seven triads in order in each major key.",
          checkpoints: _chordsByKeyCheckpoints(),
          proficiencyRule: const SkillProficiencyRule(
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
          id: "i-v-vi-iv",
          name: "I–V–vi–IV progression",
          description: "Practise a foundational four-chord pop progression.",
          checkpoints: _progressionCheckpoints(),
          proficiencyRule: const SkillProficiencyRule(
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
          id: "dominant-cadence",
          name: "Dominant cadence",
          description: "Resolve V to I through its inversions in every key.",
          checkpoints: _cadenceCheckpoints(),
          proficiencyRule: const SkillProficiencyRule(
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
      ],
    );
    SkillCatalogueValidator.validate(catalogue);
    return catalogue;
  }

  static List<SkillCheckpoint> _scaleCheckpoints(
    String nodeId,
    music.ScaleType scaleType, {
    bool handsApart = false,
  }) {
    return music.Key.values
        .map((key) {
          ExerciseConfiguration configuration(HandSelection hand) =>
              ExerciseConfiguration(
                practiceMode: PracticeMode.scales,
                handSelection: hand,
                key: key,
                scaleType: scaleType,
              );
          final exercises = handsApart
              ? [
                  SkillExercise(
                    id: "$nodeId-${key.name}-left",
                    name: "${key.displayName} major, left hand",
                    configuration: configuration(HandSelection.left),
                  ),
                  SkillExercise(
                    id: "$nodeId-${key.name}-right",
                    name: "${key.displayName} major, right hand",
                    configuration: configuration(HandSelection.right),
                  ),
                ]
              : [
                  SkillExercise(
                    id: "$nodeId-${key.name}",
                    name: "${key.displayName} ${scaleType.name} scale",
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
          final root = MusicalNote.values[key.index];
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

  static List<SkillCheckpoint> _progressionCheckpoints() {
    return music.Key.values
        .map((key) {
          return SkillCheckpoint(
            id: "i-v-vi-iv-${key.name}",
            name: "${key.displayName} major",
            exercises: [
              SkillExercise(
                id: "i-v-vi-iv-${key.name}",
                name: "${key.displayName}: I–V–vi–IV",
                configuration: ExerciseConfiguration(
                  practiceMode: PracticeMode.chordProgressions,
                  handSelection: HandSelection.both,
                  key: key,
                  chordProgressionId: "I - V - vi - IV",
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
