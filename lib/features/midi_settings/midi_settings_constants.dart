/// Constants for MIDI Settings page UI elements
///
/// Contains feature-specific constants for MIDI configuration interface.
/// For common icon sizes, MIDI ranges, and timing values, see
/// [lib/shared/constants/ui_constants.dart].
///
/// ## Migration Notes
/// All timing constants have been moved to [MidiConstants] in ui_constants.dart:
/// - bluetoothInitTimeout → MidiConstants.bluetoothInitTimeout
/// - scanningDuration → MidiConstants.scanningDuration
/// - deviceConnectionDelay → MidiConstants.connectionDelay
///
/// This file is intentionally minimal as all constants were duplicates
/// of shared values. It is retained for future MIDI settings-specific
/// constants that may be needed.
class MidiSettingsUIConstants {
  MidiSettingsUIConstants._();

  // No feature-specific constants currently needed.
  // All timing constants moved to MidiConstants in ui_constants.dart.
}
