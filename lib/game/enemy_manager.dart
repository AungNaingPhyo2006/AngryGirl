import 'dart:math';

import 'package:flame/components.dart';
import '/game/enemy.dart';
import 'ninja_run.dart';
import '/models/enemy_data.dart';

// This class is responsible for spawning random enemies at certain
// interval of time depending upon players current score.
class EnemyManager extends Component with HasGameReference<NinjaRun> {
  // A list to hold data for all the enemies.
  final List<EnemyData> _data = [];

  // Pixel Adventure characters in images/enemies/<id>/.
  static const pixelAdventureEnemies = [
    'ninja_frog',
    'mask_dude',
    'pink_man',
    'virtual_guy',
  ];

  // Enemies which join the random ones once the score is over
  // [scoreForExtraEnemies]: the Pixel Adventure characters and a skeleton.
  static const scoreForExtraEnemies = 500;
  final List<EnemyData> _extraData = [];

  // Enemies which attack from a distance. Each comes every time the score
  // reaches a multiple of its score: a pig which breathes a fireball,
  // a chicken which fires a rocket, and a bat which fires a rocket.
  static const scorePerFirePig = 100;
  static const scorePerRocketChick = 200;
  static const scorePerRocketBat = 300;
  late final EnemyData _firePigData;
  late final EnemyData _rocketChickData;
  late final EnemyData _rocketBatData;

  // When milestones meet (such as at 600), they come one after the other
  // with these delays, so that they don't arrive together.
  late final List<_MilestoneEnemy> _milestoneEnemies = [
    _MilestoneEnemy(scorePerFirePig, 0, () => _spawn(_firePigData)),
    _MilestoneEnemy(scorePerRocketChick, 1.5, () => _spawn(_rocketChickData)),
    _MilestoneEnemy(scorePerRocketBat, 3, () => _spawn(_rocketBatData)),
  ];

  // Random generator required for randomly selecting enemy type.
  final Random _random = Random();

  // Timer to decide when to spawn next enemy.
  final Timer _timer = Timer(2, repeat: true);

  // False in the tutorial, which spawns its enemies with [spawnById].
  final bool autoSpawn;

  EnemyManager({this.autoSpawn = true}) {
    _timer.onTick = spawnRandomEnemy;
  }

  // This method is responsible for spawning a random enemy.
  void spawnRandomEnemy() {
    final enemies = game.playerData.currentScore > scoreForExtraEnemies
        ? [..._data, ..._extraData]
        : _data;

    /// Generate a random index within [enemies] and get an [EnemyData].
    _spawn(enemies[_random.nextInt(enemies.length)]);
  }

  // Spawns one of the basic enemies, which can't throw anything.
  Enemy spawnById(String id) => _spawn(_data.firstWhere((d) => d.id == id));

  Enemy _spawn(EnemyData enemyData) {
    final enemy = Enemy(enemyData);

    // Help in setting all enemies on ground.
    enemy.anchor = Anchor.bottomLeft;
    enemy.position = Vector2(game.virtualSize.x + 72, game.virtualSize.y - 24);

    // If this enemy can fly, set its y position randomly.
    if (enemyData.canFly) {
      final newHeight = _random.nextDouble() * 2 * enemyData.textureSize.y;
      enemy.position.y -= newHeight;
    }

    // Due to the size of our viewport, we can
    // use textureSize as size for the components.
    enemy.size = enemyData.textureSize;
    game.world.add(enemy);
    return enemy;
  }

