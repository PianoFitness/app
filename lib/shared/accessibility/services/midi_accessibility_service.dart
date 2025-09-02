import "package:flutter/material.dart";
import "package:piano_fitness/shared/accessibility/config/accessibility_labels.dart";

/// Service for MIDI device and controls accessibility.
///
/// This service provides semantic descriptions and labels for MIDI device
/// information, connection status, and control interfaces.
class MidiAccessibilityService {
  /// Creates a semantic description for device information.
  ///
  /// The [deviceName], [deviceType], and [deviceId] provide device details.
  /// The [isConnected] indicates the current connection status.
  /// The [inputPorts] and [outputPorts] specify the available ports.
  /// Returns a comprehensive device description for screen readers.
  static String getDeviceDescription({
    required String deviceName,
    required String deviceType,
    required String deviceId,
    required bool isConnected,
    required int inputPorts,
    required int outputPorts,
  }) {
    final parts = <String>[
      AccessibilityLabels.midi.deviceName(deviceName),
      AccessibilityLabels.midi.deviceType(deviceType),
      AccessibilityLabels.midi.deviceId(deviceId),
      AccessibilityLabels.midi.connectionStatus(isConnected),
      AccessibilityLabels.midi.inputPorts(inputPorts),
      AccessibilityLabels.midi.outputPorts(outputPorts),
    ];

    return parts.join(". ");
  }

  /// Creates semantic labels for device information fields.
  static String deviceNameLabel(String name) =>
      AccessibilityLabels.midi.deviceName(name);

  static String deviceTypeLabel(String type) =>
      AccessibilityLabels.midi.deviceType(type);

  static String deviceIdLabel(String id) =>
      AccessibilityLabels.midi.deviceId(id);

  static String connectionStatusLabel(bool isConnected) =>
      AccessibilityLabels.midi.connectionStatus(isConnected);

  static String inputPortsLabel(int count) =>
      AccessibilityLabels.midi.inputPorts(count);

  static String outputPortsLabel(int count) =>
      AccessibilityLabels.midi.outputPorts(count);

  /// Creates semantic labels for MIDI channel controls.
  static String currentChannelLabel(int channel) =>
      AccessibilityLabels.midi.currentChannel(channel);

  static String channelHintLabel(int channel) =>
      AccessibilityLabels.midi.channelHint(channel);

  static String get increaseChannelLabel => MidiLabels.increaseChannel;

  static String get decreaseChannelLabel => MidiLabels.decreaseChannel;

  static String get channelDescriptionLabel => MidiLabels.channelDescription;

  /// Creates semantic labels for MIDI status.
  static String statusLabel(String status) =>
      AccessibilityLabels.midi.statusLabel(status);

  /// Creates semantic labels for MIDI actions.
  static String get retryActionLabel => MidiLabels.retryAction;

  static String get backActionLabel => MidiLabels.backAction;

  /// Creates an accessible wrapper for device information widgets.
  ///
  /// This provides a semantic container with proper structure for
  /// device information displays.
  static Widget createDeviceInfoWrapper({
    required Widget child,
    required String deviceName,
    required bool isConnected,
  }) {
    final statusDescription = AccessibilityLabels.midi.connectionStatus(
      isConnected,
    );
    final description =
        "Device information for $deviceName. $statusDescription";

    return Semantics(
      label: "Device Information",
      hint: description,
      container: true,
      child: child,
    );
  }

  /// Creates an accessible wrapper for MIDI channel controls.
  ///
  /// This provides semantic structure for channel increment/decrement controls.
  static Widget createChannelControlWrapper({
    required Widget child,
    required int currentChannel,
  }) {
    final description = AccessibilityLabels.midi.currentChannel(currentChannel);

    return Semantics(
      label: "MIDI Channel Controls",
      hint: description,
      container: true,
      child: child,
    );
  }

  /// Creates an accessible wrapper for MIDI status displays.
  ///
  /// This provides live region announcements for status changes.
  static Widget createStatusWrapper({
    required Widget child,
    required String status,
  }) {
    final description = AccessibilityLabels.midi.statusLabel(status);

    return Semantics(label: description, liveRegion: true, child: child);
  }
}
