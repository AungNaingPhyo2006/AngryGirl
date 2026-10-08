import 'shop.dart';
import 'tutorial_step.dart';

// All the text shown in the app, in each supported language.
// Use [Settings.strings] to get the texts of the selected language.
abstract class AppStrings {
  const AppStrings();

  // Language codes stored in [Settings.language].
  static const myanmar = 'my';
  static const english = 'en';

  static AppStrings of(String language) =>
      language == english ? const _English() : const _Myanmar();

  // Font size of menu button texts. Myanmar letters need a much taller
  // line than English ones, so they are made smaller to fit the buttons.
  double get buttonFontSize;

  // Font size of settings menu texts.
  double get menuFontSize;

  bool get isMyanmar;

  // Main menu.
  String get play;
  String get settings;
  String get about;
  String get exit;
  String get tutorial;

  // Hud, pause and game over menus.
  String score(int score);
  String highScore(int score);
  String get resume;
  String get restart;
  String get gameOver;
  String get revive;
  String yourScore(int score);

  // Hud guide, shown in the first game.
  String get guideJump;
  String get guideScore;
  String get guideDiamonds;
  String get guidePause;
  String get guideLives;
  String get guidePowerUps;
  String guideRockets(int scorePerRocket);
  String guideBurst(int scorePerBurst);
  String get guideNext;
  String get guideSkip;
  String get guideDone;

  // Tutorial.
  String tutorialStep(TutorialStep step);
  String get tutorialGreat;
  String get tutorialTryAgain;

  // Settings menu.
  String get music;
  String get effects;
  String get enemyNames;
  String get language;

  // Enemy names menu.
  String get enemyNamesHint;
  String enemyLabel(String id);

  // Shop menu.
  String get shop;
  String get upgrades;
  String get skins;
  String upgradeName(UpgradeType type);
  // Effect of the given upgrade, e.g. the number of rockets.
  String upgradeValue(UpgradeType type, num value);
  String level(int level, int max);
  String get maxed;
  String get equip;
  String get equipped;
  String skinName(String id);
  String get backgrounds;
  String get oneGameItems;
  String consumableName(Consumable type);
  String owned(int count);
  String get usedNextGame;
  String cosmeticGroupName(CosmeticGroup group);
  String cosmeticName(Cosmetic item);
  String backgroundName(String id);

  // About menu.
  String get description;
  String version(String version, String build);
  String developedBy(String name);
}

class _Myanmar extends AppStrings {
  const _Myanmar();

  @override
  double get buttonFontSize => 22;
  @override
  double get menuFontSize => 20;
  @override
  bool get isMyanmar => true;

  @override
  String get play => 'ကစားမည်';
  @override
  String get settings => 'ဆက်တင်';
  @override
  String get about => 'အကြောင်း';
  @override
  String get exit => 'ထွက်မည်';
  @override
  String get tutorial => 'လေ့ကျင့်ခန်း';

  @override
  String score(int score) => 'ရမှတ်: $score';
  @override
  String highScore(int score) => 'အမြင့်ဆုံး: $score';
  @override
  String get resume => 'ဆက်ကစားမည်';
  @override
  String get restart => 'ပြန်စမည်';
  @override
  String get gameOver => 'ဂိမ်းပြီးပါပြီ';
  @override
  String get revive => 'အသက်ပြန်ရှင်';
  @override
  String yourScore(int score) => 'သင့်ရမှတ်: $score';

