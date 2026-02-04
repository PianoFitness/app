/// MIDI connection and infrastructure configuration constants.
///
/// These constants define timeouts, delays, and other infrastructure-related
/// values for MIDI device connection and communication.
///
/// Application Layer: Service orchestration and infrastructure coordination.
class MidiConnectionConfig {
  MidiConnectionConfig._(); // Private constructor to prevent instantiation

  // Connection timeouts
  /// Bluetooth initialization timeout: 5 seconds
  ///
  /// Maximum time to wait for Bluetooth adapter initialization.
  /// If initialization takes longer, the operation will timeout.
  static const Duration bluetoothInitTimeout = Duration(seconds: 5);

  /// Device scanning duration: 3 seconds
  ///
  /// How long to scan for MIDI devices before stopping.
  /// Provides a balance between discovery time and user experience.
  static const Duration scanningDuration = Duration(seconds: 3);

  /// Delay before device connection: 500 milliseconds
  ///
  /// Brief pause before attempting to connect to a device.
  /// Allows the device to stabilize after selection.
  static const Duration connectionDelay = Duration(milliseconds: 500);

  /// Device discovery timeout: 10 seconds
  ///
  /// Maximum time to wait for device discovery to complete.
  static const Duration discoveryTimeout = Duration(seconds: 10);

  /// Connection attempt timeout: 5 seconds
  ///
  /// Maximum time to wait for a single connection attempt.
  static const Duration connectionTimeout = Duration(seconds: 5);
}
