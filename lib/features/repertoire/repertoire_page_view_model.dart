import "dart:async";
import "package:audioplayers/audioplayers.dart";
import "package:flutter/foundation.dart";
import "package:flutter/services.dart";

/// ViewModel for managing repertoire page state and logic.
///
/// This class handles the business logic for the repertoire page,
/// managing timer state and providing guidance for repertoire practice.
class RepertoirePageViewModel extends ChangeNotifier {
  /// Creates a new RepertoirePageViewModel.
  RepertoirePageViewModel() {
    _player = AudioPlayer();
  }

  late final AudioPlayer _player;
  Timer? _timer;

  // Timer state
  int _selectedDurationMinutes = 15; // Default 15 minutes
  int _remainingSeconds = 15 * 60; // 15 minutes in seconds
  bool _isRunning = false;
  bool _isPaused = false;

  /// Available timer duration options in minutes.
  static const List<int> timerDurations = [5, 10, 15, 20, 30];

  /// Currently selected timer duration in minutes.
  int get selectedDurationMinutes => _selectedDurationMinutes;

  /// Remaining time in seconds.
  int get remainingSeconds => _remainingSeconds;

  /// Whether the timer is currently running.
  bool get isRunning => _isRunning;

  /// Whether the timer is currently paused.
  bool get isPaused => _isPaused;

  /// Whether the timer can be started (not running and has time remaining).
  bool get canStart => !_isRunning && _remainingSeconds > 0;

  /// Whether the timer can be paused (currently running).
  bool get canPause => _isRunning && !_isPaused;

  /// Whether the timer can be resumed (paused).
  bool get canResume => _isRunning && _isPaused;

  /// Whether the timer can be reset.
  bool get canReset =>
      _isRunning || _remainingSeconds != _selectedDurationMinutes * 60;

  /// Formatted remaining time as MM:SS.
  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  /// Progress value between 0.0 and 1.0.
  double get progress {
    final totalSeconds = _selectedDurationMinutes * 60;
    if (totalSeconds == 0) return 1.0;
    return 1.0 - (_remainingSeconds / totalSeconds);
  }

  /// Sets the timer duration and resets the timer.
  void setDuration(int minutes) {
    if (_selectedDurationMinutes != minutes) {
      _selectedDurationMinutes = minutes;
      _resetTimer();
      notifyListeners();
    }
  }

  /// Starts the timer.
  void startTimer() {
    if (!canStart) return;

    _isRunning = true;
    _isPaused = false;
    _startCountdown();

    // Provide haptic feedback for accessibility
    HapticFeedback.lightImpact();

    notifyListeners();
  }

  /// Pauses the timer.
  void pauseTimer() {
    if (!canPause) return;

    _isPaused = true;
    _timer?.cancel();

    // Provide haptic feedback for accessibility
    HapticFeedback.lightImpact();

    notifyListeners();
  }

  /// Resumes the timer.
  void resumeTimer() {
    if (!canResume) return;

    _isPaused = false;
    _startCountdown();

    // Provide haptic feedback for accessibility
    HapticFeedback.lightImpact();

    notifyListeners();
  }

  /// Resets the timer to the selected duration.
  void resetTimer() {
    _resetTimer();

    // Provide haptic feedback for accessibility
    HapticFeedback.lightImpact();

    notifyListeners();
  }

  void _resetTimer() {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;
    _remainingSeconds = _selectedDurationMinutes * 60;
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _timerCompleted();
      }
    });
  }

  Future<void> _timerCompleted() async {
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;

    // Play completion sound
    try {
      await _player.play(
        AssetSource("audio/218851__kellyconidi__highbell.mp3"),
      );
    } catch (e) {
      debugPrint("Error playing timer completion sound: $e");
    }

    // Provide strong haptic feedback for completion
    HapticFeedback.heavyImpact();

    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    super.dispose();
  }
}
