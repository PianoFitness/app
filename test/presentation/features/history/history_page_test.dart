import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";
import "package:piano_fitness/domain/models/music/arpeggio_type.dart";
import "package:piano_fitness/domain/models/music/chord_type.dart";
import "package:piano_fitness/domain/models/music/hand_selection.dart";
import "package:piano_fitness/domain/models/music/scale_types.dart" as music;
import "package:piano_fitness/domain/models/practice/exercise_configuration.dart";
import "package:piano_fitness/domain/models/practice/exercise_history_entry.dart";
import "package:piano_fitness/domain/models/practice/exercise_tempo_result.dart";
import "package:piano_fitness/domain/models/practice/practice_step_note_value.dart";
import "package:piano_fitness/domain/models/practice/practice_mode.dart";
import "package:piano_fitness/domain/services/music_theory/note_utils.dart";
import "package:piano_fitness/presentation/features/history/history_page.dart";
import "package:piano_fitness/presentation/features/history/widgets/history_entry_card.dart";

import "../../../shared/midi_mocks.dart";
import "../../../shared/test_helpers/mock_repositories.mocks.dart";
import "../../../shared/test_helpers/widget_test_helper.dart";

// ── Entry factory helpers ──────────────────────────────────────────────────

ExerciseHistoryEntry _makeScalesEntry() =>
    ExerciseHistoryEntry.fromConfiguration(
      id: "scales-1",
      profileId: "p1",
      completedAt: DateTime(2026, 3, 29, 10, 30),
      config: const ExerciseConfiguration(
        practiceMode: PracticeMode.scales,
        handSelection: HandSelection.both,
        key: music.Key.c,
        scaleType: music.ScaleType.major,
      ),
    );

ExerciseHistoryEntry _makeChordsByKeyEntry() =>
    ExerciseHistoryEntry.fromConfiguration(
      id: "chordsByKey-1",
      profileId: "p1",
      completedAt: DateTime(2026, 3, 29, 11),
      config: const ExerciseConfiguration(
        practiceMode: PracticeMode.chordsByKey,
        handSelection: HandSelection.right,
        key: music.Key.g,
        scaleType: music.ScaleType.major,
        includeSeventhChords: true,
      ),
    );

ExerciseHistoryEntry _makeChordsByTypeEntry() =>
    ExerciseHistoryEntry.fromConfiguration(
      id: "chordsByType-1",
      profileId: "p1",
      completedAt: DateTime(2026, 3, 29, 12),
      config: const ExerciseConfiguration(
        practiceMode: PracticeMode.chordsByType,
        handSelection: HandSelection.left,
        chordType: ChordType.minor,
        includeInversions: true,
      ),
    );

ExerciseHistoryEntry _makeArpeggiosEntry() =>
    ExerciseHistoryEntry.fromConfiguration(
      id: "arpeggios-1",
      profileId: "p1",
      completedAt: DateTime(2026, 3, 29, 13),
      config: const ExerciseConfiguration(
        practiceMode: PracticeMode.arpeggios,
        handSelection: HandSelection.both,
        musicalNote: MusicalNote.c,
        arpeggioType: ArpeggioType.major,
        arpeggioOctaves: ArpeggioOctaves.two,
      ),
    );

ExerciseHistoryEntry _makeChordProgressionsEntry() =>
    ExerciseHistoryEntry.fromConfiguration(
      id: "chordProg-1",
      profileId: "p1",
      completedAt: DateTime(2026, 3, 29, 14),
      config: const ExerciseConfiguration(
        practiceMode: PracticeMode.chordProgressions,
        handSelection: HandSelection.both,
        key: music.Key.f,
        chordProgressionId: "I-IV-V-I",
      ),
    );

