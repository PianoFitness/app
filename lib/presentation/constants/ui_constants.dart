/// Shared UI constants for consistent spacing, sizing, and timing across the app.
///
/// This file provides Material Design-inspired constants for building
/// consistent, maintainable UIs throughout Piano Fitness.
library;

import "dart:ui";
import "package:piano_fitness/domain/models/midi_channel.dart";

/// Standardized spacing values following Material Design guidelines.
///
/// Use these for consistent padding, margins, and gaps throughout the app.
/// Based on the 4pt/8pt grid system.
class Spacing {
  Spacing._(); // Private constructor to prevent instantiation

  /// Extra small spacing: 4.0 logical pixels
  static const double xs = 4.0;

  /// Small spacing: 8.0 logical pixels
  static const double sm = 8.0;

  /// Medium spacing: 16.0 logical pixels (default for most cases)
  static const double md = 16.0;

  /// Large spacing: 24.0 logical pixels
  static const double lg = 24.0;

  /// Extra large spacing: 32.0 logical pixels
  static const double xl = 32.0;

  /// Double extra large spacing: 48.0 logical pixels
  static const double xxl = 48.0;
}

/// Standardized border radius values for consistent component styling.
///
/// Use these for cards, containers, buttons, and other rounded elements.
class AppBorderRadius {
  AppBorderRadius._(); // Private constructor to prevent instantiation

  /// Extra small border radius: 4.0 logical pixels
  static const double xs = 4.0;

  /// Small border radius: 8.0 logical pixels
  static const double small = 8.0;

  /// Medium border radius: 12.0 logical pixels
  static const double medium = 12.0;

  /// Large border radius: 16.0 logical pixels
  static const double large = 16.0;

  /// Extra large border radius: 20.0 logical pixels
  static const double xLarge = 20.0;
}

/// Component-specific dimension constants.
///
/// Standardized sizes for interactive elements and UI components.
class ComponentDimensions {
  ComponentDimensions._(); // Private constructor to prevent instantiation

  /// Minimum touch target size for accessibility: 44.0 logical pixels
  static const double minTouchTarget = 44.0;

  /// Small icon size: 16.0 logical pixels
  static const double iconSizeSmall = 16.0;

  /// Medium icon size: 20.0 logical pixels
  static const double iconSizeMedium = 20.0;

  /// Large icon size: 24.0 logical pixels
  static const double iconSizeLarge = 24.0;

  /// Extra large icon size: 32.0 logical pixels
  static const double iconSizeXLarge = 32.0;

  /// Header/feature icon size: 80.0 logical pixels
  static const double iconSizeHeader = 80.0;
}

/// Standardized animation and transition durations.
///
/// Use these for consistent timing across the app's animations.
class AnimationDurations {
  AnimationDurations._(); // Private constructor to prevent instantiation

  /// Short animation: 200 milliseconds
  static const Duration short = Duration(milliseconds: 200);

  /// Medium animation: 300 milliseconds
  static const Duration medium = Duration(milliseconds: 300);

  /// Long animation: 500 milliseconds
  static const Duration long = Duration(milliseconds: 500);

  /// Extra long animation: 1 second
  static const Duration xLong = Duration(seconds: 1);

  /// Snackbar/toast display duration: 2 seconds
  static const Duration snackbar = Duration(seconds: 2);
}

/// Common shadow configurations for elevated components.
///
/// Use these for consistent depth and elevation effects.
class ShadowConfig {
  ShadowConfig._(); // Private constructor to prevent instantiation

  /// Subtle shadow offset for slight elevation
  static const Offset subtleOffset = Offset(0, 2);

  /// Standard blur radius for subtle shadows
  static const double subtleBlur = 4.0;

  /// Medium shadow offset for standard elevation
  static const Offset mediumOffset = Offset(0, 4);

  /// Standard blur radius for medium shadows
  static const double mediumBlur = 12.0;
}

/// MIDI protocol standard ranges and default values.
///
/// These constants define the valid ranges for MIDI messages according
/// to the MIDI specification.
class MidiConstants {
  MidiConstants._(); // Private constructor to prevent instantiation

  // Channel ranges
  /// Minimum MIDI channel (0-based): 0
  /// References domain layer constant for consistency.
  static const int channelMin = MidiChannel.min;

  /// Maximum MIDI channel (0-based): 15
  /// References domain layer constant for consistency.
  static const int channelMax = MidiChannel.max;

  // Controller and value ranges
  /// Maximum value for MIDI controllers and data bytes: 127
  static const int controllerMax = 127;

  /// Maximum value for MIDI program numbers: 127
  static const int programMax = 127;

  // Pitch bend ranges
  /// Minimum pitch bend value (normalized): -1.0
  static const double pitchBendMin = -1.0;

  /// Maximum pitch bend value (normalized): 1.0
  static const double pitchBendMax = 1.0;

  /// Pitch bend slider divisions for UI controls: 100
  static const int pitchBendDivisions = 100;

  // Default values
  /// Standard default velocity for note messages: 64 (medium velocity)
  static const int defaultVelocity = 64;

  // Connection timeouts
  /// Bluetooth initialization timeout: 5 seconds
  static const Duration bluetoothInitTimeout = Duration(seconds: 5);

  /// Device scanning duration: 3 seconds
  static const Duration scanningDuration = Duration(seconds: 3);

  /// Delay before device connection: 500 milliseconds
  static const Duration connectionDelay = Duration(milliseconds: 500);
}

/// Standardized opacity values for consistent transparency across the app.
///
/// Use these constants with Color.withValues(alpha:) for Material3 compatibility.
/// Organized by semantic usage rather than numerical value.
class OpacityValues {
  OpacityValues._(); // Private constructor to prevent instantiation

  // ===== BACKGROUND OVERLAYS =====
  /// Very subtle background tint (barely visible)
  static const double backgroundSubtle = 0.05;

  /// Light background tint for containers
  static const double backgroundLight = 0.1;

  /// Moderate background tint
  static const double backgroundMedium = 0.2;

  /// Strong background tint
  static const double backgroundStrong = 0.3;

  // ===== BORDERS & OUTLINES =====
  /// Subtle border/outline
  static const double borderSubtle = 0.2;

  /// Standard border visibility
  static const double borderMedium = 0.3;

  /// Strong border/outline (info boxes, emphasis)
  static const double borderStrong = 0.5;

  // ===== SHADOWS & ELEVATION =====
  /// Very subtle shadow (minimal elevation)
  static const double shadowSubtle = 0.05;

  /// Standard shadow for cards/components
  static const double shadowMedium = 0.1;

  // ===== TEXT & CONTENT =====
  /// Muted text (secondary information)
  static const double textMuted = 0.7;

  /// Nearly opaque (highlighted/active states)
  static const double textHighlighted = 0.8;

  // ===== GRADIENTS =====
  /// Start of gradient (lighter)
  static const double gradientStart = 0.1;

  /// Middle of gradient
  static const double gradientMid = 0.2;

  /// End of gradient (darker)
  static const double gradientEnd = 0.3;
}

/// Responsive breakpoint values for adaptive layouts.
///
/// Use these for consistent responsive behavior across the app.
class ResponsiveBreakpoints {
  ResponsiveBreakpoints._(); // Private constructor to prevent instantiation

  /// Tablet width/height threshold: 768.0 logical pixels
  ///
  /// Devices with width or height >= this value are considered tablets.
  static const double tablet = 768.0;

  /// Compact height threshold: 600.0 logical pixels
  ///
  /// Layouts with height < this value should use compact spacing.
  static const double compactHeight = 600.0;
}
