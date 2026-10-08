import 'package:flutter/material.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'ninja_run.dart';
import '/models/enemy_data.dart';
import 'fireball.dart';
import 'enemy_rocket.dart';

// This represents an enemy in the game world.
//ဒီ Enemy class က Flame game engine ကို အသုံးပြုပြီးရေးထားတဲ့ Game World ထဲမှာထည့်မယ့် ရန်သူ (enemy) character တစ်ခုကို ဖော်ပြတာပါ။
//ဒါဟာ Ninja game ထဲမှာ Ninja နဲ့ တိုက်ခိုက်မယ့် character ဖြစ်ပါတယ်။

// SpriteAnimationComponent = Enemy ဟာ animated sprite တစ်ခုဖြစ်တယ် (frame-based animation)
// CollisionCallbacks = Enemy ဟာ collision detection လုပ်တယ်
// HasGameReference<NinjaRun> = Game world (NinjaRun) ကို reference လုပ်နိုင်တယ် (player data, score access လုပ်ဖို့)

class Enemy extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameReference<NinjaRun> {
  // The data required for creation of this enemy.
  //enemyData ဆိုတာ EnemyData model class မှာရှိတဲ့ ရန်သူတစ်ဦးစီရဲ့
  //animation info (image, frame count, step time, texture size, speedX) ပါ။
  final EnemyData enemyData;

  Enemy(this.enemyData) {
    animation = SpriteAnimation.fromFrameData(
      enemyData.image,
      SpriteAnimationData.sequenced(
        amount: enemyData.nFrames,
        stepTime: enemyData.stepTime,
        textureSize: enemyData.textureSize,
      ),
    );
  }

  bool isTransformed = false;

  // A fire breathing enemy breathes one fireball once it is
  // [_fireDistance] of the screen width away from the right side.
  static const _fireDistance = 0.3;
  static const _breathTime = 0.4;
  bool _hasBreathedFire = false;
  bool _hasThrownRocket = false;
  double _breathLeft = 0;

  void transformEnemy() {
    if (!isTransformed && enemyData.deathFrames > 0) {
      // Play the death frames once and stay on the last one.
      final deathSize = enemyData.deathTextureSize ?? enemyData.textureSize;
      animation = SpriteAnimation.fromFrameData(
        enemyData.deathImage ?? enemyData.image,
        SpriteAnimationData.sequenced(
          amount: enemyData.deathFrames,
          stepTime: 0.1,
          textureSize: deathSize,
          texturePosition: Vector2(enemyData.deathFrameStart * deathSize.x, 0),
          loop: false,
        ),
      );
      isTransformed = true;
    }
  }

  // Add this getter to expose attackable
  bool get attackable => enemyData.attackable;

  @override
  void onMount() {
    // Reduce the size of enemy as they look too
    // big compared to the Ninja.
    size *= 0.5;
    // Add a hitbox for this enemy.
    add(
      RectangleHitbox.relative(
        Vector2.all(0.8),
        parentSize: size,
        position: Vector2(size.x * 0.2, size.y * 0.2) / 2,
      ),
    );

    // Add the enemy name above it, only if the player has given it one.
    final name = game.settings.enemyName(enemyData.id);
    TextComponent? title;
    if (name.isNotEmpty) {
      title = TextComponent(
        text: name,
        textRenderer: TextPaint(
          style: TextStyle(
            fontSize: 7,
            color: Color(0xFFFFFFFF),
            fontFamilyFallback: ['NotoSerifMyanmar'],
          ),
        ),
        anchor: Anchor.bottomCenter,
        position: Vector2(size.x / 2, -1),
      );
      add(title);
    }

    // Make right facing enemies face the player. The title is flipped
    // back so that its text does not appear mirrored.
    if (enemyData.facesRight) {
      flipHorizontallyAroundCenter();
      title?.flipHorizontally();
    }

    super.onMount();
  }

  @override
  void update(double dt) {
    position.x -= enemyData.speedX * dt;

    if (enemyData.shootsFire &&
        !_hasBreathedFire &&
        x < game.virtualSize.x * (1 - _fireDistance)) {
      _breatheFire();
    }

    if (enemyData.throwsRocket &&
        !_hasThrownRocket &&
        x < game.virtualSize.x * (1 - _fireDistance)) {
      _throwRocket();
    }

    // Glows orange for a moment while breathing fire.
    if (_breathLeft > 0) {
      _breathLeft -= dt;
      if (_breathLeft <= 0) {
        paint.colorFilter = null;
      }
    }

    // Remove the enemy and increase player score
    // by 1, if enemy has gone past left end of the screen.
    if (position.x < -enemyData.textureSize.x) {
      removeFromParent();
      // game.playerData.currentScore += 1;
    }

    super.update(dt);
  }

  void _breatheFire() {
    _hasBreathedFire = true;
    _breathLeft = _breathTime;
    paint.colorFilter = const ColorFilter.mode(
      Color(0xFFFFA040),
      BlendMode.modulate,
    );
    // From its mouth, at the front of its face.
    game.world.add(Fireball(position: Vector2(x, y - size.y * 0.45)));
  }

  // Throws a rocket at where Ninja is now.
  void _throwRocket() {
    _hasThrownRocket = true;
    game.world.add(
      EnemyRocket(position: absoluteCenter, target: game.ninja.absoluteCenter),
    );
  }
}