  @override
  String get guideJump =>
      'Screen ကို နှိပ်ရင် ခုန်ပါတယ်။ လေထဲမှာ ထပ်နှိပ်ရင် နောက်တစ်ဆင့် ထပ်ခုန်နိုင်ပါတယ်။';
  @override
  String get guideScore =>
      'လက်ရှိရမှတ်နဲ့ အမြင့်ဆုံးရမှတ်။ ရန်သူကို ကန်ရင်၊ စိန်ကောက်ရင် ရမှတ်တက်ပါတယ်။';
  @override
  String get guideDiamonds =>
      'စုထားတဲ့ စိန်များ။ ဆိုင်မှာ ဝယ်ဖို့နဲ့ အသက်ပြန်ရှင်ဖို့ သုံးနိုင်ပါတယ်။';
  @override
  String get guidePause => 'ဂိမ်းကို ခဏရပ်ရန်။';
  @override
  String get guideLives =>
      'ကျန်တဲ့ အသက်များ။ ရန်သူထိရင် နှလုံးတစ်လုံး၊ မီးလုံးထိရင် တစ်ဝက် လျော့ပါတယ်။ '
      'အကုန်ကုန်ရင် ဂိမ်းပြီးပါပြီ။';
  @override
  String get guidePowerUps =>
      'ရထားတဲ့ power-up တွေ ဒီမှာ ပေါ်ပါမယ်။ ဒိုင်းက ထိခိုက်မှုကို ကာပေးပြီး '
      'သံလိုက်က စိန်တွေကို ဆွဲယူပေးပါတယ်။ x2 က ရမှတ်နှစ်ဆ ရစေပါတယ်။';
  @override
  String guideRockets(int scorePerRocket) =>
      'ရမှတ် $scorePerRocket ရတိုင်း ဒုံးကျည်တစ်စင်း ရပါတယ်။ ပတ်လည်က အဝိုင်းက '
      'နောက်ဒုံးကျည်အထိ ဘယ်လောက်ကျန်လဲ ပြပါတယ်။ ကန်လို့မရတဲ့ ရန်သူကို နှိပ်ပြီး ပစ်ပါ။';
  @override
  String guideBurst(int scorePerBurst) =>
      'ရမှတ် $scorePerBurst ရတိုင်း bomb တစ်ခါစာ ရပါတယ်။ နှိပ်လိုက်ရင် ရှေ့က '
      'အနီးဆုံး ရန်သူ ၂ ကောင်ပေါ်ကို bomb ကျပြီး ဘယ်ရန်သူမဆို သေပါတယ်။';
  @override
  String get guideNext => 'နောက်တစ်ခု';
  @override
  String get guideSkip => 'ကျော်မည်';
  @override
  String get guideDone => 'စကစားမည်';

  @override
  String tutorialStep(TutorialStep step) => switch (step) {
    TutorialStep.jump => 'Screen ကို နှိပ်ပြီး ခုန်ကြည့်ပါ။',
    TutorialStep.doubleJump => 'လေထဲမှာ ထပ်နှိပ်ပြီး နှစ်ဆင့်ခုန်ကြည့်ပါ။',
    TutorialStep.dodge => 'ဒီရန်သူကို ကန်လို့မရပါ။ ကျော်ခုန်ပါ။',
    TutorialStep.kick => 'ဒီရန်သူကို ကန်လို့ရပါတယ်။ မြေပြင်ပေါ်ကနေ ဝင်တိုက်ပါ။',
    TutorialStep.diamonds => 'စိန်တွေ အကုန်ကောက်ပါ။',
    TutorialStep.rocket => 'ဒုံးကျည်ခလုတ်ကို နှိပ်ပြီး ရန်သူကို ပစ်ပါ။',
    TutorialStep.shield => 'ဒိုင်းကို ကောက်ပါ။ ထိခိုက်မှုတစ်ခါ ကာပေးပါတယ်။',
    TutorialStep.done => 'လေ့ကျင့်ခန်း ပြီးပါပြီ။ ကစားဖို့ အသင့်ဖြစ်ပါပြီ။',
  };
  @override
  String get tutorialGreat => 'တော်လိုက်တာ!';
  @override
  String get tutorialTryAgain => 'မရသေးပါ၊ ထပ်ကြိုးစားပါ။';

  @override
  String get music => 'ဂီတ';
  @override
  String get effects => 'အသံ';
  @override
  String get enemyNames => 'ရန်သူအမည်များ';
  @override
  String get language => 'ဘာသာစကား';

  @override
  String get enemyNamesHint => 'အမည်မပြချင်ရင် အလွတ်ထားပါ။';
  @override
  String enemyLabel(String id) => switch (id) {
    'angry_pig' => 'ဝက်',
    'bat' => 'လင်းနို့',
    'gino' => 'ဆံပင်နီ',
    'chick' => 'ကြက်',
    'knight' => 'စစ်သူရဲ',
    'adventurer' => 'စွန့်စားသူ',
    'ninja_frog' => 'ဖားနင်ဂျာ',
    'mask_dude' => 'မျက်နှာဖုံးသူ',
    'pink_man' => 'ပန်းရောင်လူ',
    'virtual_guy' => 'အာကာသသား',
    'skeleton' => 'အရိုးစု',
    _ => id,
  };

