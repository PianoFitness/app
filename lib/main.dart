import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:piano_fitness/shared/services/notification_service.dart";
import "package:piano_fitness/shared/theme/semantic_colors.dart";
import "package:piano_fitness/shared/widgets/main_navigation.dart";
import "package:timezone/data/latest.dart" as tz;

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

/// Creates a custom TextTheme matching the app's design system.
///
/// Based on the Piano Fitness design specification with consistent font sizing
/// across display, headline, body, and label text styles.
TextTheme _createTextTheme() {
  return const TextTheme(
    // Display styles - largest text
    displayLarge: TextStyle(fontSize: 32),
    displayMedium: TextStyle(fontSize: 28),
    displaySmall: TextStyle(fontSize: 24),

    // Headline styles - section headers
    headlineLarge: TextStyle(fontSize: 20),
    headlineMedium: TextStyle(fontSize: 18),
    headlineSmall: TextStyle(fontSize: 16),

    // Title styles - component titles
    titleLarge: TextStyle(fontSize: 20),
    titleMedium: TextStyle(fontSize: 16),
    titleSmall: TextStyle(fontSize: 14),

    // Body styles - main content
    bodyLarge: TextStyle(fontSize: 16),
    bodyMedium: TextStyle(fontSize: 14),
    bodySmall: TextStyle(fontSize: 12),

    // Label styles - buttons, chips, small text
    labelLarge: TextStyle(fontSize: 14),
    labelMedium: TextStyle(fontSize: 12),
    labelSmall: TextStyle(fontSize: 10),
  );
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
        textTheme: _createTextTheme(),
        extensions: const <ThemeExtension<dynamic>>[SemanticColors.light],
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: _createTextTheme(),
        extensions: const <ThemeExtension<dynamic>>[SemanticColors.dark],
      ),
      home: const MainNavigation(),
    );
  }
}