ExerciseHistoryEntry _makeDominantCadenceEntry() =>
    ExerciseHistoryEntry.fromConfiguration(
      id: "dominant-1",
      profileId: "p1",
      completedAt: DateTime(2026, 3, 29, 15),
      config: const ExerciseConfiguration(
        practiceMode: PracticeMode.dominantCadence,
        handSelection: HandSelection.both,
        key: music.Key.d,
      ),
    );

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  setUpAll(MidiMocks.setUp);
  tearDownAll(MidiMocks.tearDown);

  group("HistoryPage", () {
    testWidgets("shows loading indicator while fetching", (tester) async {
      final mockUserProf = MockIUserProfileRepository();
      final mockHistoryRepo = MockIExerciseHistoryRepository();

      // A Completer that never completes keeps the ViewModel in loading state.
      final completer = Completer<String?>();
      when(
        mockUserProf.getActiveProfileId(),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(
        createTestWidgetWithMocks(
          child: const HistoryPage(),
          userProfileRepository: mockUserProf,
          exerciseHistoryRepository: mockHistoryRepo,
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets("shows empty state when no active profile", (tester) async {
      final mockUserProf = MockIUserProfileRepository();
      final mockHistoryRepo = MockIExerciseHistoryRepository();

      when(mockUserProf.getActiveProfileId()).thenAnswer((_) async => null);

      await tester.pumpWidget(
        createTestWidgetWithMocks(
          child: const HistoryPage(),
          userProfileRepository: mockUserProf,
          exerciseHistoryRepository: mockHistoryRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Your progress starts here"), findsOneWidget);
    });

    testWidgets("shows empty state when profile has no history", (
      tester,
    ) async {
      final mockUserProf = MockIUserProfileRepository();
      final mockHistoryRepo = MockIExerciseHistoryRepository();

      when(mockUserProf.getActiveProfileId()).thenAnswer((_) async => "p1");
      when(
        mockHistoryRepo.getEntriesForProfile("p1"),
      ).thenAnswer((_) async => []);
      when(
        mockHistoryRepo.watchEntriesForProfile("p1"),
      ).thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(
        createTestWidgetWithMocks(
          child: const HistoryPage(),
          userProfileRepository: mockUserProf,
          exerciseHistoryRepository: mockHistoryRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Your progress starts here"), findsOneWidget);
    });

    testWidgets("shows error message when repository throws", (tester) async {
      final mockUserProf = MockIUserProfileRepository();
      final mockHistoryRepo = MockIExerciseHistoryRepository();

      when(mockUserProf.getActiveProfileId()).thenAnswer((_) async => "p1");
      when(
        mockHistoryRepo.getEntriesForProfile("p1"),
      ).thenThrow(Exception("db error"));
      when(
        mockHistoryRepo.watchEntriesForProfile("p1"),
      ).thenAnswer((_) => Stream.error(Exception("db error")));

      await tester.pumpWidget(
        createTestWidgetWithMocks(
          child: const HistoryPage(),
          userProfileRepository: mockUserProf,
          exerciseHistoryRepository: mockHistoryRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text("Could not load history. Please try again."),
        findsOneWidget,
      );
    });

    testWidgets("shows history entries as HistoryEntryCard widgets", (
      tester,
    ) async {
      final mockUserProf = MockIUserProfileRepository();
      final mockHistoryRepo = MockIExerciseHistoryRepository();

      final entries = [_makeScalesEntry(), _makeChordsByKeyEntry()];
      when(mockUserProf.getActiveProfileId()).thenAnswer((_) async => "p1");
      when(
        mockHistoryRepo.getEntriesForProfile("p1"),
      ).thenAnswer((_) async => entries);
      when(
        mockHistoryRepo.watchEntriesForProfile("p1"),
      ).thenAnswer((_) => Stream.value(entries));

      await tester.pumpWidget(
        createTestWidgetWithMocks(
          child: const HistoryPage(),
          userProfileRepository: mockUserProf,
          exerciseHistoryRepository: mockHistoryRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HistoryEntryCard), findsNWidgets(2));
      expect(find.text("Your practice is adding up"), findsOneWidget);
      expect(
        find.byKey(const Key("progress_practices_metric")),
        findsOneWidget,
      );
      expect(find.byKey(const Key("progress_days_metric")), findsOneWidget);
      expect(find.text("Recent activity"), findsOneWidget);
    });

    testWidgets("does not show loading indicator after data loads", (
      tester,
    ) async {
      final mockUserProf = MockIUserProfileRepository();
      final mockHistoryRepo = MockIExerciseHistoryRepository();

      when(mockUserProf.getActiveProfileId()).thenAnswer((_) async => null);

      await tester.pumpWidget(
        createTestWidgetWithMocks(
          child: const HistoryPage(),
          userProfileRepository: mockUserProf,
          exerciseHistoryRepository: mockHistoryRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group("HistoryEntryCard", () {
    Widget wrap(ExerciseHistoryEntry entry) => MaterialApp(
      home: Scaffold(body: HistoryEntryCard(entry: entry)),
    );

    testWidgets("renders scales entry", (tester) async {
      await tester.pumpWidget(wrap(_makeScalesEntry()));
      await tester.pump();

      expect(find.text("C Major Scale"), findsOneWidget);
      expect(find.text("Scales"), findsOneWidget);
      expect(find.text("Both Hands"), findsOneWidget);
    });

    testWidgets("renders accuracy percentage label when present", (
      tester,
    ) async {
      final entry = ExerciseHistoryEntry.fromConfiguration(
        id: "scales-acc",
        profileId: "p1",
        completedAt: DateTime(2026, 3, 29, 10, 30),
        config: const ExerciseConfiguration(
          practiceMode: PracticeMode.scales,
          handSelection: HandSelection.both,
          key: music.Key.c,
          scaleType: music.ScaleType.major,
        ),
        accuracyPercentage: 95.0,
      );
      await tester.pumpWidget(wrap(entry));
      await tester.pump();

      expect(find.textContaining("95% accuracy"), findsOneWidget);
    });

    testWidgets("marks measured BPM when timing varied", (tester) async {
      final semantics = tester.ensureSemantics();
      final entry = ExerciseHistoryEntry.fromConfiguration(
        id: "scales-variable-tempo",
        profileId: "p1",
        completedAt: DateTime(2026, 3, 29, 10, 30),
        config: const ExerciseConfiguration(
          practiceMode: PracticeMode.scales,
          handSelection: HandSelection.right,
          key: music.Key.c,
          scaleType: music.ScaleType.major,
        ),
        accuracyPercentage: 100,
        measuredTempoBpm: 127.4,
        meanInterOnsetMicroseconds: 235478,
        interOnsetStandardDeviationMicroseconds: 58870,
        tempoCoefficientOfVariation: 0.25,
        tempoIntervalCount: 12,
        tempoMeasurementQuality: TempoMeasurementQuality.inconsistent,
        tempoStepNoteValue: PracticeStepNoteValue.eighth,
      );
      await tester.pumpWidget(wrap(entry));
      await tester.pump();

      expect(find.textContaining("100% accuracy"), findsOneWidget);
      expect(find.text("127.4 BPM"), findsOneWidget);
      expect(find.byIcon(Icons.waves_rounded), findsOneWidget);
      expect(
        find.byTooltip("Varied tempo · 25.0% timing variation"),
        findsOneWidget,
      );
      expect(find.byKey(const Key("history_tempo_varied")), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              (widget.properties.label?.contains("127.4 BPM, varied tempo") ??
                  false),
        ),
        findsOneWidget,
      );
      semantics.dispose();
    });

    testWidgets("marks a reliable BPM as steady", (tester) async {
      final entry = ExerciseHistoryEntry.fromConfiguration(
        id: "scales-steady-tempo",
        profileId: "p1",
        completedAt: DateTime(2026, 3, 29, 10, 30),
        config: const ExerciseConfiguration(
          practiceMode: PracticeMode.scales,
          handSelection: HandSelection.both,
          key: music.Key.c,
          scaleType: music.ScaleType.major,
        ),
        measuredTempoBpm: 120,
        meanInterOnsetMicroseconds: 250000,
        interOnsetStandardDeviationMicroseconds: 12500,
        tempoCoefficientOfVariation: 0.05,
        tempoIntervalCount: 12,
        tempoMeasurementQuality: TempoMeasurementQuality.reliable,
        tempoStepNoteValue: PracticeStepNoteValue.eighth,
      );
      await tester.pumpWidget(wrap(entry));

      expect(find.text("120.0 BPM"), findsOneWidget);
      expect(find.byIcon(Icons.horizontal_rule_rounded), findsOneWidget);
      expect(
        find.byTooltip("Steady tempo · 5.0% timing variation"),
        findsOneWidget,
      );
      expect(find.byKey(const Key("history_tempo_steady")), findsOneWidget);
    });

    testWidgets("derives mostly-steady feedback from stored variation", (
      tester,
    ) async {
      final entry = ExerciseHistoryEntry.fromConfiguration(
        id: "scales-mostly-steady-tempo",
        profileId: "p1",
        completedAt: DateTime(2026, 3, 29, 10, 30),
        config: const ExerciseConfiguration(
          practiceMode: PracticeMode.scales,
          handSelection: HandSelection.both,
          key: music.Key.c,
          scaleType: music.ScaleType.major,
        ),
        measuredTempoBpm: 120,
        meanInterOnsetMicroseconds: 250000,
        interOnsetStandardDeviationMicroseconds: 37500,
        tempoCoefficientOfVariation: 0.15,
        tempoIntervalCount: 12,
        tempoMeasurementQuality: TempoMeasurementQuality.reliable,
        tempoStepNoteValue: PracticeStepNoteValue.eighth,
      );
      await tester.pumpWidget(wrap(entry));

      expect(find.byIcon(Icons.graphic_eq_rounded), findsOneWidget);
      expect(
        find.byTooltip("Mostly steady · 15.0% timing variation"),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key("history_tempo_mostlySteady")),
        findsOneWidget,
      );
    });

    testWidgets("falls back to stored quality for legacy tempo rows", (
      tester,
    ) async {
      final entry = ExerciseHistoryEntry.fromConfiguration(
        id: "scales-legacy-tempo",
        profileId: "p1",
        completedAt: DateTime(2026, 3, 29, 10, 30),
        config: const ExerciseConfiguration(
          practiceMode: PracticeMode.scales,
          handSelection: HandSelection.right,
          key: music.Key.c,
          scaleType: music.ScaleType.major,
        ),
        measuredTempoBpm: 110,
        tempoMeasurementQuality: TempoMeasurementQuality.inconsistent,
        tempoStepNoteValue: PracticeStepNoteValue.eighth,
      );
      await tester.pumpWidget(wrap(entry));

      expect(find.byTooltip("Varied tempo"), findsOneWidget);
      expect(
        find.byKey(const Key("history_tempo_inconsistent")),
        findsOneWidget,
      );
    });

    testWidgets("marks a BPM calculated from a short sample", (tester) async {
      final entry = ExerciseHistoryEntry.fromConfiguration(
        id: "scales-short-tempo",
        profileId: "p1",
        completedAt: DateTime(2026, 3, 29, 10, 30),
        config: const ExerciseConfiguration(
          practiceMode: PracticeMode.scales,
          handSelection: HandSelection.left,
          key: music.Key.c,
          scaleType: music.ScaleType.major,
        ),
        measuredTempoBpm: 92.5,
        meanInterOnsetMicroseconds: 324324,
        interOnsetStandardDeviationMicroseconds: 16216,
        tempoCoefficientOfVariation: 0.05,
        tempoIntervalCount: 3,
        tempoMeasurementQuality: TempoMeasurementQuality.insufficientData,
        tempoStepNoteValue: PracticeStepNoteValue.eighth,
      );
      await tester.pumpWidget(wrap(entry));

      expect(find.text("92.5 BPM"), findsOneWidget);
      expect(find.byIcon(Icons.timelapse_rounded), findsOneWidget);
      expect(
        find.byTooltip("Short tempo sample · 5.0% timing variation"),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key("history_tempo_shortSample")),
        findsOneWidget,
      );
    });

    testWidgets("tempo badge wraps cleanly on a narrow phone", (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final entry = ExerciseHistoryEntry.fromConfiguration(
        id: "scales-narrow-tempo",
        profileId: "p1",
        completedAt: DateTime(2026, 3, 29, 10, 30),
        config: const ExerciseConfiguration(
          practiceMode: PracticeMode.scales,
          handSelection: HandSelection.both,
          key: music.Key.c,
          scaleType: music.ScaleType.major,
        ),
        accuracyPercentage: 100,
        measuredTempoBpm: 127.4,
        meanInterOnsetMicroseconds: 235478,
        interOnsetStandardDeviationMicroseconds: 58870,
        tempoCoefficientOfVariation: 0.25,
        tempoIntervalCount: 12,
        tempoMeasurementQuality: TempoMeasurementQuality.inconsistent,
        tempoStepNoteValue: PracticeStepNoteValue.eighth,
      );
      await tester.pumpWidget(wrap(entry));

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key("history_tempo_varied")), findsOneWidget);
    });

    testWidgets("renders chordsByKey entry with seventh chords", (
      tester,
    ) async {
      await tester.pumpWidget(wrap(_makeChordsByKeyEntry()));
      await tester.pump();

      expect(find.text("G Chords, with 7ths"), findsOneWidget);
      expect(find.text("Chords by Key"), findsOneWidget);
      expect(find.text("Right Hand"), findsOneWidget);
    });

    testWidgets("renders chordsByType entry with inversions", (tester) async {
      await tester.pumpWidget(wrap(_makeChordsByTypeEntry()));
      await tester.pump();

      expect(find.text("Minor Chords, with inversions"), findsOneWidget);
      expect(find.text("Chords by Type"), findsOneWidget);
      expect(find.text("Left Hand"), findsOneWidget);
    });

    testWidgets("renders arpeggios entry", (tester) async {
      await tester.pumpWidget(wrap(_makeArpeggiosEntry()));
      await tester.pump();

      expect(find.text("C Major Arpeggio (2 oct)"), findsOneWidget);
      expect(find.text("Arpeggios"), findsOneWidget);
    });

    testWidgets("renders chordProgressions entry", (tester) async {
      await tester.pumpWidget(wrap(_makeChordProgressionsEntry()));
      await tester.pump();

      expect(find.textContaining("I-IV-V-I"), findsOneWidget);
      expect(find.text("Chord Progressions"), findsOneWidget);
    });
    testWidgets("renders scales minor scale", (tester) async {
      final e = ExerciseHistoryEntry.fromConfiguration(
        id: "sm",
        profileId: "p1",
        completedAt: DateTime(2026),
        config: const ExerciseConfiguration(
          practiceMode: PracticeMode.scales,
          handSelection: HandSelection.both,
          key: music.Key.a,
          scaleType: music.ScaleType.minor,
        ),
      );
      await tester.pumpWidget(wrap(e));
      await tester.pump();
      expect(find.text("A Minor Scale"), findsOneWidget);
    });

    testWidgets("renders scales dorian scale", (tester) async {
      final e = ExerciseHistoryEntry.fromConfiguration(
        id: "sd",
        profileId: "p1",
        completedAt: DateTime(2026),
        config: const ExerciseConfiguration(
          practiceMode: PracticeMode.scales,
          handSelection: HandSelection.both,
          key: music.Key.d,
          scaleType: music.ScaleType.dorian,
        ),
      );
      await tester.pumpWidget(wrap(e));
      await tester.pump();
      expect(find.text("D Dorian Scale"), findsOneWidget);
    });

    testWidgets("renders chordsByType diminished", (tester) async {
      final e = ExerciseHistoryEntry.fromConfiguration(
        id: "cd",
        profileId: "p1",
        completedAt: DateTime(2026),
        config: const ExerciseConfiguration(
          practiceMode: PracticeMode.chordsByType,
          handSelection: HandSelection.both,
          chordType: ChordType.diminished,
        ),
      );
      await tester.pumpWidget(wrap(e));
      await tester.pump();
      expect(find.text("Diminished Chords"), findsOneWidget);
    });

    testWidgets("renders arpeggios minor", (tester) async {
      final e = ExerciseHistoryEntry.fromConfiguration(
        id: "am",
        profileId: "p1",
        completedAt: DateTime(2026),
        config: const ExerciseConfiguration(
          practiceMode: PracticeMode.arpeggios,
          handSelection: HandSelection.both,
          musicalNote: MusicalNote.a,
          arpeggioType: ArpeggioType.minor,
        ),
      );
      await tester.pumpWidget(wrap(e));
      await tester.pump();
      expect(find.text("A Minor Arpeggio (1 oct)"), findsOneWidget);
    });

    testWidgets("renders three and four octave arpeggios correctly", (
      tester,
    ) async {
      final three = ExerciseHistoryEntry.fromConfiguration(
        id: "a3",
        profileId: "p1",
        completedAt: DateTime(2026),
        config: const ExerciseConfiguration(
          practiceMode: PracticeMode.arpeggios,
          handSelection: HandSelection.both,
          musicalNote: MusicalNote.c,
          arpeggioType: ArpeggioType.major,
          arpeggioOctaves: ArpeggioOctaves.three,
        ),
      );
      await tester.pumpWidget(wrap(three));
      await tester.pump();
      expect(find.text("C Major Arpeggio (3 oct)"), findsOneWidget);

      final four = ExerciseHistoryEntry.fromConfiguration(
        id: "a4",
        profileId: "p1",
        completedAt: DateTime(2026),
        config: const ExerciseConfiguration(
          practiceMode: PracticeMode.arpeggios,
          handSelection: HandSelection.both,
          musicalNote: MusicalNote.c,
          arpeggioType: ArpeggioType.major,
          arpeggioOctaves: ArpeggioOctaves.four,
        ),
      );
      await tester.pumpWidget(wrap(four));
      await tester.pump();
      expect(find.text("C Major Arpeggio (4 oct)"), findsOneWidget);
    });

    testWidgets("renders blockChords entry", (tester) async {
      final e = ExerciseHistoryEntry.fromConfiguration(
        id: "bc1",
        profileId: "p1",
        completedAt: DateTime(2026),
        config: const ExerciseConfiguration(
          practiceMode: PracticeMode.blockChords,
          handSelection: HandSelection.both,
          musicalNote: MusicalNote.g,
          arpeggioType: ArpeggioType.minor,
          arpeggioOctaves: ArpeggioOctaves.two,
        ),
      );
      await tester.pumpWidget(wrap(e));
      await tester.pump();
      expect(find.text("G Minor Block Chords (2 oct)"), findsOneWidget);
      expect(find.text("Block Chords"), findsOneWidget);
    });

    testWidgets("renders dominantCadence entry", (tester) async {
      await tester.pumpWidget(wrap(_makeDominantCadenceEntry()));
      await tester.pump();

      expect(find.text("D Dominant Cadence"), findsOneWidget);
      expect(find.text("Dominant Cadence"), findsOneWidget);
    });
  });
}