  @override
  String get shop => 'ဈေးဆိုင်';
  @override
  String get upgrades => 'အဆင့်မြှင့်ရန်';
  @override
  String get skins => 'အသွင်များ';
  @override
  String upgradeName(UpgradeType type) => switch (type) {
    UpgradeType.rocketCapacity => 'ဒုံးကျည် ပမာဏ',
    UpgradeType.magnetDuration => 'သံလိုက် ကြာချိန်',
    UpgradeType.shieldStrength => 'ဒိုင်း ခံနိုင်ရည်',
    UpgradeType.dinoLife => 'ဒိုင်နိုဆော အသက်',
    UpgradeType.maxLives => 'အသက် အများဆုံး',
    UpgradeType.startShield => 'ဒိုင်းနဲ့ စမယ်',
    UpgradeType.batCarry => 'လင်းနို့ ချီချိန်',
  };
  @override
  String upgradeValue(UpgradeType type, num value) => switch (type) {
    UpgradeType.rocketCapacity => 'ဒုံးကျည် $value စင်း',
    UpgradeType.magnetDuration => '$value စက္ကန့်',
    UpgradeType.shieldStrength => 'ထိမှု $value ကြိမ်',
    UpgradeType.dinoLife => 'ရန်သူ $value ကောင်',
    UpgradeType.maxLives => 'အသက် $value ခု',
    UpgradeType.startShield => value > 0 ? 'ရှိ' : 'မရှိ',
    UpgradeType.batCarry => '$value စက္ကန့်',
  };
  @override
  String level(int level, int max) => 'အဆင့် $level/$max';
  @override
  String get maxed => 'အပြည့်';
  @override
  String get equip => 'သုံးမည်';
  @override
  String get equipped => 'သုံးနေသည်';
  @override
  String skinName(String id) => switch (id) {
    'crimson' => 'နီ',
    'ocean' => 'ပင်လယ်ပြာ',
    'forest' => 'တောစိမ်း',
    'gold' => 'ရွှေ',
    'shadow' => 'အရိပ်',
    _ => 'မူလ',
  };
  @override
  String get backgrounds => 'နောက်ခံများ';
  @override
  String get oneGameItems => 'တစ်ပွဲစာ ပစ္စည်း';
  @override
  String consumableName(Consumable type) => switch (type) {
    Consumable.startRockets => 'ဒုံးကျည် ၃ စင်းနဲ့ စမယ်',
    Consumable.doubleScore => 'အမှတ် ၂ ဆ (၃၀ စက္ကန့်)',
    Consumable.startBursts => 'Bomb ၂ ခါစာနဲ့ စမယ်',
  };
  @override
  String owned(int count) => 'ရှိပြီး $count ခု';
  @override
  String get usedNextGame => 'နောက်ပွဲ စတာနဲ့ သုံးမယ်';
  @override
  String cosmeticGroupName(CosmeticGroup group) => switch (group) {
    CosmeticGroup.music => 'နောက်ခံ သီချင်း',
    CosmeticGroup.shieldColor => 'ဒိုင်း အရောင်',
    CosmeticGroup.rocketStyle => 'ဒုံးကျည် အသွင်',
    CosmeticGroup.dinoColor => 'ဒိုင်နိုဆော အရောင်',
  };
  @override
  String cosmeticName(Cosmetic item) => switch (item.id) {
    '8bit' => '8-Bit',
    'superepic' => 'Super Epic',
    'blue' => 'ပြာ',
    'gold' => 'ရွှေ',
    'pink' => 'ပန်းရောင်',
    'purple' => 'ခရမ်း',
    'fireball' => 'မီးလုံး',
    'plasma' => 'ပလာစမာ',
    'missile' => 'ဒုံးပျံ',
    'yellow' => 'ဝါ',
    'green' => 'စိမ်း',
    'red' => 'နီ',
    _ => item.id,
  };
  @override
  String backgroundName(String id) => switch (id) {
    'jungle' => 'တောအုပ်',
    'lake' => 'ရေကန်',
    'night_forest' => 'ညတောအုပ်',
    'city' => 'မြို့',
    _ => 'ရေတံခွန်',
  };

