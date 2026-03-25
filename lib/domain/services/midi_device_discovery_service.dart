import "package:piano_fitness/domain/repositories/midi_repository.dart";

/// Domain-level Bluetooth status, independent of any platform library.
enum BluetoothStatus {
  unsupported,
  poweredOff,
  poweredOn,
  resetting,
  unauthorized,
  unknown,
  other,
}

/// Abstracts MIDI device discovery and Bluetooth lifecycle management.
///
/// This interface covers operations that go beyond MIDI data streaming
/// (handled by [IMidiRepository]): device scanning, Bluetooth initialization,
/// and device connection lifecycle.
abstract class IMidiDeviceDiscoveryService {
  /// Fires whenever the MIDI device setup changes (device added/removed).
  Stream<void> get setupChanged;

  /// Fires when the Bluetooth status changes.
  Stream<BluetoothStatus> get bluetoothStatusChanged;

  /// Current Bluetooth status (synchronous read).
  BluetoothStatus get bluetoothStatus;

  /// Returns the current list of available MIDI devices.
  Future<List<MidiDevice>> getDevices();

  /// Initializes the Bluetooth central role on this device.
  Future<void> startBluetoothCentral();

  /// Waits until Bluetooth is fully initialized.
  Future<void> waitUntilBluetoothIsInitialized();

  /// Begins scanning for nearby Bluetooth MIDI devices.
  Future<void> startScanning();

  /// Stops an in-progress Bluetooth scan.
  void stopScanning();

  /// Connects to the given [device].
  Future<void> connectToDevice(MidiDevice device);

  /// Disconnects the given [device].
  Future<void> disconnectDevice(MidiDevice device);

  /// Releases any resources held by the service.
  void dispose();
}
