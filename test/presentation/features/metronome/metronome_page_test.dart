import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";
import "package:piano_fitness/domain/repositories/metronome_audio_service.dart";
import "package:piano_fitness/presentation/features/metronome/metronome_page.dart";
import "package:provider/provider.dart";

import "../../../shared/test_helpers/mock_repositories.mocks.dart";

void main() {
  group("MetronomePage", () {
    late MockIMetronomeAudioService mockAudioService;

    setUp(() {
      mockAudioService = MockIMetronomeAudioService();
      when(mockAudioService.initialize()).thenAnswer((_) async {});
      when(
        mockAudioService.playClick(volume: anyNamed("volume")),
      ).thenAnswer((_) async {});
      when(mockAudioService.dispose()).thenAnswer((_) async {});
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: Provider<IMetronomeAudioService>.value(
          value: mockAudioService,
          child: const MetronomePage(),
        ),
      );
    }

    testWidgets("displays default tempo and stopped state", (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text("120 BPM"), findsOneWidget);
      expect(
        find.byKey(const Key("metronome_start_stop_button")),
        findsOneWidget,
      );
      expect(find.text("Start"), findsOneWidget);
    });

    testWidgets("tapping start/stop toggles the button label", (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("metronome_start_stop_button")));
      await tester.pump();
      expect(find.text("Stop"), findsOneWidget);

      await tester.tap(find.byKey(const Key("metronome_start_stop_button")));
      await tester.pump();
      expect(find.text("Start"), findsOneWidget);
    });

    testWidgets("bpm increment/decrement buttons adjust the tempo", (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("metronome_bpm_increment")));
      await tester.pump();
      expect(find.text("121 BPM"), findsOneWidget);

      await tester.tap(find.byKey(const Key("metronome_bpm_decrement")));
      await tester.pump();
      await tester.tap(find.byKey(const Key("metronome_bpm_decrement")));
      await tester.pump();
      expect(find.text("119 BPM"), findsOneWidget);
    });

    testWidgets("selecting a time signature chip updates the selection", (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final threeFourChip = find.byKey(
        const Key("metronome_time_signature_3_4"),
      );
      expect(threeFourChip, findsOneWidget);

      await tester.tap(threeFourChip);
      await tester.pump();

      final chip = tester.widget<ChoiceChip>(threeFourChip);
      expect(chip.selected, isTrue);
    });

    testWidgets("mute button toggles the icon", (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.volume_up), findsOneWidget);

      await tester.tap(find.byKey(const Key("metronome_mute_button")));
      await tester.pump();

      expect(find.byIcon(Icons.volume_off), findsOneWidget);
    });
  });
}