  @override
  String get description =>
      'Angry Girl သည် ဆက်တိုက်ပြေးရသော ဂိမ်းဖြစ်ပါတယ်။ '
      'Screen ကိုနှိပ်ပြီး ရန်သူတွေကို ခုန်ကျော်ပါ၊ လေထဲမှာ ထပ်နှိပ်ရင် '
      'နောက်တစ်ဆင့် ထပ်ခုန်နိုင်ပါတယ်။ စစ်သူရဲတွေကို ဝင်တိုက်ပြီး အမှတ်ယူပါ။ '
      'အမှတ် ၂၀ တိုင်း ဒုံးကျည်တစ်စင်း ရပါမယ်။ စိန်တစ်လုံးကို ၁ မှတ် ရပါမယ်။ '
      'အမှတ် ၁၀၀ တိုင်း သံလိုက် (စိန်တွေကို ဆွဲယူ) သို့မဟုတ် ဒိုင်း '
      '(တစ်ကြိမ် ကာကွယ်) ပေါ်လာပါမယ်။ အသက် ၅ ခုပဲ ရှိလို့ သတိထားပါ!';
  @override
  String version(String version, String build) => 'ဗားရှင်း $version ($build)';
  @override
  String developedBy(String name) => 'ဖန်တီးသူ - $name';
}

class _English extends AppStrings {
  const _English();

  @override
  double get buttonFontSize => 30;
  @override
  double get menuFontSize => 24;
  @override
  bool get isMyanmar => false;

  @override
  String get play => 'Play';
  @override
  String get settings => 'Settings';
  @override
  String get about => 'About';
  @override
  String get exit => 'Exit';
  @override
  String get tutorial => 'Tutorial';

  @override
  String score(int score) => 'Score: $score';
  @override
  String highScore(int score) => 'High: $score';
  @override
  String get resume => 'Resume';
  @override
  String get restart => 'Restart';
  @override
  String get gameOver => 'Game Over';
  @override
  String get revive => 'Revive';
  @override
  String yourScore(int score) => 'Your Score: $score';

  @override
  String get guideJump =>
      'Tap the screen to jump. Tap again in the air to jump once more.';
  @override
  String get guideScore =>
      'Your score and high score. Kick enemies and collect diamonds '
      'for points.';
  @override
  String get guideDiamonds =>
      'Your diamonds. Spend them in the shop or to revive.';
  @override
  String get guidePause => 'Pauses the game.';
  @override
  String get guideLives =>
      'Your lives. An enemy takes a heart and a fireball takes half. '
      'The game is over when they are all gone.';
  @override
  String get guidePowerUps =>
      'Your power-ups show up here. A shield blocks hits, a magnet pulls '
      'in diamonds and x2 doubles your points.';
  @override
  String guideRockets(int scorePerRocket) =>
      'You get a rocket every $scorePerRocket points. The ring shows how '
      'close the next one is. Tap to fire at enemies you can\'t kick.';
  @override
  String guideBurst(int scorePerBurst) =>
      'You get a burst every $scorePerBurst points. Tap to drop a bomb on '
      'each of the 2 nearest enemies in front of you. Bombs defeat any enemy.';
  @override
  String get guideNext => 'Next';
  @override
  String get guideSkip => 'Skip';
  @override
  String get guideDone => 'Play';

  @override
  String tutorialStep(TutorialStep step) => switch (step) {
    TutorialStep.jump => 'Tap the screen to jump.',
    TutorialStep.doubleJump => 'Tap again in the air to jump twice.',
    TutorialStep.dodge => 'This enemy can\'t be kicked. Jump over it!',
    TutorialStep.kick => 'This enemy can be kicked. Run into it on the ground!',
    TutorialStep.diamonds => 'Collect all the diamonds.',
    TutorialStep.rocket => 'Tap the rocket button to fire at the enemy.',
    TutorialStep.shield => 'Pick up the shield. It blocks one hit.',
    TutorialStep.done => 'Tutorial complete! You are ready to play.',
  };
  @override
  String get tutorialGreat => 'Great!';
  @override
  String get tutorialTryAgain => 'Missed it, try again.';

  @override
  String get music => 'Music';
  @override
  String get effects => 'Effects';
  @override
  String get enemyNames => 'Enemy Names';
  @override
  String get language => 'Language';

