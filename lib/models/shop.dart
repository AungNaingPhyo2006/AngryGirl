import 'dart:math';
import 'dart:ui';

// Everything which can be bought with diamonds in the shop.

enum UpgradeType {
  rocketCapacity,
  magnetDuration,
  shieldStrength,
  dinoLife,
  maxLives,
  startShield,
  batCarry,
}

class Upgrade {
  final UpgradeType type;

  // Price in diamonds of each level, so its length is the maximum level.
  final List<int> costs;

  const Upgrade(this.type, this.costs);

  int get maxLevel => costs.length;

  static const all = [
    Upgrade(UpgradeType.rocketCapacity, [20, 40, 60, 80, 100]),
    Upgrade(UpgradeType.magnetDuration, [15, 30, 45, 60, 75]),
    Upgrade(UpgradeType.shieldStrength, [50, 100]),
    Upgrade(UpgradeType.dinoLife, [25, 50, 75, 100]),
    Upgrade(UpgradeType.maxLives, [100, 200, 300]),
    Upgrade(UpgradeType.startShield, [120]),
    Upgrade(UpgradeType.batCarry, [30, 60, 90, 120]),
  ];

  static Upgrade of(UpgradeType type) => all.firstWhere((u) => u.type == type);
}

// A character skin. Skins recolour the Ninja sprite.
class Skin {
  final String id;
  final int price;

  // Multiplied with the colours of the sprite.
  final Color? tint;

  // Used instead of [tint] for effects a tint can't make.
  final List<double>? matrix;

  const Skin(this.id, this.price, {this.tint, this.matrix});

  ColorFilter? get colorFilter {
    if (matrix != null) {
      return ColorFilter.matrix(matrix!);
    }
    if (tint != null) {
      return ColorFilter.mode(tint!, BlendMode.modulate);
    }
    return null;
  }

  static const defaultId = 'default';

  static const all = [
    Skin(defaultId, 0),
    Skin('crimson', 300, tint: Color(0xFFFF8A80)),
    Skin('ocean', 400, tint: Color(0xFF80D8FF)),
    Skin('forest', 600, tint: Color(0xFFB9F6CA)),
    // Grey and dark.
    Skin(
      'shadow',
      700,
      matrix: [
        0.15, 0.3, 0.05, 0, 0, //
        0.15, 0.3, 0.05, 0, 0, //
        0.15, 0.3, 0.05, 0, 0, //
        0, 0, 0, 1, 0, //
      ],
    ),
    Skin('gold', 800, tint: Color(0xFFFFE082)),
  ];

  static Skin of(String id) =>
      all.firstWhere((s) => s.id == id, orElse: () => all.first);
}

// A background scene, made of parallax layers in images/parallax/,
// from the farthest to the nearest. The last layer is the ground.
class Background {
  final String id;
  final int price;
  final List<String> layers;

  const Background(this.id, this.price, this.layers);

  static const defaultId = 'waterfall';

  static const all = [
    Background(defaultId, 0, [
      'parallax/plx-1.png',
      'parallax/plx-2.png',
      'parallax/plx-3.png',
      'parallax/plx-4.png',
      'parallax/plx-5.png',
      'parallax/plx-6.png',
    ]),
    Background('jungle', 500, [
      'parallax/plx-1.png',
      'parallax/parallax_4/plx-3.png',
      'parallax/parallax_4/plx-4.png',
      'parallax/parallax_4/plx-5.png',
      'parallax/plx-6.png',
    ]),
    Background('lake', 1000, [
      'parallax/parallax_1/sky.png',
      'parallax/parallax_1/clouds_2.png',
      'parallax/parallax_1/clouds_1.png',
      'parallax/parallax_1/rocks.png',
      'parallax/parallax_1/ground.png',
      'parallax/parallax_1/ground_strip.png',
    ]),
    Background('night_forest', 2000, [
      'parallax/parallax_2/sky.png',
      'parallax/parallax_2/clouds_2.png',
      'parallax/parallax_2/clouds_1.png',
      'parallax/parallax_2/rocks.png',
      'parallax/parallax_2/ground_1.png',
      'parallax/parallax_2/ground_2.png',
      'parallax/parallax_2/ground_3.png',
      'parallax/parallax_2/ground_strip.png',
    ]),
    Background('city', 3000, [
      'parallax/parallax_3/sky.png',
      'parallax/parallax_3/houses3.png',
      'parallax/parallax_3/houses2.png',
      'parallax/parallax_3/houses1.png',
      'parallax/parallax_3/road.png',
    ]),
  ];

