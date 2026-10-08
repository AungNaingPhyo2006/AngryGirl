import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'ninja.dart';
import 'ninja_run.dart';

// A rocket fired by an enemy (a bat or a chicken) towards Ninja.
// It costs a life if it hits.
class EnemyRocket extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameReference<NinjaRun> {
  static const double speed = 140;

  final Vector2 _velocity;

  // Flies from [position] straight towards [target].
  EnemyRocket({required Vector2 position, required Vector2 target})
    : _velocity = (target - position).normalized() * speed,
      super(position: position, size: Vector2.all(16), anchor: Anchor.center);

  @override
  void onLoad() {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('bullet/Move.png'),
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: 0.08,
        textureSize: Vector2.all(46),
      ),
    );
    // The sprite points to the right, so it is turned to where it flies.
    angle = atan2(_velocity.y, _velocity.x);
    add(CircleHitbox.relative(0.7, parentSize: size));
  }

  @override
  void update(double dt) {
    position += _velocity * dt;

    // Remove it once it leaves the screen.
    if (x < -size.x || y > game.virtualSize.y + size.y) {
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
      other.hitByProjectile(1);
      removeFromParent();
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}
