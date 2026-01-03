/// Constants for MIDI Settings page UI elements
///
/// Contains feature-specific constants for MIDI configuration interface.
/// For common icon sizes and MIDI ranges, see [lib/shared/constants/ui_constants.dart].
class MidiSettingsUIConstants {
  MidiSettingsUIConstants._();

  // Scanning and connection timeouts
  static const Duration bluetoothInitTimeout = Duration(seconds: 5);
  static const Duration scanningDuration = Duration(seconds: 3);
  static const Duration deviceConnectionDelay = Duration(milliseconds: 500);
}
