import 'package:flame/extensions.dart';

// This class stores all the data
// necessary for creation of an enemy.
class EnemyData {
  // Key of this enemy in [Settings.defaultEnemyNames], used to
  // look up the name shown above it.
  final String id;
  final Image image;
  final int nFrames;
  final double stepTime;
  final Vector2 textureSize;
  final double speedX;
  final bool canFly;
  final bool attackable;

  // True if the sprite sheet faces right. Such enemies are flipped
  // so that they face the player while running towards the left.
  final bool facesRight;

  // Index of the first frame and number of frames of the animation
  // played when this enemy gets attacked. These frames follow the
  // run frames in the same row of the sprite sheet.
  final int deathFrameStart;
  final int deathFrames;

  // Sheet of the death frames, if they are not in [image].
  final Image? deathImage;

  // Frame size of [deathImage], if it is not [textureSize].
  final Vector2? deathTextureSize;

  // Points earned when this enemy is defeated.
  final int points;

  // Points earned when a rocket hits this enemy. Rockets pass through
  // enemies that can be kicked, unless this is given.
  final int? rocketPoints;

  bool get rocketCanHit => !attackable || rocketPoints != null;

  // True for an enemy which breathes a fireball at Ninja.
  final bool shootsFire;

  // True for an enemy which throws a [EnemyRocket] at Ninja.
  final bool throwsRocket;

  const EnemyData({
    required this.id,
    required this.image,
    required this.nFrames,
    required this.stepTime,
    required this.textureSize,
    required this.speedX,
    required this.canFly,
    required this.attackable,
    this.facesRight = false,
    this.deathFrameStart = 0,
    this.deathFrames = 0,
    this.deathImage,
    this.deathTextureSize,
    this.points = 5,
    this.rocketPoints,
    this.shootsFire = false,
    this.throwsRocket = false,
  });
}
