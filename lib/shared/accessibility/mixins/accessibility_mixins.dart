import "package:flutter/material.dart";
import "package:piano_fitness/shared/accessibility/config/accessibility_labels.dart";
import "package:piano_fitness/shared/accessibility/services/musical_announcements_service.dart";

/// A mixin providing accessibility announcement capabilities.
///
/// This mixin can be used with StatefulWidget classes to add
/// screen reader announcement functionality for musical events.
mixin AccessibilityAnnouncementMixin<T extends StatefulWidget> on State<T> {
  /// Announces a note being played.
  void announceNote(String note, {Duration delay = Duration.zero}) {
    if (delay == Duration.zero) {
      MusicalAnnouncementsService.announceNote(note);
    } else {
      Future.delayed(delay, () {
        if (mounted) {
          MusicalAnnouncementsService.announceNote(note);
        }
      });
    }
  }

  /// Announces a chord being played.
  void announceChord(List<String> notes, {Duration delay = Duration.zero}) {
    if (delay == Duration.zero) {
      MusicalAnnouncementsService.announceChord(notes);
    } else {
      Future.delayed(delay, () {
        if (mounted) {
          MusicalAnnouncementsService.announceChord(notes);
        }
      });
    }
  }

  /// Announces a status change.
  void announceStatus(String status, {Duration delay = Duration.zero}) {
    if (delay == Duration.zero) {
      MusicalAnnouncementsService.announceStatus(status);
    } else {
      Future.delayed(delay, () {
        if (mounted) {
          MusicalAnnouncementsService.announceStatus(status);
        }
      });
    }
  }

  /// Announces an error with appropriate semantic markup.
  void announceError(String error, {Duration delay = Duration.zero}) {
    if (delay == Duration.zero) {
      MusicalAnnouncementsService.announceError(error);
    } else {
      Future.delayed(delay, () {
        if (mounted) {
          MusicalAnnouncementsService.announceError(error);
        }
      });
    }
  }
}

/// A mixin providing semantic wrapper utilities.
///
/// This mixin provides common semantic wrapper methods that can be
/// used across different widgets to ensure consistent accessibility.
mixin SemanticWrapperMixin {
  /// Wraps a widget with button semantics.
  Widget wrapAsButton({
    required Widget child,
    required String label,
    String? hint,
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      hint: hint,
      onTap: onTap,
      child: child,
    );
  }

  /// Wraps a widget with container semantics.
  Widget wrapAsContainer({required Widget child, String? label, String? hint}) {
    return Semantics(container: true, label: label, hint: hint, child: child);
  }

  /// Wraps a widget with header semantics.
  Widget wrapAsHeader({required Widget child, String? label}) {
    return Semantics(header: true, label: label, child: child);
  }

  /// Wraps a widget with live region semantics.
  Widget wrapAsLiveRegion({required Widget child, String? label}) {
    return Semantics(liveRegion: true, label: label, child: child);
  }

  /// Wraps a widget with slider semantics for continuous values.
  Widget wrapAsSlider({
    required Widget child,
    required double value,
    required double max,
    double min = 0.0,
    String? label,
    String? hint,
    ValueChanged<double>? onChanged,
  }) {
    return Semantics(
      slider: true,
      enabled: onChanged != null,
      value: "${value.toInt()} of ${max.toInt()}",
      label: label,
      hint: hint,
      onIncrease: onChanged != null
          ? () {
              final newValue = (value + ((max - min) / 10)).clamp(min, max);
              onChanged(newValue);
            }
          : null,
      onDecrease: onChanged != null
          ? () {
              final newValue = (value - ((max - min) / 10)).clamp(min, max);
              onChanged(newValue);
            }
          : null,
      child: child,
    );
  }
}

/// A mixin providing MIDI-specific accessibility patterns.
///
/// This mixin provides common accessibility patterns specifically
/// for MIDI-related functionality and device management.
mixin MidiAccessibilityMixin {
  /// Creates semantic markup for MIDI device status.
  Widget createDeviceStatusSemantic({
    required Widget child,
    required bool isConnected,
    required String deviceName,
  }) {
    final status = isConnected
        ? AccessibilityLabels.midiDeviceConnected(deviceName)
        : AccessibilityLabels.midiDeviceDisconnected(deviceName);

    return Semantics(liveRegion: true, label: status, child: child);
  }

  /// Creates semantic markup for MIDI connection buttons.
  Widget createConnectionButtonSemantic({
    required Widget child,
    required bool isConnected,
    required String deviceName,
    VoidCallback? onPressed,
  }) {
    final label = isConnected
        ? AccessibilityLabels.disconnectDevice(deviceName)
        : AccessibilityLabels.connectDevice(deviceName);

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      onTap: onPressed,
      child: child,
    );
  }

  /// Creates semantic markup for MIDI channel selection.
  Widget createChannelSelectorSemantic({
    required Widget child,
    required int currentChannel,
    required int totalChannels,
    ValueChanged<int>? onChanged,
  }) {
    return Semantics(
      slider: true,
      enabled: onChanged != null,
      value: "$currentChannel of $totalChannels",
      label: AccessibilityLabels.midiChannelLabel,
      hint: AccessibilityLabels.midiChannelHint(currentChannel, totalChannels),
      onIncrease: onChanged != null && currentChannel < totalChannels
          ? () => onChanged(currentChannel + 1)
          : null,
      onDecrease: onChanged != null && currentChannel > 1
          ? () => onChanged(currentChannel - 1)
          : null,
      child: child,
    );
  }
}

/// A mixin providing timer-specific accessibility patterns.
///
/// This mixin provides accessibility patterns for timer controls
/// commonly used in practice and play modes.
mixin TimerAccessibilityMixin {
  /// Creates semantic markup for timer display.
  Widget createTimerDisplaySemantic({
    required Widget child,
    required Duration duration,
    bool isRunning = false,
  }) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final timeText =
        "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";

    final label = isRunning
        ? AccessibilityLabels.timerRunning(timeText)
        : AccessibilityLabels.timerStopped(timeText);

    return Semantics(liveRegion: true, label: label, child: child);
  }

  /// Creates semantic markup for timer control buttons.
  Widget createTimerControlSemantic({
    required Widget child,
    required TimerAction action,
    bool enabled = true,
    VoidCallback? onPressed,
  }) {
    String label;
    String? hint;

    switch (action) {
      case TimerAction.start:
        label = AccessibilityLabels.startTimer;
        hint = AccessibilityLabels.startTimerHint;
        break;
      case TimerAction.pause:
        label = AccessibilityLabels.pauseTimer;
        hint = AccessibilityLabels.pauseTimerHint;
        break;
      case TimerAction.reset:
        label = AccessibilityLabels.resetTimer;
        hint = AccessibilityLabels.resetTimerHint;
        break;
    }

    return Semantics(
      button: true,
      enabled: enabled && onPressed != null,
      label: label,
      hint: hint,
      onTap: onPressed,
      child: child,
    );
  }
}

/// Enumeration of timer actions for semantic labeling.
enum TimerAction {
  /// Start the timer.
  start,

  /// Pause the timer.
  pause,

  /// Reset the timer.
  reset,
}