  @override
  void onMount() {
    if (isMounted) {
      removeFromParent();
    }

    // Don't fill list again and again on every mount.
    if (_data.isEmpty) {
      // As soon as this component is mounted, initilize all the data.
      _data.addAll([
        EnemyData(
          id: 'angry_pig',
          image: game.images.fromCache('AngryPig/Walk (36x30).png'),
          nFrames: 16,
          stepTime: 0.1,
          textureSize: Vector2(36, 30),
          speedX: 80,
          canFly: false,
          attackable: false,
        ),
        EnemyData(
          id: 'bat',
          image: game.images.fromCache('Bat/Flying (46x30).png'),
          nFrames: 7,
          stepTime: 0.1,
          textureSize: Vector2(46, 30),
          speedX: 100,
          canFly: true,
          attackable: false,
        ),
        EnemyData(
          id: 'gino',
          image: game.images.fromCache('enemies/gino.png'),
          nFrames: 8,
          stepTime: 0.09,
          textureSize: Vector2(64, 64),
          speedX: 150,
          canFly: false,
          attackable: true,
          facesRight: true,
          deathFrameStart: 8,
          deathFrames: 5,
        ),
        EnemyData(
          id: 'chick',
          image: game.images.fromCache('enemies/ChickRun (32x34).png'),
          nFrames: 14,
          stepTime: 0.09,
          textureSize: Vector2(32, 34),
          speedX: 150,
          canFly: false,
          attackable: false,
        ),
        EnemyData(
          id: 'knight',
          image: game.images.fromCache('enemies/knight.png'),
          nFrames: 10,
          stepTime: 0.09,
          textureSize: Vector2(100, 55),
          speedX: 150,
          canFly: false,
          attackable: true,
          facesRight: true,
          deathFrameStart: 11,
          deathFrames: 9,
        ),
        EnemyData(
          id: 'adventurer',
          image: game.images.fromCache('enemies/adventurer.png'),
          nFrames: 6,
          stepTime: 0.09,
          textureSize: Vector2(50, 37),
          speedX: 150,
          canFly: false,
          attackable: false,
          facesRight: true,
          deathFrameStart: 6,
          deathFrames: 7,
          points: 10,
        ),
      ]);
      _rocketChickData = EnemyData(
        id: 'chick',
        image: game.images.fromCache('enemies/ChickRun (32x34).png'),
        nFrames: 14,
        stepTime: 0.09,
        textureSize: Vector2(32, 34),
        speedX: 150,
        canFly: false,
        attackable: false,
        throwsRocket: true,
      );
      _rocketBatData = EnemyData(
        id: 'bat',
        image: game.images.fromCache('Bat/Flying (46x30).png'),
        nFrames: 7,
        stepTime: 0.1,
        textureSize: Vector2(46, 30),
        speedX: 100,
        canFly: true,
        attackable: false,
        throwsRocket: true,
      );
      _firePigData = EnemyData(
        id: 'angry_pig',
        image: game.images.fromCache('AngryPig/Walk (36x30).png'),
        nFrames: 16,
        stepTime: 0.1,
        textureSize: Vector2(36, 30),
        speedX: 80,
        canFly: false,
        attackable: false,
        shootsFire: true,
      );
      _extraData.addAll([
        for (final id in pixelAdventureEnemies)
          EnemyData(
            id: id,
            image: game.images.fromCache('enemies/$id/run.png'),
            nFrames: 12,
            stepTime: 0.05,
            textureSize: Vector2.all(32),
            speedX: 120,
            canFly: false,
            attackable: false,
            facesRight: true,
            deathImage: game.images.fromCache('enemies/$id/hit.png'),
            deathFrames: 7,
            rocketPoints: 15,
          ),
        EnemyData(
          id: 'skeleton',
          image: game.images.fromCache('enemies/skeleton/run.png'),
          nFrames: 13,
          stepTime: 0.08,
          textureSize: Vector2(22, 33),
          speedX: 90,
          canFly: false,
          attackable: false,
          facesRight: true,
          deathImage: game.images.fromCache('enemies/skeleton/hit.png'),
          deathTextureSize: Vector2(33, 32),
          deathFrames: 15,
        ),
      ]);
    }
    for (final milestone in _milestoneEnemies) {
      milestone.start(game.playerData.currentScore);
    }
    if (autoSpawn) {
      _timer.start();
    }
    super.onMount();
  }

  @override
  void update(double dt) {
    if (autoSpawn) {
      _timer.update(dt);
      for (final milestone in _milestoneEnemies) {
        milestone.update(dt, game.playerData.currentScore);
      }
    }
    super.update(dt);
  }

  void removeAllEnemies() {
    final enemies = game.world.children.whereType<Enemy>();
    for (var enemy in enemies) {
      enemy.removeFromParent();
    }
  }
}

// Spawns an enemy every time the score reaches a multiple of [scorePer],
// [delay] seconds after the score gets there.
class _MilestoneEnemy {
  final int scorePer;
  final Timer _delay;

  // Number of multiples of [scorePer] reached so far.
  int _reached = 0;

  _MilestoneEnemy(this.scorePer, double delay, void Function() spawn)
    : _delay = Timer(delay, onTick: spawn, autoStart: false);

  // Only multiples reached after [score] bring an enemy.
  void start(int score) {
    _reached = score ~/ scorePer;
    _delay.stop();
  }

  void update(double dt, int score) {
    if (score ~/ scorePer > _reached) {
      _reached = score ~/ scorePer;
      _delay.start();
    }
    _delay.update(dt);
  }
}
