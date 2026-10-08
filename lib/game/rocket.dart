import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '/game/enemy.dart';
import '/models/shop.dart';
import '/game/score_popup.dart';
import 'ninja_run.dart';

// A rocket fired by the player. It flies to the right and destroys the
// first enemy it hits that cannot be attacked by kicking, or that has
// [EnemyData.rocketPoints]. Other enemies are not affected and the
// rocket passes through them.
class Rocket extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameReference<NinjaRun> {
  static const double speed = 250;

  Rocket({required super.position})
    : super(size: Vector2.all(16), anchor: Anchor.center);

  @override
  void onLoad() {
    // In the look chosen in the shop.
    final style = game.playerData.cosmetic(CosmeticGroup.rocketStyle);
    if (style.id == 'missile') {
      animation = SpriteAnimation.spriteList([
        Sprite(game.images.fromCache('power_ups/missile.png')),
      ], stepTime: 1);
      // The picture points up and to the right.
      angle = pi / 4;
    } else {
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('bullet/Move.png'),
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.08,
          textureSize: Vector2.all(46),
        ),
      );
      paint.colorFilter = style.hueFilter;
    }
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    x += speed * dt;

    // Remove the rocket once it leaves the screen.
    if (x > game.virtualSize.x + size.x) {
      removeFromParent();
    }
    super.update(dt);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is Enemy &&
        other.enemyData.rocketCanHit &&
        !other.isTransformed) {
      final points = other.enemyData.rocketPoints ?? other.enemyData.points;
      game.world.add(Explosion(position: other.absoluteCenter));
      game.world.add(ScorePopup.above(other, points: points));
      game.playerData.currentScore += points;
      other.removeFromParent();
      removeFromParent();
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}

// Explosion shown where a rocket hits an enemy. Removes itself
// once the animation is over.
class Explosion extends SpriteAnimationComponent
    with HasGameReference<NinjaRun> {
  Explosion({required super.position})
    : super(size: Vector2.all(24), anchor: Anchor.center, removeOnFinish: true);

  @override
  void onLoad() {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('bullet/Explosion.png'),
      SpriteAnimationData.sequenced(
        amount: 7,
        stepTime: 0.06,
        textureSize: Vector2.all(46),
        loop: false,
      ),
    );
  }
}
