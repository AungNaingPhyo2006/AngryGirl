import 'dart:math';

import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:hive/hive.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';

import 'bomb.dart';
import 'enemy.dart';
import 'ninja.dart';
import 'rocket.dart';
import 'tutorial.dart';
import 'fireball.dart';
import 'enemy_rocket.dart';
import 'collectibles.dart';
import 'helper_dino.dart';
import '/widgets/hud.dart';
import '/widgets/hud_guide.dart';
import '/models/settings.dart';
import '/models/shop.dart';
import '/game/audio_manager.dart';
import '/game/enemy_manager.dart';
import '/models/player_data.dart';
import '/widgets/pause_menu.dart';
import '/widgets/game_over_menu.dart';

// This is the main flame game class.
// FlameGame: Flame engine ရဲ့ base game class.
// TapCallbacks: screen tap detection.
// HasCollisionDetection: components တွေရဲ့ ယှဉ်ပြိုင်မှု (collision) တွေကို handle လုပ်ပေးတယ်။
class NinjaRun extends FlameGame with TapCallbacks, HasCollisionDetection {
  NinjaRun({super.camera});

  // List of all the image assets.
  // Game မှာအသုံးပြုမယ့် image (sprites/backgrounds) နဲ့ audio files (bgm/sfx) များ preload ပြင်ဆင်ထားတယ်။
  static final _imageAssets = [
    'run-player.png',
    ...Ninja.carriedImages,
    'bullet/Move.png',
    'bullet/Explosion.png',
    'diamond/diamond.png',
    'DinoSprites - tard.png',
    'power_ups/magnet.png',
    'power_ups/shield.png',
    'power_ups/missile.png',
    'fireball/fireball.png',
    'AngryPig/Walk (36x30).png',
    'Bat/Flying (46x30).png',
    'enemies/gino.png',
    'enemies/knight.png',
    'enemies/adventurer.png',
    'enemies/ChickRun (32x34).png',
    'parallax/plx-1.png',
    'parallax/plx-2.png',
    'parallax/plx-3.png',
    'parallax/plx-4.png',
    'parallax/plx-5.png',
    'parallax/plx-6.png',
    for (final enemy in EnemyManager.pixelAdventureEnemies) ...[
      'enemies/$enemy/run.png',
      'enemies/$enemy/hit.png',
    ],
    'enemies/skeleton/run.png',
    'enemies/skeleton/hit.png',
  ];

  // List of all the sound effect assets.
  static const _sfxAssets = [
    'hurt7.wav',
    'jump14.wav',
    'fire.wav',
    'jump3.wav',
  ];

  // List of all the audio assets.
  static const _audioAssets = ['8BitPlatformerLoop.wav', ..._sfxAssets];

  late Ninja _ninja; //  Main character.
  late Settings settings; // settings: အသံတွေအတွက် preferences.
  late PlayerData playerData; // playerData: player score, lives data.
  late EnemyManager _enemyManager; // _enemyManager: manager class.
  late CollectibleManager _collectibleManager;
  late HelperDinoSpawner _dinoSpawner;

  Ninja get ninja => _ninja;

  // Not null while the tutorial is being played.
  TutorialManager? _tutorial;
  TutorialManager? get tutorial => _tutorial;

  // Diamonds and high score from before the tutorial, given back
  // after it, so that the tutorial doesn't change them.
  (int, int)? _beforeTutorial;

