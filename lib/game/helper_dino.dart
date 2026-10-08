import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '/game/audio_manager.dart';
import '/game/enemy.dart';
import '/game/rocket.dart';
import '/game/score_popup.dart';
import '/models/shop.dart';
import 'ninja_run.dart';

enum _DinoState { run, kick, hurt }

// A dino which runs in front of Ninja and knocks out the enemies that
// can't be kicked. It dies after defeating [PlayerData.dinoLife] enemies.
class HelperDino extends SpriteAnimationGroupComponent<_DinoState>
    with CollisionCallbacks, HasGameReference<NinjaRun> {
  static const _image = 'DinoSprites - tard.png';
  static const _gravity = 800.0;
  static const _jumpSpeed = -260.0;
  static const _appearTime = 0.3;

  // How far ahead a flying enemy can be when the dino jumps at it.
  static const _jumpRange = 45.0;

  int _kills = 0;
  bool _dying = false;
  double _speedY = 0;
  double _groundY = 0;
  double _age = 0;

  final Timer _kickTimer = Timer(0.3, autoStart: false);
  final Timer _hurtTimer = Timer(1, autoStart: false);

  // Drawn at 16px from its 24px frames, a bit smaller than Ninja.
  HelperDino() : super(size: Vector2.all(16), anchor: Anchor.bottomLeft);

  @override
  void onLoad() {
    final image = game.images.fromCache(_image);
    SpriteAnimation frames(int start, int amount, {bool loop = true}) =>
        SpriteAnimation.fromFrameData(
          image,
          SpriteAnimationData.sequenced(
            amount: amount,
            stepTime: 0.1,
            textureSize: Vector2.all(24),
            texturePosition: Vector2(start * 24.0, 0),
            loop: loop,
          ),
        );

    animations = {
      _DinoState.run: frames(4, 6),
      _DinoState.kick: frames(10, 3, loop: false),
      _DinoState.hurt: frames(13, 4, loop: false),
    };
    current = _DinoState.run;

    // In the colour chosen in the shop.
    paint.colorFilter = game.playerData
        .cosmetic(CosmeticGroup.dinoColor)
        .hueFilter;

    // Appear just in front of Ninja, on the ground.
    final ninja = game.ninja;
    // On the ground line of the enemies. Ninja's frames have empty space
    // below its feet, so Ninja's own position is lower than its feet.
    _groundY = game.virtualSize.y - 24;
    position = Vector2(ninja.x + ninja.size.x + 12, _groundY);
    scale = Vector2.zero();

    add(RectangleHitbox.relative(Vector2(0.7, 0.8), parentSize: size));

    _kickTimer.onTick = () {
      if (!_dying) {
        current = _DinoState.run;
      }
    };
    _hurtTimer.onTick = removeFromParent;
  }

  @override
  void update(double dt) {
    // Grow in when it appears.
    _age += dt;
    scale = Vector2.all(min(_age / _appearTime, 1));

    _jumpAtFlyingEnemies();

    _speedY += _gravity * dt;
    y = min(y + _speedY * dt, _groundY);
    if (y >= _groundY) {
      _speedY = 0;
    }

    _kickTimer.update(dt);
    _hurtTimer.update(dt);
    super.update(dt);
  }

  // Jumps when an enemy it can defeat is flying just ahead of it.
  void _jumpAtFlyingEnemies() {
    if (_dying || y < _groundY) {
      return;
    }
    for (final enemy in game.world.children.whereType<Enemy>()) {
      final ahead = enemy.x - (x + size.x);
      final flying = enemy.enemyData.canFly && enemy.y < _groundY - 8;
      if (_canDefeat(enemy) && flying && ahead > 0 && ahead < _jumpRange) {
        _speedY = _jumpSpeed;
        return;
      }
    }
  }

  bool _canDefeat(Enemy enemy) => !enemy.attackable && !enemy.isTransformed;

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (!_dying && other is Enemy && _canDefeat(other)) {
      _defeat(other);
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _defeat(Enemy enemy) {
    game.world.add(Explosion(position: enemy.absoluteCenter));
    game.world.add(ScorePopup.above(enemy));
    game.playerData.currentScore += enemy.enemyData.points;
    enemy.removeFromParent();
    AudioManager.instance.playSfx('jump14.wav');

    _kills++;
    if (_kills >= game.playerData.dinoLife) {
      // Worn out after its last fight.
      _dying = true;
      current = _DinoState.hurt;
      _hurtTimer.start();
    } else {
      current = _DinoState.kick;
      _kickTimer.start();
    }
  }
}

// Brings a [HelperDino] every time the score reaches a multiple of
// [scorePerDino], while there isn't one already.
class HelperDinoSpawner extends Component with HasGameReference<NinjaRun> {
  static const scorePerDino = 50;

  // Number of score milestones passed so far.
  int _milestones = 0;

  @override
  void onMount() {
    _milestones = game.playerData.currentScore ~/ scorePerDino;
    super.onMount();
  }

  @override
  void update(double dt) {
    final reached = game.playerData.currentScore ~/ scorePerDino;
    if (reached > _milestones) {
      _milestones = reached;
      if (game.world.children.whereType<HelperDino>().isEmpty) {
        game.world.add(HelperDino());
      }
    }
    super.update(dt);
  }
}
