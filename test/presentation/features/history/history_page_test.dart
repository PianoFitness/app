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

      expect(find.text("No practice history yet"), findsOneWidget);
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

      await tester.pumpWidget(
        createTestWidgetWithMocks(
          child: const HistoryPage(),
          userProfileRepository: mockUserProf,
          exerciseHistoryRepository: mockHistoryRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("No practice history yet"), findsOneWidget);
    });

    testWidgets("shows error message when repository throws", (tester) async {
      final mockUserProf = MockIUserProfileRepository();
      final mockHistoryRepo = MockIExerciseHistoryRepository();

      when(mockUserProf.getActiveProfileId()).thenAnswer((_) async => "p1");
      when(
        mockHistoryRepo.getEntriesForProfile("p1"),
      ).thenThrow(Exception("db error"));

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

      await tester.pumpWidget(
        createTestWidgetWithMocks(
          child: const HistoryPage(),
          userProfileRepository: mockUserProf,
          exerciseHistoryRepository: mockHistoryRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HistoryEntryCard), findsNWidgets(2));
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

    testWidgets("renders dominantCadence entry", (tester) async {
      await tester.pumpWidget(wrap(_makeDominantCadenceEntry()));
      await tester.pump();

      expect(find.text("D Dominant Cadence"), findsOneWidget);
      expect(find.text("Dominant Cadence"), findsOneWidget);
    });
  });
}