  static Background of(String id) =>
      all.firstWhere((b) => b.id == id, orElse: () => all.first);
}

// Items for one game. Each one bought is used up automatically when the
// next game starts.
enum Consumable { startRockets, doubleScore, startBursts }

class ConsumableItem {
  final Consumable type;
  final int price;

  const ConsumableItem(this.type, this.price);

  // Rockets held at the start with [Consumable.startRockets].
  static const startRocketCount = 3;

  // Seconds of double score at the start with [Consumable.doubleScore].
  static const doubleScoreSeconds = 30.0;

  // Bursts held at the start with [Consumable.startBursts].
  static const startBurstCount = 2;

  static const all = [
    ConsumableItem(Consumable.startRockets, 30),
    ConsumableItem(Consumable.doubleScore, 40),
    ConsumableItem(Consumable.startBursts, 50),
  ];
}

// Looks and sounds which can be bought. The first item of each group is
// free and used until the player chooses another one.
enum CosmeticGroup { music, shieldColor, rocketStyle, dinoColor }

class Cosmetic {
  final CosmeticGroup group;
  final String id;
  final int price;

  // Background music file in assets/audio/, for [CosmeticGroup.music].
  final String? music;

  // Colour of the shield, for [CosmeticGroup.shieldColor].
  final Color? color;

  // Degrees the colours are turned around the colour wheel,
  // for [CosmeticGroup.dinoColor].
  final double? hue;

  const Cosmetic(
    this.group,
    this.id,
    this.price, {
    this.music,
    this.color,
    this.hue,
  });

  // Key of this item when it is saved as bought.
  String get key => '${group.name}.$id';

  ColorFilter? get hueFilter =>
      hue == null || hue == 0 ? null : ColorFilter.matrix(hueRotation(hue!));

  static const all = [
    Cosmetic(CosmeticGroup.music, '8bit', 0, music: '8BitPlatformerLoop.wav'),
    Cosmetic(
      CosmeticGroup.music,
      'superepic',
      500,
      music: 'alexander-nakarada-superepic.mp3',
    ),
    Cosmetic(CosmeticGroup.shieldColor, 'blue', 0, color: Color(0xFF40C4FF)),
    Cosmetic(CosmeticGroup.shieldColor, 'gold', 200, color: Color(0xFFFFD54F)),
    Cosmetic(CosmeticGroup.shieldColor, 'pink', 200, color: Color(0xFFFF80AB)),
    Cosmetic(
      CosmeticGroup.shieldColor,
      'purple',
      200,
      color: Color(0xFFB388FF),
    ),
    Cosmetic(CosmeticGroup.rocketStyle, 'fireball', 0),
    // The fireball turned blue.
    Cosmetic(CosmeticGroup.rocketStyle, 'plasma', 300, hue: 180),
    Cosmetic(CosmeticGroup.rocketStyle, 'missile', 300),
    Cosmetic(CosmeticGroup.dinoColor, 'yellow', 0, hue: 0),
    Cosmetic(CosmeticGroup.dinoColor, 'green', 250, hue: 70),
    Cosmetic(CosmeticGroup.dinoColor, 'blue', 250, hue: 160),
    Cosmetic(CosmeticGroup.dinoColor, 'red', 250, hue: -50),
  ];

  static List<Cosmetic> inGroup(CosmeticGroup group) =>
      all.where((c) => c.group == group).toList();

  static Cosmetic find(CosmeticGroup group, String? id) {
    final items = inGroup(group);
    return items.firstWhere((c) => c.id == id, orElse: () => items.first);
  }
}

// Colour matrix which turns colours [degrees] around the colour wheel,
// keeping their brightness.
List<double> hueRotation(double degrees) {
  final r = degrees * pi / 180;
  final c = cos(r);
  final s = sin(r);
  const lr = 0.213, lg = 0.715, lb = 0.072;
  return [
    lr + c * (1 - lr) - s * lr,
    lg - c * lg - s * lg,
    lb - c * lb + s * (1 - lb),
    0,
    0, //
    lr - c * lr + s * 0.143,
    lg + c * (1 - lg) + s * 0.140,
    lb - c * lb - s * 0.283,
    0,
    0, //
    lr - c * lr - s * (1 - lr),
    lg - c * lg + s * lg,
    lb + c * (1 - lb) + s * lb,
    0,
    0, //
    0, 0, 0, 1, 0, //
  ];
}