  @override
  String get enemyNamesHint => 'Leave a name empty to hide it.';
  @override
  String enemyLabel(String id) => switch (id) {
    'angry_pig' => 'Pig',
    'bat' => 'Bat',
    'gino' => 'Red Hair',
    'chick' => 'Chicken',
    'knight' => 'Knight',
    'adventurer' => 'Adventurer',
    'ninja_frog' => 'Ninja Frog',
    'mask_dude' => 'Mask Dude',
    'pink_man' => 'Pink Man',
    'virtual_guy' => 'Virtual Guy',
    'skeleton' => 'Skeleton',
    _ => id,
  };

  @override
  String get shop => 'Shop';
  @override
  String get upgrades => 'Upgrades';
  @override
  String get skins => 'Skins';
  @override
  String upgradeName(UpgradeType type) => switch (type) {
    UpgradeType.rocketCapacity => 'Rocket Capacity',
    UpgradeType.magnetDuration => 'Magnet Duration',
    UpgradeType.shieldStrength => 'Shield Strength',
    UpgradeType.dinoLife => 'Dino Life',
    UpgradeType.maxLives => 'Max Lives',
    UpgradeType.startShield => 'Start with Shield',
    UpgradeType.batCarry => 'Bat Carry Time',
  };
  @override
  String upgradeValue(UpgradeType type, num value) => switch (type) {
    UpgradeType.rocketCapacity => '$value rockets',
    UpgradeType.magnetDuration => '${value}s',
    UpgradeType.shieldStrength => '$value hits',
    UpgradeType.dinoLife => '$value enemies',
    UpgradeType.maxLives => '$value lives',
    UpgradeType.startShield => value > 0 ? 'On' : 'Off',
    UpgradeType.batCarry => '${value}s',
  };
  @override
  String level(int level, int max) => 'Level $level/$max';
  @override
  String get maxed => 'MAX';
  @override
  String get equip => 'Use';
  @override
  String get equipped => 'In use';
  @override
  String skinName(String id) => switch (id) {
    'crimson' => 'Crimson',
    'ocean' => 'Ocean',
    'forest' => 'Forest',
    'gold' => 'Gold',
    'shadow' => 'Shadow',
    _ => 'Classic',
  };
  @override
  String get backgrounds => 'Backgrounds';
  @override
  String get oneGameItems => 'One-game Items';
  @override
  String consumableName(Consumable type) => switch (type) {
    Consumable.startRockets => 'Start with 3 Rockets',
    Consumable.doubleScore => 'Double Score (30s)',
    Consumable.startBursts => 'Start with 2 Bursts',
  };
  @override
  String owned(int count) => 'Owned: $count';
  @override
  String get usedNextGame => 'Used when the next game starts';
  @override
  String cosmeticGroupName(CosmeticGroup group) => switch (group) {
    CosmeticGroup.music => 'Music',
    CosmeticGroup.shieldColor => 'Shield Colour',
    CosmeticGroup.rocketStyle => 'Rocket Look',
    CosmeticGroup.dinoColor => 'Dino Colour',
  };
  @override
  String cosmeticName(Cosmetic item) => switch (item.id) {
    '8bit' => '8-Bit',
    'superepic' => 'Super Epic',
    'blue' => 'Blue',
    'gold' => 'Gold',
    'pink' => 'Pink',
    'purple' => 'Purple',
    'fireball' => 'Fireball',
    'plasma' => 'Plasma',
    'missile' => 'Missile',
    'yellow' => 'Yellow',
    'green' => 'Green',
    'red' => 'Red',
    _ => item.id,
  };
  @override
  String backgroundName(String id) => switch (id) {
    'jungle' => 'Jungle',
    'lake' => 'Lake',
    'night_forest' => 'Night Forest',
    'city' => 'City',
    _ => 'Waterfall',
  };

  @override
  String get description =>
      'Angry Girl is an endless runner. Tap the screen to jump over '
      'enemies, and tap again in the air to double jump. Run into the '
      'knights and warriors to knock them down for points. Every 20 points '
      'earns a rocket, and every diamond is worth 1 point. Every 100 points a '
      'power-up appears: a magnet pulls in diamonds, and a shield blocks one '
      'hit. You have 5 lives, so watch out!';
  @override
  String version(String version, String build) => 'Version $version ($build)';
  @override
  String developedBy(String name) => 'Developed by $name';
}
