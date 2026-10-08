import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

import 'app_strings.dart';

part 'settings.g.dart';

// This class stores the game settings persistently.
@HiveType(typeId: 1)
class Settings extends ChangeNotifier with HiveObjectMixin {
  Settings({bool bgm = false, bool sfx = false}) {
    _bgm = bgm;
    _sfx = sfx;
  }

  @HiveField(0)
  bool _bgm = false;

  bool get bgm => _bgm;
  set bgm(bool value) {
    _bgm = value;
    notifyListeners();
    save();
  }

  @HiveField(1)
  bool _sfx = false;

  bool get sfx => _sfx;
  set sfx(bool value) {
    _sfx = value;
    notifyListeners();
    save();
  }

  // Suggested names for each enemy, keyed by [EnemyData.id]. They are
  // only shown as hints, so enemy names are hidden by default.
  static const defaultEnemyNames = {
    'angry_pig': 'Angry Pig',
    'bat': 'Bird Fighter',
    'gino': 'Street Fighter',
    'chick': 'Chick Fighter',
    'knight': 'Worrier',
    'adventurer': 'Adventurer',
    'ninja_frog': 'Ninja Frog',
    'mask_dude': 'Mask Dude',
    'pink_man': 'Pink Man',
    'virtual_guy': 'Virtual Guy',
    'skeleton': 'Skeleton',
  };

  // Names given by the player. An empty name hides the enemy's name.
  @HiveField(2)
  Map<String, String>? _enemyNames;

  String enemyName(String id) => _enemyNames?[id] ?? '';

  // Language of the app texts. Myanmar is used until the player changes it.
  @HiveField(3)
  String? _language;

  String get language => _language ?? AppStrings.myanmar;
  set language(String value) {
    _language = value;
    notifyListeners();
    save();
  }

  AppStrings get strings => AppStrings.of(language);

  // True once the hud guide has been shown, so that it is only
  // shown in the first game.
  @HiveField(4)
  bool? _hudGuideSeen;

  bool get hudGuideSeen => _hudGuideSeen ?? false;
  set hudGuideSeen(bool value) {
    _hudGuideSeen = value;
    notifyListeners();
    save();
  }

  // True once the tutorial has been finished. Until then, the
  // tutorial button in the main menu stands out for new players.
  @HiveField(5)
  bool? _tutorialDone;

  bool get tutorialDone => _tutorialDone ?? false;
  set tutorialDone(bool value) {
    _tutorialDone = value;
    notifyListeners();
    save();
  }

  void setEnemyName(String id, String name) {
    (_enemyNames ??= {})[id] = name.trim();
    notifyListeners();
    save();
  }
}
