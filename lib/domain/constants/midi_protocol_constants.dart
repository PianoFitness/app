/// MIDI protocol specification constants.
///
/// These constants define the valid ranges and default values according to
/// the MIDI 1.0 specification. All values are protocol-defined and should
/// not be changed.
///
/// Domain Layer: Pure business rules independent of frameworks or infrastructure.
class MidiProtocol {
  MidiProtocol._(); // Private constructor to prevent instantiation

  // Data byte ranges (MIDI uses 7-bit values for data)
  /// Minimum value for MIDI data bytes: 0
  static const int dataMin = 0;

  /// Maximum value for MIDI data bytes: 127 (7-bit maximum)
  static const int dataMax = 127;

  // Controller ranges
  /// Maximum value for MIDI controllers: 127
  ///
  /// MIDI Control Change messages use controller numbers 0-127.
  static const int controllerMax = dataMax;

  // Program ranges
  /// Maximum value for MIDI program numbers: 127
  ///
  /// MIDI Program Change messages use program numbers 0-127.
  static const int programMax = dataMax;

  // Velocity ranges
  /// Minimum velocity value: 0
  ///
  /// Velocity of 0 in a Note On message is equivalent to Note Off.
  static const int velocityMin = dataMin;

  /// Maximum velocity value: 127
  static const int velocityMax = dataMax;

  /// Standard default velocity: 64 (medium velocity)
  ///
  /// Used when a neutral velocity value is needed.
  static const int defaultVelocity = 64;

  // Pitch bend ranges
  /// Minimum pitch bend value (raw): 0
  ///
  /// Represents maximum downward pitch bend (typically -2 semitones).
  static const int pitchBendRawMin = 0;

  /// Center pitch bend value (raw): 8192
  ///
  /// Represents no pitch bend (14-bit center value).
  static const int pitchBendRawCenter = 8192;

  /// Maximum pitch bend value (raw): 16383
  ///
  /// Represents maximum upward pitch bend (typically +2 semitones).
  /// This is the maximum 14-bit value (2^14 - 1).
  static const int pitchBendRawMax = 16383;

  /// Minimum pitch bend value (normalized): -1.0
  ///
  /// Normalized representation where -1.0 = maximum downward bend.
  static const double pitchBendNormalizedMin = -1.0;

  /// Center pitch bend value (normalized): 0.0
  ///
  /// Normalized representation where 0.0 = no pitch bend.
  static const double pitchBendNormalizedCenter = 0.0;

  /// Maximum pitch bend value (normalized): 1.0
  ///
  /// Normalized representation where 1.0 = maximum upward bend.
  static const double pitchBendNormalizedMax = 1.0;

  // Note ranges
  /// Minimum MIDI note number: 0 (C-1)
  static const int noteMin = 0;

  /// Maximum MIDI note number: 127 (G9)
  static const int noteMax = 127;

  /// Middle C note number: 60 (C4 in scientific pitch notation)
  static const int middleC = 60;
}
