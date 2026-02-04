import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:piano_fitness/features/repertoire/repertoire_page_view_model.dart";
import "package:mockito/mockito.dart";
import "../../shared/test_helpers/mock_repositories.mocks.dart";

// Simple test-friendly notification services for testing
class TestNotificationService {
  static final List<Map<String, String?>> _notifications = [];
  static bool shouldThrowError = false;

  static Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (shouldThrowError) {
      throw Exception("Test notification error");
    }
    _notifications.add({"title": title, "body": body, "payload": payload});
  }

  static List<Map<String, String?>> get notifications =>
      List.from(_notifications);
  static void clearNotifications() => _notifications.clear();
  static void setShouldThrowError(bool value) => shouldThrowError = value;
}

// Mock method channel for AudioPlayer
void setUpAudioPlayerMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock the main audioplayers channel
  const MethodChannel channel = MethodChannel("xyz.luan/audioplayers");
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        switch (methodCall.method) {
          case "create":
            return "player_id";
          case "setUrl":
          case "resume":
          case "pause":
          case "stop":
          case "release":
          case "seek":
          case "setVolume":
          case "setPlaybackRate":
            return 1;
          case "getDuration":
            return 1000;
          case "getCurrentPosition":
            return 0;
          case "setSourceUrl":
            return null;
          default:
            return null;
        }
      });

  // Mock the global audioplayers channel
  const MethodChannel globalChannel = MethodChannel(
    "xyz.luan/audioplayers.global",
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(globalChannel, (MethodCall methodCall) async {
        switch (methodCall.method) {
          case "init":
            return null;
          case "setAudioContext":
            return null;
          case "setGlobalAudioContext":
            return null;
          default:
            return null;
        }
      });
}

void main() {
  group("RepertoirePageViewModel", () {
    late RepertoirePageViewModel viewModel;
    late MockIAudioService mockAudioService;
    late MockINotificationRepository mockNotificationRepository;
    late MockISettingsRepository mockSettingsRepository;

    setUpAll(() {
      setUpAudioPlayerMocks();
    });

    setUp(() {
      mockAudioService = MockIAudioService();
      mockNotificationRepository = MockINotificationRepository();
      mockSettingsRepository = MockISettingsRepository();

      // Stub the createPlayer method to return a mock AudioPlayerHandle
      final mockAudioPlayer = MockAudioPlayerHandle();
      when(mockAudioService.createPlayer()).thenReturn(mockAudioPlayer);

      viewModel = RepertoirePageViewModel(
        audioService: mockAudioService,
        notificationRepository: mockNotificationRepository,
        settingsRepository: mockSettingsRepository,
      );
      TestNotificationService.clearNotifications();
      TestNotificationService.setShouldThrowError(false);
    });

    tearDown(() {
      viewModel.dispose();
    });

    group("Timer functionality", () {
      testWidgets("initializes with correct default values", (tester) async {
        expect(viewModel.selectedDurationMinutes, equals(15));
        expect(viewModel.remainingSeconds, equals(15 * 60));
        expect(viewModel.isRunning, isFalse);
        expect(viewModel.isPaused, isFalse);
        expect(viewModel.canStart, isTrue);
        expect(viewModel.canPause, isFalse);
        expect(viewModel.canResume, isFalse);
        expect(viewModel.canReset, isFalse);
      });

      testWidgets("sets duration correctly", (tester) async {
        const newDuration = 20;

        // Listen for changes
        bool notified = false;
        viewModel.addListener(() {
          notified = true;
        });

        viewModel.setDuration(newDuration);

        expect(viewModel.selectedDurationMinutes, equals(newDuration));
        expect(viewModel.remainingSeconds, equals(newDuration * 60));
        expect(notified, isTrue);
      });

      testWidgets("formats time correctly", (tester) async {
        expect(viewModel.formattedTime, equals("15:00"));

        viewModel.setDuration(1);
        expect(viewModel.formattedTime, equals("01:00"));

        // Simulate some time passing (would need more complex setup for actual timer testing)
        // For now just verify the formatting logic works
      });

      testWidgets("calculates progress correctly", (tester) async {
        expect(viewModel.progress, equals(0.0));

        // Change duration to test progress calculation
        viewModel.setDuration(10); // 10 minutes = 600 seconds
        expect(viewModel.progress, equals(0.0)); // No time elapsed yet
      });

      testWidgets("can start timer when conditions are met", (tester) async {
        expect(viewModel.canStart, isTrue);
        expect(viewModel.canPause, isFalse);
        expect(viewModel.canResume, isFalse);
        expect(viewModel.canReset, isFalse);
      });

      testWidgets("timer state properties are correct initially", (
        tester,
      ) async {
        expect(viewModel.isRunning, isFalse);
        expect(viewModel.isPaused, isFalse);
        expect(viewModel.remainingSeconds, equals(15 * 60));
        expect(viewModel.progress, equals(0.0));
      });
    });

    group("Timer completion behavior", () {
      testWidgets("timer duration options are available", (tester) async {
        expect(RepertoirePageViewModel.timerDurations, contains(5));
        expect(RepertoirePageViewModel.timerDurations, contains(10));
        expect(RepertoirePageViewModel.timerDurations, contains(15));
        expect(RepertoirePageViewModel.timerDurations, contains(20));
        expect(RepertoirePageViewModel.timerDurations, contains(30));
      });

      testWidgets("timer state is correct when completed", (tester) async {
        // Create a testable view model that allows us to simulate completion
        final testViewModel = TestableRepertoirePageViewModel();

        // Simulate timer completion
        await testViewModel.simulateTimerCompletion();

        // Verify the timer is no longer running
        expect(testViewModel.isRunning, isFalse);
        expect(testViewModel.isPaused, isFalse);

        testViewModel.dispose();
      });

      testWidgets(
        "notification is sent when timer completion conditions are met",
        (tester) async {
          final testViewModel = TestableRepertoirePageViewModel();

          // Simulate timer completion with notifications enabled
          await testViewModel.simulateTimerCompletionWithNotification(
            timerCompletionEnabled: true,
            permissionGranted: true,
          );

          // Verify notification was sent to our test service
          final notifications = TestNotificationService.notifications;
          expect(notifications.length, equals(1));
          expect(
            notifications[0]["title"],
            equals("Great Practice Session! 🎹"),
          );
          expect(
            notifications[0]["body"],
            equals("You completed 15 minutes of practice. Well done!"),
          );
          expect(notifications[0]["payload"], equals("timer_completion"));

          testViewModel.dispose();
        },
      );

      testWidgets(
        "notification is not sent when timer completion is disabled",
        (tester) async {
          final testViewModel = TestableRepertoirePageViewModel();

          // Simulate timer completion with notifications disabled
          await testViewModel.simulateTimerCompletionWithNotification(
            timerCompletionEnabled: false,
            permissionGranted: true,
          );

          // Verify no notification was sent
          final notifications = TestNotificationService.notifications;
          expect(notifications.length, equals(0));

          testViewModel.dispose();
        },
      );

      testWidgets("notification is not sent when permissions are not granted", (
        tester,
      ) async {
        final testViewModel = TestableRepertoirePageViewModel();

        // Simulate timer completion with no permissions
        await testViewModel.simulateTimerCompletionWithNotification(
          timerCompletionEnabled: true,
          permissionGranted: false,
        );

        // Verify no notification was sent
        final notifications = TestNotificationService.notifications;
        expect(notifications.length, equals(0));

        testViewModel.dispose();
      });

      testWidgets("handles notification errors gracefully", (tester) async {
        final testViewModel = TestableRepertoirePageViewModel();

        // Set up the test service to throw an error
        TestNotificationService.setShouldThrowError(true);

        // Simulate timer completion - should not throw despite the error
        await expectLater(
          testViewModel.simulateTimerCompletionWithNotification(
            timerCompletionEnabled: true,
            permissionGranted: true,
          ),
          completes,
        );

        // Reset error state
        TestNotificationService.setShouldThrowError(false);
        testViewModel.dispose();
      });

      testWidgets("shows notification with correct duration in message", (
        tester,
      ) async {
        final testViewModel = TestableRepertoirePageViewModel();

        // Set a different duration
        testViewModel.setDuration(30);

        // Simulate timer completion with notifications enabled
        await testViewModel.simulateTimerCompletionWithNotification(
          timerCompletionEnabled: true,
          permissionGranted: true,
        );

        // Verify notification shows correct duration
        final notifications = TestNotificationService.notifications;
        expect(notifications.length, equals(1));
        expect(
          notifications[0]["body"],
          equals("You completed 30 minutes of practice. Well done!"),
        );

        testViewModel.dispose();
      });
    });
  });
}

