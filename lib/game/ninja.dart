import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '/game/enemy.dart';
import '/game/score_popup.dart';
import 'ninja_run.dart';
import '/game/audio_manager.dart';
import '/models/player_data.dart';
import '/models/shop.dart';

//This enum represents the animation states of [Ninja].
//ဒီကုဒ်က NinjaRun game ထဲမှာ အသုံးပြုတဲ့ main player character ဖြစ်တဲ့ Ninja class ကိုဖေါ်ပြတာပါ။
//ဒီ Ninja class က သုံးသပ် animation, gravity, collision, jump, hit စတာတွေအကုန် handle လုပ်ပါတယ်။

//Character ဟာ idle, run, kick, hit, sprint ဆိုတဲ့ animation 5 မျိုး ရှိတယ်။
// carried: helper bat ချီထားချိန်မှာ Warrior jump ပုံတွေကို သုံးတယ်။
enum NinjaAnimationStates { idle, run, kick, hit, sprint, carried }

//This represents the Ninja character of this game.
//NinjaAnimationStates =>  enum သုံးပြီး animation states ကို control
//Collision detection => (တစ်ခြား enemy နဲ့ ထိတာ)
//HasGameReference<NinjaRun>  => game.virtualSize စတာ access လုပ်ဖို့ game instance reference

