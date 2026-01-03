/// Constants for Device Controller page UI elements
///
/// Contains feature-specific constants for device controller interface.
/// For MIDI parameter ranges and common icon sizes, see
/// [lib/shared/constants/ui_constants.dart].
class DeviceControllerUIConstants {
  DeviceControllerUIConstants._();

  // Virtual piano key dimensions
  static const double pianoKeyWidth = 40.0;
  static const double pianoKeyHeight = 80.0;
  static const double pianoKeySpacing = 4.0;
  static const double pianoKeyFontSize = 12.0;

  // Piano layout spacing (for black key positioning)
  static const double blackKeyLeftOffset = 18.0;
  static const double blackKeyGroupGap = 40.0;
}