  //Vector2 ဆိုတာ Flame game engine မှာအသုံးပြုတဲ့ 2D vector class ဖြစ်ပြီး,
  //(x, y) coordinate တန်ဖိုးတွေနဲ့ position, size, velocity, scale စတဲ့ 2D-related အရာတွေကို ဖော်ပြဖို့ အသုံးပြတယ်။
  //Vector2(800, 480); // width: 800, height: 480
  //ဒီမှာ virtualSize ဆိုတဲ့ getter method တစ်ခုဖန်တီးထားတယ်။
  //virtualSize ကို access လုပ်တဲ့အခါမှာ
  //camera.viewport.virtualSize ကို return ပေးတယ်။
  //camera: Flame game engine ထဲက camera object (game world ကိုဖော်ပြဖို့).
  //camera.viewport: Camera ရဲ့ viewport — screen ပေါ်မှာ ဘယ်အပိုင်းကိုပြမလဲ ဆိုတာကို ပြီးခိုင်းတယ်။
  //virtualSize: Viewport ရဲ့ virtual width & height — game world တွင် coordinate system ကိုဘယ်လိုသတ်မှတ်ထားသလဲ။
  //camera.viewport.virtualSize = Vector2(800, 480); ဆိုတာက screen မှာ 800px × 480px ကို Flame game ရဲ့ logical coordinate system အဖြစ် သတ်မှတ်လိုက်တယ်။
  //Vector2 get virtualSize => camera.viewport.virtualSize;
  //Flame game မှာ game logic ထဲကနေ virtualSize ကိုအသုံးပြချင်တဲ့အခါမှာ
  //camera.viewport.virtualSize ကို shortcut နဲ့ reference လုပ်နိုင်အောင် getter ထားတာပါ။
  //Game size, object alignment, background centering, collision zone စတဲ့အရာတွေအတွက် virtualSize ကိုသုံးတယ်။
  //final center = virtualSize / 2; ဆိုရင် game screen ရဲ့ center point ကို ရရှိနိုင်တယ်။

  Vector2 get virtualSize => camera.viewport.virtualSize;

  // This method get called while flame is preparing this game.
  // Game အစပေါ်လာတဲ့အချိန် run မယ့် setup method:
  @override
  Future<void> onLoad() async {
    // Makes the game full screen and landscape only.
    await Flame.device.fullScreen();
    await Flame.device.setLandscape();

    /// Read [PlayerData] and [Settings] from hive.
    playerData = await _readPlayerData();
    settings = await _readSettings();

    /// Initilize [AudioManager].
    await AudioManager.instance.init(
      _audioAssets,
      settings,
      sfxFiles: _sfxAssets,
    );

    // Start playing background music. Internally takes care
    // of checking user settings.
    startMusic();

    // Cache all the images.
    await images.loadAll(_imageAssets);

    // This makes the camera look at the center of the viewport.
    camera.viewfinder.position = camera.viewport.virtualSize * 0.5;

    await applyBackground();
  }

  ParallaxComponent? _background;

  // Speed of the farthest layer, and of the ground (the nearest layer).
  // The ground moves with the enemies and collectibles.
  static const _farLayerSpeed = 10.0;
  static const _groundSpeed = 53.8;

  /// Shows the background chosen in the shop as a [ParallaxComponent].
  Future<void> applyBackground() async {
    final layers = playerData.background.layers;

    // Each layer is faster than the one behind it, so that
    // the ground has the same speed in every background.
    final step = pow(_groundSpeed / _farLayerSpeed, 1 / (layers.length - 1));
    final background = await loadParallaxComponent(
      [for (final layer in layers) ParallaxImageData(layer)],
      baseVelocity: Vector2(_farLayerSpeed, 0),
      velocityMultiplierDelta: Vector2(step.toDouble(), 0),
    );

    _background?.removeFromParent();
    _background = background;
    camera.backdrop.add(background);
  }

  /// This method add the already created [Ninja]
  /// and [EnemyManager] to this game.
  // Game play စတင်တဲ့အချိန်မှာ Ninja character နဲ့ EnemyManager ကို add လုပ်တယ်။
  void startGamePlay() {
    // Start with full lives (which depend on the shop upgrade),
    // and with a shield if it was bought in the shop.
    playerData.lives = playerData.maxLives.toDouble();
    playerData.revives = 0;
    if (playerData.startsWithShield) {
      playerData.shieldCharges = playerData.maxShieldCharges;
    }

    // One-game items bought in the shop are used up here.
    if (playerData.useConsumable(Consumable.startRockets)) {
      playerData.rockets = ConsumableItem.startRocketCount;
    }
    if (playerData.useConsumable(Consumable.doubleScore)) {
      playerData.doubleScoreTime = ConsumableItem.doubleScoreSeconds;
    }
    if (playerData.useConsumable(Consumable.startBursts)) {
      playerData.bursts = ConsumableItem.startBurstCount;
    }

    _ninja = Ninja(images.fromCache('run-player.png'), playerData);
    _enemyManager = EnemyManager();
    _collectibleManager = CollectibleManager();
    _dinoSpawner = HelperDinoSpawner();

    world.add(_ninja);
    world.add(_enemyManager);
    world.add(_collectibleManager);
    world.add(_dinoSpawner);
    _showHudGuideIfNew();
  }

