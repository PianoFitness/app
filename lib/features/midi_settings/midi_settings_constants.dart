/// Constants for MIDI Settings page UI elements
///
/// Contains feature-specific constants for MIDI configuration interface including
/// icon sizes, spacing values, and scanning/connection timeouts.
class MidiSettingsUIConstants {
  MidiSettingsUIConstants._();

  // Icon sizes
  static const double headerIconSize = 80.0;
  static const double resetInfoIconSize = 32.0;

  // Scanning and connection timeouts
  static const Duration bluetoothInitTimeout = Duration(seconds: 5);
  static const Duration scanningDuration = Duration(seconds: 3);
  static const Duration deviceConnectionDelay = Duration(milliseconds: 500);
}
