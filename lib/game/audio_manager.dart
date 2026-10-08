import '/models/settings.dart';
import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';

/// This class is the common interface between [Ninja]
/// and [Flame] engine's audio APIs.
class AudioManager {
  late Settings settings;

  // One reusable pool per sound effect, so that playing an sfx
  // does not create (and leak) a new AudioPlayer every time.
  final Map<String, AudioPool> _sfxPools = {};

  AudioManager._internal();

  /// [_instance] represents the single static instance of [AudioManager].
  static final AudioManager _instance = AudioManager._internal();

  /// A getter to access the single instance of [AudioManager].
  static AudioManager get instance => _instance;

  /// This method is responsible for initializing caching given list of [files],
  /// and initilizing settings. An [AudioPool] is created for each of the
  /// [sfxFiles], which must be played using [playSfx].
  Future<void> init(
    List<String> files,
    Settings settings, {
    List<String> sfxFiles = const [],
  }) async {
    this.settings = settings;
    FlameAudio.bgm.initialize();
    await FlameAudio.audioCache.loadAll(files);
    for (final file in sfxFiles) {
      _sfxPools[file] ??= await FlameAudio.createPool(file, maxPlayers: 3);
    }
  }

  // Starts the given audio file as BGM on loop.
  void startBgm(String fileName) {
    if (settings.bgm) {
      FlameAudio.bgm.play(fileName, volume: 0.4);
    }
  }

  // Pauses currently playing BGM if any.
  void pauseBgm() {
    if (settings.bgm) {
      FlameAudio.bgm.pause();
    }
  }

  // Resumes currently paused BGM if any.
  void resumeBgm() {
    if (settings.bgm) {
      FlameAudio.bgm.resume();
    }
  }

  // Stops currently playing BGM if any.
  void stopBgm() {
    FlameAudio.bgm.stop();
  }

  // Plays the given audio file once, reusing a pooled player.
  void playSfx(String fileName) {
    if (settings.sfx) {
      _sfxPools[fileName]?.start();
    }
  }
}
