/// Types of MIDI events that can be parsed by the MidiService.
///
/// These categories help the application respond appropriately to different
/// kinds of MIDI messages from connected devices.
enum MidiEventType {
  /// Note on message - key pressed with velocity > 0
  noteOn,

  /// Note off message - key released or note on with velocity 0
  noteOff,

  /// Control change message - knobs, sliders, pedals, etc.
  controlChange,

  /// Program change message - instrument/patch selection
  programChange,

  /// Pitch bend message - pitch wheel movement
  pitchBend,

  /// Any other MIDI message not specifically categorized above
  other,
}

/// Represents a parsed MIDI event with all relevant information.
///
/// This class encapsulates all the components of a MIDI message after parsing,
/// making it easier to handle different types of MIDI events consistently
/// throughout the application.
class MidiEvent {
  /// Creates a new MIDI event with all required components.
  const MidiEvent({
    required this.status,
    required this.channel,
    required this.data1,
    required this.data2,
    required this.type,
    String? displayMessage,
  }) : _displayMessage = displayMessage;

  /// The raw MIDI status byte including channel information.
  final int status;

  /// The MIDI channel number (1-16, human-readable format).
  final int channel;

  /// First data byte (note number, controller number, etc.).
  final int data1;

  /// Second data byte (velocity, controller value, etc.).
  final int data2;

  /// The categorized type of this MIDI event.
  final MidiEventType type;

  final String? _displayMessage;

  /// Human-readable description of this MIDI event for debugging/display.
  /// Computed lazily if not explicitly provided during construction.
  String get displayMessage => _displayMessage ?? _buildDisplayMessage();

  String _buildDisplayMessage() {
    switch (type) {
      case MidiEventType.noteOn:
        return "Note ON: $data1 (Ch: $channel, Vel: $data2)";
      case MidiEventType.noteOff:
        return "Note OFF: $data1 (Ch: $channel)";
      case MidiEventType.controlChange:
        return "CC: Controller $data1 = $data2 (Ch: $channel)";
      case MidiEventType.programChange:
        return "Program Change: $data1 (Ch: $channel)";
      case MidiEventType.pitchBend:
        return "Pitch Bend: ${pitchBendValue.toStringAsFixed(2)} (Ch: $channel)";
      case MidiEventType.other:
        return "MIDI: Status 0x${status.toRadixString(16).toUpperCase().padLeft(2, '0')} Data1: 0x${data1.toRadixString(16).toUpperCase().padLeft(2, '0')} Data2: 0x${data2.toRadixString(16).toUpperCase().padLeft(2, '0')}";
    }
  }

  /// Normalized pitch bend value in the range -1.0 (min) to 1.0 (max).
  ///
  /// Only meaningful when [type] is [MidiEventType.pitchBend].
  /// Uses the standard 14-bit MIDI pitch bend encoding: [data1] is the LSB
  /// and [data2] is the MSB of the 14-bit value.
  double get pitchBendValue {
    final rawPitch = data1 + (data2 << 7);
    return ((rawPitch / 0x3FFF) * 2.0) - 1;
  }
}
