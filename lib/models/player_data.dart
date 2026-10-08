import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'shop.dart';

part 'player_data.g.dart';

// This class stores the player progress presistently.
@HiveType(typeId: 0)
class PlayerData extends ChangeNotifier with HiveObjectMixin {
  @HiveField(1)
  int highScore = 0;

  // A rocket is earned for every [scorePerRocket] points, and at most
  // [maxRockets] can be held at a time. The rocket capacity upgrade
  // adds one rocket for each level.
  static const baseMaxRockets = 5;
  static const scorePerRocket = 20;

  int get maxRockets =>
      baseMaxRockets + upgradeLevel(UpgradeType.rocketCapacity);

  int _rockets = 0;

  int get rockets => _rockets;
  set rockets(int value) {
    _rockets = value.clamp(0, maxRockets);
    notifyListeners();
  }

  // A burst is earned for every [scorePerBurst] points, and at most
  // [maxBursts] can be held at a time. A burst drops a bomb on each
  // of the nearest enemies in front of Ninja.
  static const maxBursts = 3;
  static const scorePerBurst = 200;

  int _bursts = 0;

  int get bursts => _bursts;
  set bursts(int value) {
    _bursts = value.clamp(0, maxBursts);
    notifyListeners();
  }

  // A helper bat item appears every [scorePerHelperBat] points. The bat
  // carries Ninja through the air for [carryDuration] seconds. Each bat
  // carry upgrade level adds [carrySecondsPerLevel].
  static const scorePerHelperBat = 400;
  static const baseCarryDuration = 5.0;
  static const carrySecondsPerLevel = 1.0;

  double get carryDuration =>
      baseCarryDuration +
      carrySecondsPerLevel * upgradeLevel(UpgradeType.batCarry);

  // Seconds left of being carried by the helper bat. Listeners are
  // notified only when the whole seconds change, as it changes every frame.
  double _carryTime = 0;

  double get carryTime => _carryTime;
  bool get isCarried => _carryTime > 0;
  set carryTime(double value) {
    final oldSeconds = _carryTime.ceil();
    _carryTime = max(0, value);
    if (_carryTime.ceil() != oldSeconds) {
      notifyListeners();
    }
  }

  // A power-up appears every [scorePerPowerUp] points.
  static const scorePerPowerUp = 100;

  // Each magnet duration upgrade level adds [magnetSecondsPerLevel].
  static const baseMagnetDuration = 8.0;
  static const magnetSecondsPerLevel = 2.0;

  double get magnetDuration =>
      baseMagnetDuration +
      magnetSecondsPerLevel * upgradeLevel(UpgradeType.magnetDuration);

  // Number of hits the shield can still block. A picked up shield
  // blocks one hit, plus one for each shield strength upgrade level.
  int _shieldCharges = 0;

  int get shieldCharges => _shieldCharges;
  bool get hasShield => _shieldCharges > 0;
  int get maxShieldCharges => 1 + upgradeLevel(UpgradeType.shieldStrength);

  // Number of enemies the helper dino defeats before it dies. Each dino
  // life upgrade level lets it defeat one more.
  static const baseDinoLife = 2;

  int get dinoLife => baseDinoLife + upgradeLevel(UpgradeType.dinoLife);
  set shieldCharges(int value) {
    _shieldCharges = max(0, value);
    notifyListeners();
  }

  // Seconds left of the magnet power-up. Listeners are notified
  // only when the whole seconds change, as it changes every frame.
  double _magnetTime = 0;

  double get magnetTime => _magnetTime;
  bool get hasMagnet => _magnetTime > 0;
  set magnetTime(double value) {
    final oldSeconds = _magnetTime.ceil();
    _magnetTime = max(0, value);
    if (_magnetTime.ceil() != oldSeconds) {
      notifyListeners();
    }
  }

  // Diamonds collected in all games, which are spent in the shop.
  @HiveField(2)
  int _diamonds = 0;

  int get diamonds => _diamonds;
  set diamonds(int value) {
    _diamonds = value;
    notifyListeners();
    save();
  }

  // Bought level of each upgrade, keyed by [UpgradeType.name].
  @HiveField(3)
  Map<String, int>? _upgradeLevels;

  int upgradeLevel(UpgradeType type) => _upgradeLevels?[type.name] ?? 0;

  // Buys the next level of the given upgrade.
  // Returns false if it is at its maximum level or can't be afforded.
  bool buyUpgrade(UpgradeType type) {
    final upgrade = Upgrade.of(type);
    final level = upgradeLevel(type);
    if (level >= upgrade.maxLevel || _diamonds < upgrade.costs[level]) {
      return false;
    }
    _diamonds -= upgrade.costs[level];
    (_upgradeLevels ??= {})[type.name] = level + 1;
    notifyListeners();
    save();
    return true;
  }

  // Ids of the bought skins. The default skin is always owned.
  @HiveField(4)
  List<String>? _ownedSkins;

  @HiveField(5)
  String? _selectedSkin;

  Skin get skin => Skin.of(_selectedSkin ?? Skin.defaultId);

  bool ownsSkin(String id) =>
      id == Skin.defaultId || (_ownedSkins?.contains(id) ?? false);

  // Buys the given skin and puts it on.
  // Returns false if it is already owned or can't be afforded.
  bool buySkin(String id) {
    final price = Skin.of(id).price;
    if (ownsSkin(id) || _diamonds < price) {
      return false;
    }
    _diamonds -= price;
    (_ownedSkins ??= []).add(id);
    _selectedSkin = id;
    notifyListeners();
    save();
    return true;
  }

