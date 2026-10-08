import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'ninja.dart';
import 'ninja_run.dart';

// A fireball breathed by a fire pig. It flies to the left, and costs
// Ninja half a life if it hits.
class Fireball extends SpriteComponent
    with CollisionCallbacks, HasGameReference<NinjaRun> {
  static const double speed = 160;

  // Flickers by growing and shrinking a little, this many times a second.
  static const _flickersPerSecond = 8.0;

  double _time = 0;

  Fireball({required super.position})
    : super(
        size: Vector2.all(16),
        anchor: Anchor.center,
        // The flame image points up. Turned so that its tips
        // point to the left, the way it flies.
        angle: -pi / 2,
      );

  @override
  void onLoad() {
    sprite = Sprite(game.images.fromCache('fireball/fireball.png'));
    add(CircleHitbox.relative(0.6, parentSize: size));
  }

  @override
  void update(double dt) {
    x -= speed * dt;

    _time += dt;
    scale = Vector2.all(1 + 0.12 * sin(_time * 2 * pi * _flickersPerSecond));

    // Remove the fireball once it leaves the screen.
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
      other.hitByProjectile(0.5);
      removeFromParent();
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}