  /// Starts the tutorial, in which the enemies and items come one
  /// at a time from a [TutorialManager] instead of randomly.
  void startTutorial() {
    _beforeTutorial = (playerData.diamonds, playerData.highScore);
    playerData.lives = playerData.maxLives.toDouble();
    playerData.revives = 0;

    _ninja = Ninja(images.fromCache('run-player.png'), playerData);
    _enemyManager = EnemyManager(autoSpawn: false);
    _tutorial = TutorialManager(_enemyManager);

    world.add(_ninja);
    world.add(_enemyManager);
    world.add(_tutorial!);
    _showHudGuideIfNew();
  }

  /// Starts the same kind of game again, the tutorial or a real game.
  void restart() {
    final wasTutorial = _tutorial != null;
    reset();
    wasTutorial ? startTutorial() : startGamePlay();
  }

  // Explains the hud in the first game of a new player, while the
  // game waits. Players who have already scored don't need it.
  // It is added after the hud, so that it is drawn above it.
  void _showHudGuideIfNew() {
    if (!settings.hudGuideSeen && playerData.highScore == 0) {
      overlays.add(HudGuide.id);
      pauseEngine();
    }
  }

  // This method remove all the actors from the game.
  // Game reset လုပ်ချင်တဲ့အချိန် Component တွေကို game world မှထုတ်ပယ်တယ်။
  // Everything in the world belongs to the game being played, and the
  // tutorial has no collectible manager or dino spawner to ask.
  void _disconnectActors() {
    world.removeAll(world.children.toList());
  }

  // This method reset the whole game world to initial state.
  // Game reset = player lives & score ကို default ပြန်ထားတယ်။
  void reset() {
    // First disconnect all actions from game world.
    _disconnectActors();

    // Reset player data to inital values.
    playerData.currentScore = 0;
    playerData.lives = playerData.maxLives.toDouble();
    playerData.rockets = 0;
    playerData.bursts = 0;
    playerData.shieldCharges = 0;
    playerData.magnetTime = 0;
    playerData.doubleScoreTime = 0;
    playerData.carryTime = 0;

    // Take back what was earned in the tutorial.
    if (_beforeTutorial case (final diamonds, final highScore)) {
      playerData.highScore = highScore;
      playerData.diamonds = diamonds;
      _beforeTutorial = null;
    }
    _tutorial = null;
  }

  /// Starts the background music chosen in the shop.
  void startMusic() {
    AudioManager.instance.startBgm(
      playerData.cosmetic(CosmeticGroup.music).music!,
    );
  }

  /// Continues the game after the player ran out of lives, if the
  /// player can pay [PlayerData.reviveCost] diamonds.
  void revive() {
    if (!playerData.revive()) {
      return;
    }

    // Clear the enemies and everything thrown at Ninja,
    // so that Ninja doesn't lose the life right away.
    _enemyManager.removeAllEnemies();
    for (final projectile in world.children.where(
      (c) => c is Fireball || c is EnemyRocket,
    )) {
      projectile.removeFromParent();
    }
    _ninja.recover();

    overlays.remove(GameOverMenu.id);
    overlays.add(Hud.id);
    resumeEngine();
    AudioManager.instance.resumeBgm();
  }

  // Fires a rocket from in front of the ninja, if the player has any.
  void fireRocket() {
    if (playerData.rockets <= 0) {
      return;
    }
    playerData.rockets -= 1;
    world.add(
      Rocket(
        position: _ninja.position + Vector2(_ninja.size.x, -_ninja.size.y / 2),
      ),
    );
    AudioManager.instance.playSfx('fire.wav');
  }

  // Uses a burst to drop a bomb on each of the nearest enemies in front
  // of Ninja. The burst is kept if there is no enemy to drop it on.
  void dropBombs() {
    if (playerData.bursts <= 0) {
      return;
    }
    final targets =
        world.children
            .whereType<Enemy>()
            .where(
              (enemy) =>
                  !enemy.isTransformed &&
                  enemy.absoluteCenter.x > _ninja.absoluteCenter.x &&
                  enemy.absoluteCenter.x < virtualSize.x,
            )
            .toList()
          ..sort((a, b) => a.absoluteCenter.x.compareTo(b.absoluteCenter.x));
    if (targets.isEmpty) {
      return;
    }
    playerData.bursts -= 1;
    world.addAll([
      for (final enemy in targets.take(Bomb.maxTargets)) Bomb(enemy),
    ]);
    AudioManager.instance.playSfx('fire.wav');
  }