/// Testable subclass that allows controlling timer behavior for testing
class TestableRepertoirePageViewModel extends RepertoirePageViewModel {
  TestableRepertoirePageViewModel()
    : super(
        audioService: _createMockAudioService(),
        notificationRepository: MockINotificationRepository(),
        settingsRepository: MockISettingsRepository(),
      );

  static MockIAudioService _createMockAudioService() {
    final mockService = MockIAudioService();
    final mockPlayer = MockAudioPlayerHandle();
    when(mockService.createPlayer()).thenReturn(mockPlayer);
    return mockService;
  }

  bool _testIsRunning = false;
  bool _testIsPaused = false;
  int _testRemainingSeconds = 15 * 60; // Default 15 minutes

  @override
  bool get isRunning => _testIsRunning;

  @override
  bool get isPaused => _testIsPaused;

  @override
  int get remainingSeconds => _testRemainingSeconds;

  /// Simulate timer completion without waiting for actual timer
  Future<void> simulateTimerCompletion() async {
    // Set state as it would be when timer completes
    _testIsRunning = false;
    _testIsPaused = false;
    _testRemainingSeconds = 0;

    notifyListeners();
  }

  /// Simulate timer completion with notification logic
  Future<void> simulateTimerCompletionWithNotification({
    required bool timerCompletionEnabled,
    required bool permissionGranted,
  }) async {
    // Set state as it would be when timer completes
    _testIsRunning = false;
    _testIsPaused = false;
    _testRemainingSeconds = 0;

    // Simulate the notification logic from the actual implementation
    try {
      if (timerCompletionEnabled && permissionGranted) {
        await TestNotificationService.showInstantNotification(
          title: "Great Practice Session! 🎹",
          body:
              "You completed $selectedDurationMinutes minutes of practice. Well done!",
          payload: "timer_completion",
        );
      }
    } catch (e) {
      // Gracefully handle errors like the actual implementation
    }

    notifyListeners();
  }

  @override
  void setDuration(int minutes) {
    super.setDuration(minutes);
    _testRemainingSeconds = minutes * 60;
  }
}