class Ninja extends SpriteAnimationGroupComponent<NinjaAnimationStates>
    with CollisionCallbacks, HasGameReference<NinjaRun> {
  // A map of all the animation states and their corresponding animations.
  // Sprite sheet တစ်ခုထဲမှာ frame-based animation တွေကို
  // stepTime နဲ့ texturePosition တို့ဖြင့် animation state တစ်ခုချင်းစီ ဆွဲထုတ်တယ်။

  static final _animationMap = {
    NinjaAnimationStates.run: SpriteAnimationData.sequenced(
      amount: 8,
      stepTime: 0.1,
      textureSize: Vector2.all(64),
      texturePosition: Vector2(0 * 64, 0),
    ),
    NinjaAnimationStates.sprint: SpriteAnimationData.sequenced(
      amount: 3,
      stepTime: 0.1,
      textureSize: Vector2.all(64),
      texturePosition: Vector2(8 * 64, 0),
    ),
    NinjaAnimationStates.kick: SpriteAnimationData.sequenced(
      amount: 5,
      stepTime: 0.1,
      textureSize: Vector2.all(64),
      texturePosition: Vector2(11 * 64, 0),
    ),
    NinjaAnimationStates.idle: SpriteAnimationData.sequenced(
      amount: 3,
      stepTime: 0.1,
      textureSize: Vector2.all(64),
      texturePosition: Vector2(8 * 64, 0),
    ),
    // The sheet has only 9 frames from here (frames 22 to 30). Played
    // once, so that Ninja stays down until the hit timer is over.
    NinjaAnimationStates.hit: SpriteAnimationData.sequenced(
      amount: 9,
      stepTime: 0.1,
      textureSize: Vector2.all(64),
      texturePosition: Vector2(22 * 64, 0),
      loop: false,
    ),
  };

  // The max distance from top of the screen beyond which
  // Ninja should never go. Basically the screen height - ground height
  // yMax – Ninja ရဲ့  (ground level)
  double yMax = 0.0;

  // Ninja's current speed along y-axis.
  // speedY – Y direction ရဲ့ current speed (jump/gravity)
  double speedY = 0.0;

  // Number of jumps made since Ninja left the ground.
  int _jumpCount = 0;
  static const _maxJumps = 2;

  int get jumpCount => _jumpCount;

  // Controlls how long the hit animations will be played.
  final Timer _hitTimer = Timer(1);
  final Timer _attackTimer = Timer(1);

  // After the shield blocks a hit, Ninja can't be hit for a moment,
  // so that the same enemy doesn't take a life right after.
  final Timer _shieldTimer = Timer(1, autoStart: false);

  static final _shieldRimPaint = Paint()
    ..color = const Color(0x99FFFFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.8;
  static final _shieldShinePaint = Paint()..color = const Color(0x99FFFFFF);
  static final _shieldGlintPaint = Paint()..color = const Color(0x66FFFFFF);

  //gravity – fall speed
  static const double gravity = 800;

  // Frames shown while the helper bat carries Ninja.
  static const carriedImages = [
    'player/Jump/Warrior_Jump_1.png',
    'player/Jump/Warrior_Jump_2.png',
    'player/Jump/Warrior_Jump_3.png',
  ];

  // While carried, Ninja is held this far ahead of and above where it
  // runs, and it moves there and back at these speeds.
  static const _carryAhead = 60.0;
  static const _carryHeight = 70.0;
  static const _carrySpeed = 90.0;
  static const _returnSpeed = 40.0;

  // Where Ninja runs along the ground.
  double _homeX = 0;

  final PlayerData playerData;

  //isHit – Ninja  က enemy ကိုထိတာ စောင့်ကြည့်
  bool isHit = false;
  bool isAttack = false;

  //Sprite sheet image နဲ့ animationMap ကို ပေးပြီး
  //superclass (SpriteAnimationGroupComponent) ကို initialize လုပ်တယ်။

  Ninja(Image image, this.playerData)
    : super.fromFrameData(image, _animationMap);

  @override
  void onLoad() {
    // The frames are separate images, drawn at the size of the
    // frames of the sheet so that Ninja looks the same size.
    animations = {
      ...animations!,
      NinjaAnimationStates.carried: SpriteAnimation.spriteList([
        for (final image in carriedImages)
          Sprite(game.images.fromCache(image), srcSize: Vector2.all(64)),
      ], stepTime: 0.15),
    };
  }

  @override
  void onMount() {
    // First reset all the important properties, because onMount()
    // will be called even while restarting the game.
    _reset();

    // Recolour Ninja with the skin chosen in the shop.
    paint.colorFilter = playerData.skin.colorFilter;

    // Add a hitbox for Ninja.
    //collision detect မလုပ်နိုင်အောင်
    add(
      RectangleHitbox.relative(
        Vector2(0.5, 0.7),
        parentSize: size,
        position: Vector2(size.x * 0.5, size.y * 0.3) / 2,
      ),
    );
    yMax = y; //yMax ကို Ninja ရဲ့ current Y coordinate ထားတယ်။

    /// Set the callback for [_hitTimer].
    //_hitTimer.onTick မှာ hit animation ပြီးရင် run ပြန်ထားတယ်။
    _hitTimer.onTick = () {
      current = NinjaAnimationStates.run;
      isHit = false;
    };

    _attackTimer.onTick = () {
      // Don't cut the hit animation if Ninja got hit while kicking.
      if (!isHit) {
        current = NinjaAnimationStates.run;
      }
      isAttack = false;
    };

    super.onMount();
  }

  //Gravity update => Ninja fall
  //Jump ပြီးမြေပေါ်ရောက်ရင် => Y value ကို limit
  //isOnGround ဖြစ်ရင် animation ကို run ပြန်ထားတယ်။
  //_hitTimer.update(dt) – hit animation ပြီးဖို့ timer run
  @override
  void update(double dt) {
    if (playerData.isCarried) {
      _updateCarried(dt);
    } else {
      // v = u + at
      speedY += gravity * dt;

      // d = s0 + s * t
      y += speedY * dt;

      // Go back to where Ninja runs after being carried ahead.
      if (x > _homeX) {
        x = max(_homeX, x - _returnSpeed * dt);
      }
    }

    /// This code makes sure that Ninja never goes beyond [yMax].
    if (isOnGround) {
      y = yMax;
      speedY = 0.0;
      if ((current != NinjaAnimationStates.hit) &&
          (current != NinjaAnimationStates.run)) {
        current = NinjaAnimationStates.run;
      }
    }

    _hitTimer.update(dt);
    _attackTimer.update(dt);
    _shieldTimer.update(dt);

    if (playerData.hasMagnet) {
      playerData.magnetTime -= dt;
    }
    if (playerData.doubleScoreTime > 0) {
      playerData.doubleScoreTime -= dt;
    }
    super.update(dt);
  }

  // Rises up and ahead with the helper bat, and falls once it lets go.
  void _updateCarried(double dt) {
    position.moveToTarget(
      Vector2(_homeX + _carryAhead, yMax - _carryHeight),
      _carrySpeed * dt,
    );
    speedY = 0;
    current = NinjaAnimationStates.carried;

    playerData.carryTime -= dt;
    if (!playerData.isCarried) {
      // Safe for a moment after landing among enemies, and one
      // more jump can be made while falling.
      _shieldTimer.start();
      _jumpCount = 1;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw a glass ball around Ninja while the shield is active.
    if (playerData.hasShield) {
      _drawShield(canvas, (size / 2).toOffset(), size.x * 0.5);
    }
  }

  // A see-through glass ball: clear in the middle and bluer towards
  // the edge, with a thin rim and white reflections at the top left.
  void _drawShield(Canvas canvas, Offset center, double radius) {
    // In the colour chosen in the shop.
    final color = playerData.cosmetic(CosmeticGroup.shieldColor).color!;
    final glass = Paint()
      ..shader = Gradient.radial(
        center - Offset(radius, radius) * 0.3,
        radius * 1.3,
        [const Color(0x10FFFFFF), color.withAlpha(0x30), color.withAlpha(0x90)],
        const [0, 0.65, 1],
      );
    canvas.drawCircle(center, radius, glass);
    canvas.drawCircle(center, radius, _shieldRimPaint);

    canvas.save();
    canvas.translate(center.dx - radius * 0.38, center.dy - radius * 0.48);
    canvas.rotate(-0.6);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: radius * 0.6,
        height: radius * 0.25,
      ),
      _shieldShinePaint,
    );
    canvas.restore();

    canvas.drawCircle(
      center + Offset(radius * 0.45, radius * 0.42),
      radius * 0.08,
      _shieldGlintPaint,
    );
  }

  // Gets called when Ninja collides with other Collidables.
  //တခြား object (enemy) နဲ့ Ninja ထိတိုက်တိုင်း hit() method ခေါ်တယ်။
  //isHit မဖြစ်လျှင်သာ hit ခေါ်တယ်။
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    // Call hit only if other component is an Enemy and Ninja
    // is not already in hit state.
    // Already defeated enemies are ignored, and so are all
    // the enemies while the helper bat carries Ninja.
    if (other is Enemy && !other.isTransformed && !playerData.isCarried) {
      if (other.attackable) {
        // Kick only one enemy at a time.
        if (!isAttack && !isHit) {
          attack(other);
          other.transformEnemy();
        }
      } else if (!isHit && !_shieldTimer.isRunning()) {
        // Kicking an enemy does not protect Ninja from the others.
        if (!_blockWithShield()) {
          hit();
        }
      }
    }
    super.onCollision(intersectionPoints, other);
  }

  // Returns true if Ninja is on ground.
  bool get isOnGround => (y >= yMax);

  // Makes the Ninja jump.
  //Ground မှာရှိရင်သာ ခုန်နိုင်တယ်။
  //speedY = -300 => ခုန်ခြင်း
  //Sound effect play
  void jump() {
    // Ninja can't jump while carried by the helper bat.
    if (playerData.isCarried) {
      return;
    }
    // Jump from the ground, or once more while in the air (double jump).
    if (isOnGround) {
      _jumpCount = 0;
    }
    if (_jumpCount < _maxJumps) {
      _jumpCount++;
      speedY = -300;
      current = NinjaAnimationStates.idle;
      AudioManager.instance.playSfx('jump14.wav');
    }
  }

  // Gets Ninja up and running again after a revive. Ninja can't be
  // hit for a moment, like after the shield blocks a hit.
  void recover() {
    isHit = false;
    isAttack = false;
    current = NinjaAnimationStates.run;
    _shieldTimer.start();
  }

  // Uses the shield to block a hit instead of losing a life.
  // Returns false if there is no shield.
  bool _blockWithShield() {
    if (!playerData.hasShield) {
      return false;
    }
    playerData.shieldCharges -= 1;
    _shieldTimer.start();
    AudioManager.instance.playSfx('hurt7.wav');
    return true;
  }

  // Called when something thrown at Ninja hits it, such as a fireball
  // (half a life) or a bat's rocket (one life).
  void hitByProjectile(double damage) {
    if (playerData.isCarried ||
        isHit ||
        _shieldTimer.isRunning() ||
        _blockWithShield()) {
      return;
    }
    hit(damage: damage);
  }

  // This method changes the animation state to
  /// [NinjaAnimationStates.hit], plays the hit sound
  /// effect and reduces the player life by [damage].
  void hit({double damage = 1}) {
    isHit = true;
    AudioManager.instance.playSfx('hurt7.wav');
    current = NinjaAnimationStates.hit;
    _hitTimer.start();
    playerData.lives -= damage;
  }

  // Kicks the given enemy and earns its points.
  void attack(Enemy enemy) {
    if (isOnGround) {
      isAttack = true;
      current = NinjaAnimationStates.kick;
      AudioManager.instance.playSfx('jump14.wav');
      _attackTimer.start();
      playerData.currentScore += enemy.enemyData.points;
      game.world.add(ScorePopup.above(enemy));
    }
  }

  // This method reset some of the important properties
  // of this component back to normal.
  //Ninja ကို initial position/size/animation ဖြင့် reset
  //game.virtualSize.y - 22 ဆိုတာ ground level မှာရှိဖို့
  //run animation ကို default အနေနဲ့ ပြထားတယ်။
  void _reset() {
    if (isMounted) {
      removeFromParent();
    }
    anchor = Anchor.bottomLeft;
    position = Vector2(32, game.virtualSize.y - 16);
    _homeX = x;
    size = Vector2.all(32); // Increased from 24 to 48 (doubled the size)
    current = NinjaAnimationStates.run;
    isHit = false;
    speedY = 0.0;
  }
}

// | Function        | Role                                       |
// | --------------- | ------------------------------------------ |
// | `Ninja` class    | Player character (animated + controllable) |
// | `jump()`        | Character ခုန်ဖို့                         |
// | `hit()`         | Life လျော့ဖို့ & animation                 |
// | `update()`      | Gravity effect, fall, animation            |
// | `onCollision()` | Enemy ထိတိုက်တာကို handle                  |
// | `_reset()`      | Game စမယ်ဆိုရင် Ninja ကို refresh           |
// | `onMount()`     | Game world ထဲထည့်သည့်အချိန်မှာ Run         |
