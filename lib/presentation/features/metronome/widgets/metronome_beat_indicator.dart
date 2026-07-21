import "dart:async";

import "package:flutter/material.dart";
import "package:piano_fitness/domain/models/metronome/beat_emphasis.dart";
import "package:piano_fitness/domain/models/metronome/beat_info.dart";
import "package:piano_fitness/presentation/constants/ui_constants.dart";

/// Pulsing visual reference for the current metronome beat.
///
/// Accented beats pulse larger, so the downbeat reads clearly even with
/// sound muted. Purely presentational - driven by the [beat] most recently
/// reported by MetronomePageViewModel.
class MetronomeBeatIndicator extends StatefulWidget {
  /// Creates a beat indicator reflecting [beat], or an idle dot if null.
  const MetronomeBeatIndicator({required this.beat, super.key});

  /// The most recently fired beat, or null before the metronome starts.
  final BeatInfo? beat;

  @override
  State<MetronomeBeatIndicator> createState() => _MetronomeBeatIndicatorState();
}

class _MetronomeBeatIndicatorState extends State<MetronomeBeatIndicator>
    with SingleTickerProviderStateMixin {
  // Constructed eagerly in initState(), not via a lazy `late final`
  // initializer: if didUpdateWidget() never touches it (beat stays null for
  // the widget's whole lifetime), a lazy initializer would fire on its
  // first access - which would be inside dispose() - constructing a new
  // AnimationController (and Ticker) on an already-unmounting element.
  late final AnimationController _pulseController;
  Animation<double> _scaleAnimation = const AlwaysStoppedAnimation(1);

  static const double _diameter = 96;
  static const Map<BeatEmphasis, double> _peakScaleByEmphasis = {
    BeatEmphasis.strong: 1.3,
    BeatEmphasis.medium: 1.18,
    BeatEmphasis.weak: 1.08,
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: AnimationDurations.short,
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(covariant MetronomeBeatIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    final beat = widget.beat;
    if (beat != null && !_isSameBeat(beat, oldWidget.beat)) {
      _scaleAnimation =
          Tween<double>(
            begin: 1,
            end: _peakScaleByEmphasis[beat.emphasis],
          ).animate(
            CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
          );
      _pulseController.reset();
      unawaited(
        _pulseController.forward().then((_) {
          if (mounted) _pulseController.reverse();
        }),
      );
    }
  }

  bool _isSameBeat(BeatInfo a, BeatInfo? b) =>
      b != null &&
      a.beatNumber == b.beatNumber &&
      a.measureNumber == b.measureNumber;

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final beat = widget.beat;
    final isDownbeat = beat?.isDownbeat ?? false;

    return Semantics(
      liveRegion: true,
      label: beat == null
          ? "Metronome stopped"
          : "Beat ${beat.beatNumber} of measure ${beat.measureNumber}"
                "${isDownbeat ? ", downbeat" : ""}",
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          key: const Key("metronome_beat_indicator"),
          width: _diameter,
          height: _diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDownbeat
                ? colorScheme.primary
                : colorScheme.primaryContainer,
          ),
          alignment: Alignment.center,
          child: Text(
            beat?.beatNumber.toString() ?? "•",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: isDownbeat
                  ? colorScheme.onPrimary
                  : colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
