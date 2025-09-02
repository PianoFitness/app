/// Piano modes that affect accessibility context
enum PianoMode {
  /// Free play mode
  play,

  /// Guided practice mode
  practice,

  /// Scale and chord reference mode
  reference,
}

/// Main accessibility labels configuration
class AccessibilityLabels {
  /// Piano-specific accessibility labels
  static const piano = PianoLabels();

  /// MIDI device and controls labels
  static const midi = MidiLabels();

  /// Timer and practice session labels
  static const timer = TimerLabels();

  /// Navigation and UI element labels
  static const ui = UILabels();

  /// MIDI device connection/disconnection messages.
  static String midiDeviceConnected(String deviceName) =>
      "MIDI device $deviceName connected";

  static String midiDeviceDisconnected(String deviceName) =>
      "MIDI device $deviceName disconnected";

  static String connectDevice(String deviceName) => "Connect to $deviceName";

  static String disconnectDevice(String deviceName) =>
      "Disconnect from $deviceName";

  /// MIDI channel labels.
  static const String midiChannelLabel = "MIDI Channel";

  static String midiChannelHint(int current, int total) =>
      "Channel $current of $total. Use volume buttons to change.";

  /// Timer labels.
  static const String startTimer = "Start Timer";
  static const String pauseTimer = "Pause Timer";
  static const String resetTimer = "Reset Timer";

  static const String startTimerHint = "Begin timing your practice session";
  static const String pauseTimerHint = "Pause the current timer";
  static const String resetTimerHint = "Reset timer to zero";

  static String timerRunning(String time) => "Timer running: $time";
  static String timerStopped(String time) => "Timer stopped at: $time";
}

/// Piano keyboard accessibility labels
class PianoLabels {
  const PianoLabels();

  /// Get context-appropriate keyboard label based on mode
  String keyboardLabel(PianoMode mode) => switch (mode) {
    PianoMode.play => "Play mode piano keyboard",
    PianoMode.practice => "Practice mode piano keyboard",
    PianoMode.reference => "Reference mode piano keyboard",
  };

  /// Get keyboard hint based on mode
  String keyboardHint(PianoMode mode) => switch (mode) {
    PianoMode.play => "Piano keyboard for free play and experimentation",
    PianoMode.practice => "Piano keyboard for guided practice exercises",
    PianoMode.reference => "Piano keyboard showing scale and chord patterns",
  };

  /// Generate highlighted notes announcement
  String highlightedNotes(List<String> noteNames) => switch (noteNames.length) {
    0 => "No notes highlighted",
    1 => "${noteNames.first} highlighted",
    _ => "${noteNames.length} notes highlighted: ${noteNames.join(', ')}",
  };

  /// Generate note change announcement
  String noteChange(List<String> noteNames) => switch (noteNames.length) {
    0 => "Notes cleared",
    1 => "${noteNames.first} now highlighted",
    _ => "${noteNames.length} notes now highlighted: ${noteNames.join(', ')}",
  };

  /// Single piano key description
  String keyDescription(String noteName, bool isHighlighted) =>
      "$noteName piano key${isHighlighted ? ' highlighted' : ''}";
}

/// MIDI device and controls accessibility labels
class MidiLabels {
  const MidiLabels();

  /// Device connection status
  String connectionStatus(bool isConnected) =>
      "Device is ${isConnected ? 'connected' : 'disconnected'}";

  /// Device information labels
  String deviceName(String name) => "Device name is $name";
  String deviceType(String type) => "Device type is $type";
  String deviceId(String id) => "Device ID is $id";
  String inputPorts(int count) =>
      "Device has $count input ${count == 1 ? 'port' : 'ports'}";
  String outputPorts(int count) =>
      "Device has $count output ${count == 1 ? 'port' : 'ports'}";

  /// Channel selector labels
  String currentChannel(int channel) => "MIDI Channel $channel";
  String channelHint(int channel) => "Currently set to channel $channel";
  static const String increaseChannel = "Increase MIDI channel";
  static const String decreaseChannel = "Decrease MIDI channel";
  static const String channelDescription =
      "Channel for virtual piano output, ranges from 1 to 16";

  /// Status announcements
  String statusLabel(String status) => "MIDI status: $status";
  static const String retryAction = "Retry MIDI setup";
  static const String backAction = "Return to previous screen";
}

/// Timer and practice session accessibility labels
class TimerLabels {
  const TimerLabels();

  /// Timer display labels
  String timerDisplay(String formattedTime) =>
      "Timer display: $formattedTime remaining";
  String timerStatus(String status, String time) => "$status. $time remaining.";

  /// Timer control actions
  static const String startTimer = "Start timer";
  static const String resumeTimer = "Resume timer";
  static const String pauseTimer = "Pause timer";
  static const String resetTimer = "Reset timer";

  /// Timer state announcements
  static const String timerStarted = "Timer started";
  static const String timerResumed = "Timer resumed";
  static const String timerPaused = "Timer paused";
  String timerReset(int minutes) => "Timer reset to $minutes minutes";

  /// Timer status descriptions
  static const String runningStatus = "Timer Running";
  static const String pausedStatus = "Timer Paused";
  static const String completedStatus = "Session Complete!";
  static const String readyStatus = "Ready to Start";
}

/// General UI element accessibility labels
class UILabels {
  const UILabels();

  /// Common semantic roles
  static const String header = "Section header";
  static const String button = "Button";
  static const String selector = "Selector";
  static const String display = "Display";

  /// Navigation labels
  static const String mainNavigation = "Main navigation";
  static const String backButton = "Navigate back";
  static const String menuButton = "Open menu";

  /// Status and feedback
  static const String loading = "Loading";
  static const String error = "Error";
  static const String success = "Success";
  static const String warning = "Warning";

  /// Form controls
  static const String required = "Required field";
  static const String optional = "Optional field";
  static const String invalid = "Invalid input";
  static const String valid = "Valid input";
}
