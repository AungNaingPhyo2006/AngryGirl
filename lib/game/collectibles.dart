import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '/game/audio_manager.dart';
import '/models/player_data.dart';
import 'helper_bat.dart';
import 'ninja.dart';
import 'ninja_run.dart';

// Something on the path which Ninja picks up by touching it.
// It moves with the ground, and is pulled towards Ninja
// while the magnet power-up is active.
abstract class Collectible extends PositionComponent
    with CollisionCallbacks, HasGameReference<NinjaRun> {
  // Same speed as the ground of the parallax background.
  static const _speed = 54.0;
  static const _magnetRange = 100.0;
  static const _magnetSpeed = 220.0;

  Collectible({required super.position, required double radius})
    : super(size: Vector2.all(radius * 2), anchor: Anchor.center);

  // Called when Ninja picks this up.
  void onCollected();

  @override
  void onLoad() {
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    final ninja = game.ninja;
    final toNinja = ninja.absoluteCenter - absoluteCenter;

    if (game.playerData.hasMagnet &&
        ninja.isMounted &&
        toNinja.length < _magnetRange) {
      position += toNinja.normalized() * _magnetSpeed * dt;
    } else {
      x -= _speed * dt;
    }

    // Remove it once it leaves the screen.
    if (x < -size.x) {
      removeFromParent();
    }
    super.update(dt);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is Ninja) {
      onCollected();
      removeFromParent();
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}

// A diamond which gives 1 point and 1 diamond to spend in the shop.
// It twinkles by fading and growing a little, with a sparkle at its
// brightest.
class Diamond extends Collectible {
  static const _twinklePeriod = 0.9;

  late final Sprite _sprite;
  final Paint _paint = Paint();
  static final _sparklePaint = Paint()..color = Colors.white;

  // Started at a random point, so that diamonds don't twinkle together.
  double _time = Random().nextDouble() * _twinklePeriod;

  Diamond({required super.position}) : super(radius: 6);

  @override
  void onLoad() {
    super.onLoad();
    _sprite = Sprite(game.images.fromCache('diamond/diamond.png'));
  }

  @override
  void update(double dt) {
    _time += dt;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    // 0 at the dimmest, 1 at the brightest.
    final t = (sin(_time * 2 * pi / _twinklePeriod) + 1) / 2;

    _paint.color = Colors.white.withAlpha((255 * (0.45 + 0.55 * t)).round());
    final drawSize = size * (0.9 + 0.1 * t);
    _sprite.render(
      canvas,
      position: (size - drawSize) / 2,
      size: drawSize,
      overridePaint: _paint,
    );

    if (t > 0.8) {
      _drawSparkle(canvas, Offset(size.x * 0.8, size.y * 0.2), (t - 0.8) * 15);
    }
  }

  // A small four pointed star.
  void _drawSparkle(Canvas canvas, Offset center, double radius) {
    final thin = radius * 0.25;
    final star = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..lineTo(center.dx + thin, center.dy - thin)
      ..lineTo(center.dx + radius, center.dy)
      ..lineTo(center.dx + thin, center.dy + thin)
      ..lineTo(center.dx, center.dy + radius)
      ..lineTo(center.dx - thin, center.dy + thin)
      ..lineTo(center.dx - radius, center.dy)
      ..lineTo(center.dx - thin, center.dy - thin)
      ..close();
    canvas.drawPath(star, _sparklePaint);
  }

  @override
  void onCollected() {
    game.playerData.diamonds += 1;
    game.playerData.currentScore += 1;
  }
}

enum PowerUpType { magnet, shield }

// A power-up item, which gives a temporary special ability.
class PowerUpItem extends Collectible {
  final PowerUpType type;

  PowerUpItem(this.type, {required super.position}) : super(radius: 9);

  // Image of the power-up, relative to assets/images/. A picture is used
  // instead of an emoji, as emoji don't show on the web.
  static String image(PowerUpType type) => type == PowerUpType.magnet
      ? 'power_ups/magnet.png'
      : 'power_ups/shield.png';

  @override
  void onLoad() {
    super.onLoad();
    final color = type == PowerUpType.magnet
        ? Colors.redAccent
        : Colors.lightBlueAccent;
    add(
      CircleComponent(
        radius: size.x / 2,
        paint: Paint()..color = color.withAlpha(110),
      ),
    );
    add(
      SpriteComponent(
        sprite: Sprite(game.images.fromCache(image(type))),
        size: size * 0.75,
        anchor: Anchor.center,
        position: size / 2,
      ),
    );
  }

  @override
  void onCollected() {
    final playerData = game.playerData;
    switch (type) {
      case PowerUpType.magnet:
        playerData.magnetTime = playerData.magnetDuration;
      case PowerUpType.shield:
        playerData.shieldCharges = playerData.maxShieldCharges;
    }
    AudioManager.instance.playSfx('jump3.wav');
  }
}

// Spawns a diamond from time to time, and a random power-up
// every time the score reaches a multiple of [PlayerData.scorePerPowerUp].
class CollectibleManager extends Component with HasGameReference<NinjaRun> {
  final Random _random = Random();
  final Timer _diamondTimer = Timer(2, repeat: true);

  // Number of power-ups and helper bat items spawned so far,
  // based on the score.
  int _powerUps = 0;
  int _helperBats = 0;

  CollectibleManager() {
    _diamondTimer.onTick = _spawnDiamond;
  }

  @override
  void onMount() {
    _powerUps = game.playerData.currentScore ~/ PlayerData.scorePerPowerUp;
    _helperBats = game.playerData.currentScore ~/ PlayerData.scorePerHelperBat;
    super.onMount();
  }

  // Spawns a single diamond, either on the ground or in the air.
  void _spawnDiamond() {
    final ground = game.virtualSize.y - 32;
    final y = _random.nextBool() ? ground : ground - 40;
    game.world.add(Diamond(position: Vector2(game.virtualSize.x + 10, y)));
  }

  void _spawnPowerUp() {
    final type = PowerUpType.values[_random.nextInt(PowerUpType.values.length)];
    game.world.add(
      PowerUpItem(
        type,
        position: Vector2(game.virtualSize.x + 10, game.virtualSize.y - 40),
      ),
    );
  }

  @override
  void update(double dt) {
    _diamondTimer.update(dt);

    final reached = game.playerData.currentScore ~/ PlayerData.scorePerPowerUp;
    if (reached > _powerUps) {
      _powerUps = reached;
      _spawnPowerUp();
    }

    final bats = game.playerData.currentScore ~/ PlayerData.scorePerHelperBat;
    if (bats > _helperBats) {
      _helperBats = bats;
      // Behind the power-up which comes at the same score, in the air.
      game.world.add(
        HelperBatItem(
          position: Vector2(game.virtualSize.x + 60, game.virtualSize.y - 60),
        ),
      );
    }
    super.update(dt);
  }
}
