/// Value object representing a valid MIDI channel.
///
/// MIDI channels are numbered 0-15 internally (representing MIDI channels 1-16
/// to users). This class ensures that channel values are always valid.
class MidiChannel {
  /// Creates a MIDI channel with the given value.
  ///
  /// Throws [RangeError] if [value] is not in the range 0-15 (inclusive).
  MidiChannel(this.value) {
    if (value < 0 || value > 15) {
      throw RangeError(
        "MIDI channel must be between 0 and 15 (inclusive), but got $value",
      );
    }
  }

  /// The MIDI channel value (0-15).
  final int value;

  /// The minimum valid MIDI channel value.
  static const int min = 0;

  /// The maximum valid MIDI channel value.
  static const int max = 15;

  /// Validates a channel value and returns it if valid.
  ///
  /// Throws [RangeError] if the channel is not in the range 0-15.
  static int validate(int channel) {
    if (channel < min || channel > max) {
      throw RangeError(
        "MIDI channel must be between $min and $max (inclusive), but got $channel",
      );
    }
    return channel;
  }

  /// Checks if a channel value is valid without throwing.
  static bool isValid(int channel) {
    return channel >= min && channel <= max;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MidiChannel &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => "MidiChannel($value)";
}
