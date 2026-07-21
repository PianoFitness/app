import "dart:async";

import "package:audioplayers/audioplayers.dart";
import "package:piano_fitness/domain/repositories/metronome_audio_service.dart";

/// Implementation of [IMetronomeAudioService] using audioplayers' [AudioPool]
/// with [PlayerMode.lowLatency] - see
/// docs/specifications/metronome-component.md#sound-playback for why this
/// combination was chosen over the default single-player API.
class MetronomeAudioServiceImpl implements IMetronomeAudioService {
  MetronomeAudioServiceImpl({
    this.assetPath = "audio/218851__kellyconidi__highbell.mp3",
    this.minPlayers = 2,
    this.maxPlayers = 4,
  });

  /// Path relative to the `assets/` root, matching [AssetSource].
  final String assetPath;

  /// Pre-warmed player instances kept ready at all times.
  final int minPlayers;

  /// Cap on reusable instances kept in the pool; extra concurrent clicks
  /// beyond this still play, they're just not recycled.
  final int maxPlayers;

  /// Fallback release delay if the clip's actual duration can't be read;
  /// long enough for a short click, short enough to free the pool slot
  /// quickly even at fast tempos.
  static const _fallbackReleaseDelay = Duration(milliseconds: 800);

  AudioPool? _pool;
  Future<AudioPool>? _poolFuture;
  Duration _releaseDelay = _fallbackReleaseDelay;
  bool _disposed = false;

  @override
  Future<void> initialize() async {
    if (_pool != null || _disposed) return;
    _poolFuture ??= AudioPool.createFromAsset(
      path: assetPath,
      minPlayers: minPlayers,
      maxPlayers: maxPlayers,
      playerMode: PlayerMode.lowLatency,
    );
    final pool = await _poolFuture!;
    final duration = await pool.getDuration();
    if (_disposed) {
      // dispose() ran while this pool was being created, so it never saw
      // this instance to dispose - do it now instead of leaking it or
      // resurrecting it into _pool after the service was torn down.
      await pool.dispose();
      return;
    }
    if (duration != null) {
      _releaseDelay = duration;
    }
    _pool = pool;
  }

  @override
  Future<void> playClick({required double volume}) async {
    var pool = _pool;
    if (pool == null) {
      // Not pre-warmed; callers should invoke initialize() first (see
      // interface doc) so only a missed warm-up pays this latency cost.
      await initialize();
      pool = _pool;
      // Still null after initialize() means dispose() won the race; skip
      // the click rather than force-unwrapping a pool that doesn't exist.
      if (pool == null) return;
    }
    final stop = await pool.start(volume: volume);
    // PlayerMode.lowLatency players aren't auto-released on completion
    // (see AudioPool docs), so release explicitly - otherwise the pool
    // grows unbounded over a long practice session instead of recycling.
    unawaited(Future<void>.delayed(_releaseDelay, stop));
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    final pool = _pool;
    _pool = null;
    _poolFuture = null;
    await pool?.dispose();
  }
}