  //This method gets called for each tick/frame of the game.
  //Frame တစ်ခုစီ update ဖြစ်တိုင်း player lives စစ်တယ်။
  //Lives = 0 ဆိုရင် Game Over overlay ဖော်ပြတယ်။
  @override
  void update(double dt) {
    // If number of lives is 0 or less, game is over.
    if (playerData.lives <= 0) {
      overlays.add(GameOverMenu.id);
      overlays.remove(Hud.id);
      pauseEngine();
      AudioManager.instance.pauseBgm();
    }
    super.update(dt);
  }

  // This will get called for each tap on the screen.
  @override
  void onTapDown(TapDownEvent event) {
    // Make ninja jump only when game is playing.
    // When game is in playing state, only Hud will be the active overlay.
    //Game playing ဖြစ်နေချိန်မှာသာ tap လုပ်လျှင် ninja ကခုန်တယ်။
    if (overlays.isActive(Hud.id)) {
      _ninja.jump();
    }
    super.onTapDown(event);
  }

  /// This method reads [PlayerData] from the hive box.
  Future<PlayerData> _readPlayerData() async {
    final playerDataBox = await Hive.openBox<PlayerData>(
      'NinjaRun.PlayerDataBox',
    );
    final playerData = playerDataBox.get('NinjaRun.PlayerData');

    // If data is null, this is probably a fresh launch of the game.
    //Hive မှာအရင်ရှိတာကိုဖတ်တယ်၊ မရှိရင် default PlayerData() ထည့်ထားတယ်။
    if (playerData == null) {
      // In such cases store default values in hive.
      await playerDataBox.put('NinjaRun.PlayerData', PlayerData());
    }

    // Now it is safe to return the stored value.
    return playerDataBox.get('NinjaRun.PlayerData')!;
  }

  /// This method reads [Settings] from the hive box.
  Future<Settings> _readSettings() async {
    final settingsBox = await Hive.openBox<Settings>('NinjaRun.SettingsBox');
    final settings = settingsBox.get('NinjaRun.Settings');

    // If data is null, this is probably a fresh launch of the game.
    if (settings == null) {
      // In such cases store default values in hive.
      await settingsBox.put(
        'NinjaRun.Settings',
        Settings(bgm: true, sfx: true),
      );
    }

    // Now it is safe to return the stored value.
    return settingsBox.get('NinjaRun.Settings')!;
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // On resume, if active overlay is not PauseMenu,
        // resume the engine (lets the parallax effect play).
        if (!(overlays.isActive(PauseMenu.id)) &&
            !(overlays.isActive(GameOverMenu.id)) &&
            !(overlays.isActive(HudGuide.id))) {
          resumeEngine();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // If game is active, then remove Hud and add PauseMenu
        // before pausing the game.
        // The hud guide keeps the game waiting by itself.
        if (overlays.isActive(Hud.id) && !overlays.isActive(HudGuide.id)) {
          overlays.remove(Hud.id);
          overlays.add(PauseMenu.id);
        }
        pauseEngine();
        break;
    }
    super.lifecycleStateChange(state);
  }
}

// | Feature       | Description                          |
// | ------------- | ------------------------------------ |
// | 🎮 `NinjaRun`  | Flame game main class                |
// | 🕹 Tap & Jump | Tap screen to jump                   |
// | 🎵 BGM/SFX    | Audio manager handles sound          |
// | 🧠 Data       | Hive မှတ်သားထားတဲ့ player & settings |
// | 🏃 Enemies    | Spawned dynamically via EnemyManager |
// | ⛅ Parallax    | Layered moving background            |
// | 🧩 Overlay    | `Hud`, `PauseMenu`, `GameOverMenu`   |
// | 🎓 Tutorial   | `startTutorial`, `HudGuide`          |
// | 🔁 Lifecycle  | Auto pause/resume app state          |
