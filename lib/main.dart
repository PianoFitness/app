import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:piano_fitness/shared/widgets/main_navigation.dart";

/// Entry point for the Piano Fitness application.
///
/// Initializes the app with the root widget and starts the Flutter engine.
void main() {
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
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}