  void selectSkin(String id) {
    if (ownsSkin(id)) {
      _selectedSkin = id;
      notifyListeners();
      save();
    }
  }

  // Ids of the bought backgrounds. The default one is always owned.
  @HiveField(6)
  List<String>? _ownedBackgrounds;

  @HiveField(7)
  String? _selectedBackground;

  Background get background =>
      Background.of(_selectedBackground ?? Background.defaultId);

  bool ownsBackground(String id) =>
      id == Background.defaultId || (_ownedBackgrounds?.contains(id) ?? false);

  // Buys the given background and uses it.
  // Returns false if it is already owned or can't be afforded.
  bool buyBackground(String id) {
    final price = Background.of(id).price;
    if (ownsBackground(id) || _diamonds < price) {
      return false;
    }
    _diamonds -= price;
    (_ownedBackgrounds ??= []).add(id);
    _selectedBackground = id;
    notifyListeners();
    save();
    return true;
  }

  void selectBackground(String id) {
    if (ownsBackground(id)) {
      _selectedBackground = id;
      notifyListeners();
      save();
    }
  }

  // Number of each one-game item owned, keyed by [Consumable.name].
  @HiveField(8)
  Map<String, int>? _consumables;

  int consumableCount(Consumable type) => _consumables?[type.name] ?? 0;

  // Buys one more of the given one-game item.
  // Returns false if it can't be afforded.
  bool buyConsumable(ConsumableItem item) {
    if (_diamonds < item.price) {
      return false;
    }
    _diamonds -= item.price;
    (_consumables ??= {})[item.type.name] = consumableCount(item.type) + 1;
    notifyListeners();
    save();
    return true;
  }

  // Uses up one of the given one-game item.
  // Returns false if there is none.
  bool useConsumable(Consumable type) {
    final count = consumableCount(type);
    if (count <= 0) {
      return false;
    }
    _consumables![type.name] = count - 1;
    notifyListeners();
    save();
    return true;
  }

  // Keys ([Cosmetic.key]) of the bought cosmetics. The first one of
  // each group is free, so it is always owned.
  @HiveField(9)
  List<String>? _ownedCosmetics;

  // Id of the chosen cosmetic of each group, keyed by [CosmeticGroup.name].
  @HiveField(10)
  Map<String, String>? _selectedCosmetics;

  Cosmetic cosmetic(CosmeticGroup group) =>
      Cosmetic.find(group, _selectedCosmetics?[group.name]);

  bool ownsCosmetic(Cosmetic item) =>
      item.price == 0 || (_ownedCosmetics?.contains(item.key) ?? false);

  // Buys the given cosmetic and uses it.
  // Returns false if it is already owned or can't be afforded.
  bool buyCosmetic(Cosmetic item) {
    if (ownsCosmetic(item) || _diamonds < item.price) {
      return false;
    }
    _diamonds -= item.price;
    (_ownedCosmetics ??= []).add(item.key);
    (_selectedCosmetics ??= {})[item.group.name] = item.id;
    notifyListeners();
    save();
    return true;
  }

  void selectCosmetic(Cosmetic item) {
    if (ownsCosmetic(item)) {
      (_selectedCosmetics ??= {})[item.group.name] = item.id;
      notifyListeners();
      save();
    }
  }

  // Seconds left of double score. Listeners are notified only when
  // the whole seconds change, as it changes every frame.
  double _doubleScoreTime = 0;

  double get doubleScoreTime => _doubleScoreTime;
  set doubleScoreTime(double value) {
    final oldSeconds = _doubleScoreTime.ceil();
    _doubleScoreTime = max(0, value);
    if (_doubleScoreTime.ceil() != oldSeconds) {
      notifyListeners();
    }
  }

  // Lives can be lost in halves, as a fireball costs half a life.
  // Each max lives upgrade level adds one more life.
  static const baseMaxLives = 5;

  int get maxLives => baseMaxLives + upgradeLevel(UpgradeType.maxLives);

  double _lives = baseMaxLives.toDouble();

  double get lives => _lives;
  set lives(double value) {
    _lives = value.clamp(0, maxLives.toDouble());
    notifyListeners();
  }

  // True if every game starts with a shield.
  bool get startsWithShield => upgradeLevel(UpgradeType.startShield) > 0;

  // Times the player revived in the current game, after running out of
  // lives. Each revive costs twice as many diamonds as the one before.
  static const baseReviveCost = 20;
  int revives = 0;

  int get reviveCost => baseReviveCost * (1 << revives);

  // Pays for a revive and gives one life back.
  // Returns false if it can't be afforded.
  bool revive() {
    if (_diamonds < reviveCost) {
      return false;
    }
    _diamonds -= reviveCost;
    revives++;
    _lives = 1;
    notifyListeners();
    save();
    return true;
  }

  int _currentScore = 0;

  int get currentScore => _currentScore;
  set currentScore(int value) {
    // Points earned count twice while double score is on.
    if (_doubleScoreTime > 0 && value > _currentScore) {
      value = _currentScore + (value - _currentScore) * 2;
    }
    final earned = value ~/ scorePerRocket - _currentScore ~/ scorePerRocket;
    if (earned > 0) {
      _rockets = min(_rockets + earned, maxRockets);
    }
    final earnedBursts =
        value ~/ scorePerBurst - _currentScore ~/ scorePerBurst;
    if (earnedBursts > 0) {
      _bursts = min(_bursts + earnedBursts, maxBursts);
    }
    _currentScore = value;

    if (highScore < _currentScore) {
      highScore = _currentScore;
    }

    notifyListeners();
    save();
  }
}
