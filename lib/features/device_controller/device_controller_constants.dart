/// Constants for Device Controller page UI elements
///
/// Contains feature-specific constants for device controller interface including
/// piano key dimensions, MIDI parameter ranges, and spacing values.
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

  // MIDI parameter ranges
  static const int midiChannelMin = 0;
  static const int midiChannelMax = 15;
  static const int midiControllerMax = 127;
  static const int midiProgramMax = 127;
  static const double pitchBendMin = -1.0;
  static const double pitchBendMax = 1.0;
  static const int pitchBendDivisions = 100;

  // Default MIDI values
  static const int defaultVelocity = 64;
}
