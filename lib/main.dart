import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:piano_fitness/shared/services/notification_service.dart";
import "package:piano_fitness/shared/widgets/main_navigation.dart";
import "package:timezone/data/latest.dart" as tz;

/// Custom theme extension for semantic colors that provide consistent
/// color meanings throughout the application.
@immutable
class SemanticColors extends ThemeExtension<SemanticColors> {
  /// Creates semantic colors with all required parameters.
  const SemanticColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.onInfoContainer,
    required this.disabled,
    required this.onDisabled,
  });

  /// Success color (typically green) for positive actions and states.
  final Color success;

  /// Text/icon color that works on [success] background.
  final Color onSuccess;

  /// Light success color for containers and backgrounds.
  final Color successContainer;

  /// Text/icon color that works on [successContainer] background.
  final Color onSuccessContainer;

  /// Warning color (typically orange/amber) for caution states.
  final Color warning;

  /// Text/icon color that works on [warning] background.
  final Color onWarning;

  /// Light warning color for containers and backgrounds.
  final Color warningContainer;

  /// Text/icon color that works on [warningContainer] background.
  final Color onWarningContainer;

  /// Info color (typically blue) for informational states.
  final Color info;

  /// Text/icon color that works on [info] background.
  final Color onInfo;

  /// Light info color for containers and backgrounds.
  final Color infoContainer;

  /// Text/icon color that works on [infoContainer] background.
  final Color onInfoContainer;

  /// Disabled color for inactive states.
  final Color disabled;

  /// Text/icon color that works on [disabled] background.
  final Color onDisabled;

  /// Light theme semantic colors.
  static const light = SemanticColors(
    success: Color(0xFF4CAF50),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFE8F5E8),
    onSuccessContainer: Color(0xFF2E7D32),
    warning: Color(0xFFFF9800),
    onWarning: Color(0xFFFFFFFF),
    warningContainer: Color(0xFFFFF3E0),
    onWarningContainer: Color(0xFFE65100),
    info: Color(0xFF2196F3),
    onInfo: Color(0xFFFFFFFF),
    infoContainer: Color(0xFFE3F2FD),
    onInfoContainer: Color(0xFF1565C0),
    disabled: Color(0xFF9E9E9E),
    onDisabled: Color(0xFFFFFFFF),
  );

  /// Dark theme semantic colors.
  static const dark = SemanticColors(
    success: Color(0xFF66BB6A),
    onSuccess: Color(0xFF000000),
    successContainer: Color(0xFF2E7D32),
    onSuccessContainer: Color(0xFFC8E6C9),
    warning: Color(0xFFFFB74D),
    onWarning: Color(0xFF000000),
    warningContainer: Color(0xFFE65100),
    onWarningContainer: Color(0xFFFFE0B2),
    info: Color(0xFF64B5F6),
    onInfo: Color(0xFF000000),
    infoContainer: Color(0xFF1565C0),
    onInfoContainer: Color(0xFFBBDEFB),
    disabled: Color(0xFF757575),
    onDisabled: Color(0xFFE0E0E0),
  );

  @override
  SemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? onInfoContainer,
    Color? disabled,
    Color? onDisabled,
  }) {
    return SemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
      disabled: disabled ?? this.disabled,
      onDisabled: onDisabled ?? this.onDisabled,
    );
  }

  @override
  SemanticColors lerp(ThemeExtension<SemanticColors>? other, double t) {
    if (other is! SemanticColors) {
      return this;
    }
    return SemanticColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      onSuccessContainer: Color.lerp(
        onSuccessContainer,
        other.onSuccessContainer,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      onWarningContainer: Color.lerp(
        onWarningContainer,
        other.onWarningContainer,
        t,
      )!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      onDisabled: Color.lerp(onDisabled, other.onDisabled, t)!,
    );
  }
}

/// Extension to easily access semantic colors from any BuildContext.
extension SemanticColorsExtension on BuildContext {
  /// Access semantic colors from the current theme.
  SemanticColors get semanticColors =>
      Theme.of(this).extension<SemanticColors>() ?? SemanticColors.light;
}

/// Entry point for the Piano Fitness application.
///
/// Initializes the app with the root widget and starts the Flutter engine.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone data for notifications
  tz.initializeTimeZones();

  // Initialize notification service
  try {
    debugPrint("About to initialize NotificationService...");
    await NotificationService.initialize();
    debugPrint("NotificationService initialized successfully");
  } catch (e, stackTrace) {
    debugPrint("Failed to initialize notification service: $e");
    debugPrint("Stack trace: $stackTrace");
  }

  // Configure logging levels
  if (kDebugMode) {
    // In debug mode, show fine (and above) for detailed diagnostics
    Logger.root.level = Level.FINE;
  } else {
    // In production, only show warnings and errors
    Logger.root.level = Level.WARNING;
  }

  // Set up logging output handler
  Logger.root.onRecord.listen((record) {
    // Only print logs in debug mode to avoid noise in production
    if (!kDebugMode) return;
    final errorSuffix = record.error != null ? " error: ${record.error}" : "";
    final stackSuffix = record.stackTrace != null
        ? "\n${record.stackTrace}"
        : "";
    debugPrint(
      "${record.level.name}: ${record.time}: "
      "${record.loggerName}: ${record.message}$errorSuffix$stackSuffix",
    );
  });

  runApp(const MyApp());
}

/// The root widget of the Piano Fitness application.
///
/// Sets up the app theme and defines the initial navigation structure.
/// Each page now manages its own local MIDI state for better isolation.
class MyApp extends StatelessWidget {
  /// Creates the root widget of the Piano Fitness app.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Piano Fitness",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        extensions: const <ThemeExtension<dynamic>>[SemanticColors.light],
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        extensions: const <ThemeExtension<dynamic>>[SemanticColors.dark],
      ),
      home: const MainNavigation(),
    );
  }
}
