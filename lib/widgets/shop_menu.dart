import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game/ninja_run.dart';
import '/game/audio_manager.dart';
import '/models/app_strings.dart';
import '/models/player_data.dart';
import '/models/shop.dart';
import '/widgets/main_menu.dart';
import '/widgets/menu_text.dart';

// The shop, where diamonds are spent on upgrades and character skins.
class ShopMenu extends StatelessWidget {
  // An unique identified for this overlay.
  static const id = 'ShopMenu';

  // Reference to parent game.
  final NinjaRun game;

  const ShopMenu(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    final s = game.settings.strings;

    return ChangeNotifierProvider.value(
      value: game.playerData,
      child: Consumer<PlayerData>(
        builder: (context, playerData, _) => Center(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.height * 0.85,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.black.withAlpha(140),
                child: Column(
                  children: [
                    _header(s, playerData),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                        children: [
                          _sectionTitle(s.upgrades),
                          for (final upgrade in Upgrade.all)
                            _UpgradeRow(upgrade, playerData, s, game),
                          const SizedBox(height: 8),
                          _sectionTitle(s.oneGameItems),
                          for (final item in ConsumableItem.all)
                            _ConsumableRow(item, playerData, s, game),
                          const SizedBox(height: 8),
                          _sectionTitle(s.skins),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              for (final skin in Skin.all)
                                _SkinTile(skin, playerData, s, game),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _sectionTitle(s.backgrounds),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              for (final background in Background.all)
                                _BackgroundTile(
                                  background,
                                  playerData,
                                  s,
                                  game,
                                ),
                            ],
                          ),
                          for (final group in CosmeticGroup.values) ...[
                            const SizedBox(height: 8),
                            _sectionTitle(s.cosmeticGroupName(group)),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                for (final item in Cosmetic.inGroup(group))
                                  _CosmeticTile(item, playerData, s, game),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(AppStrings s, PlayerData playerData) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 24, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              game.overlays.remove(ShopMenu.id);
              game.overlays.add(MainMenu.id);
            },
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          ),
          Text(
            s.shop,
            style: const TextStyle(fontSize: 24, color: Colors.white),
          ),
          const Spacer(),
          _DiamondPrice(playerData.diamonds, fontSize: 20, color: Colors.white),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, color: Colors.white70),
      ),
    );
  }
}

// Icon and number of diamonds.
class _DiamondPrice extends StatelessWidget {
  final int amount;
  final double fontSize;

  // Uses the colour of the button or text around it when not given.
  final Color? color;

  const _DiamondPrice(this.amount, {this.fontSize = 14, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.diamond, color: const Color(0xFF4DD0E1), size: fontSize),
        const SizedBox(width: 4),
        Text(
          '$amount',
          style: TextStyle(fontSize: fontSize, color: color),
        ),
      ],
    );
  }
}

// Text of a shop button, kept in the centre of the button.
Widget _buttonText(String text, AppStrings s) =>
    MenuText(text, fontSize: 14, isMyanmar: s.isMyanmar);

// Small button used in the shop, as the menu buttons are much bigger.
ButtonStyle _shopButtonStyle() => FilledButton.styleFrom(
  minimumSize: const Size(96, 34),
  padding: const EdgeInsets.symmetric(horizontal: 12),
  backgroundColor: Colors.white,
  foregroundColor: Colors.black,
  disabledBackgroundColor: Colors.white24,
  disabledForegroundColor: Colors.white54,
);

// Icon of an upgrade, made of the picture of what it improves.
// Upgrades which take effect at the start have a start badge.
Widget _upgradeIcon(UpgradeType type, NinjaRun game) => switch (type) {
  UpgradeType.rocketCapacity => _ShopIcon(
    color: Colors.amber,
    badge: const Icon(Icons.add, size: 12, color: Colors.white),
    child: Image.asset('assets/images/power_ups/missile.png'),
  ),
  UpgradeType.magnetDuration => _ShopIcon(
    color: Colors.redAccent,
    badge: const Icon(Icons.timer, size: 11, color: Colors.white),
    child: Image.asset('assets/images/power_ups/magnet.png'),
  ),
  UpgradeType.shieldStrength => _ShopIcon(
    color: Colors.lightBlueAccent,
    badge: const Icon(Icons.add, size: 12, color: Colors.white),
    child: Image.asset('assets/images/power_ups/shield.png'),
  ),
  UpgradeType.dinoLife => _ShopIcon(
    color: Colors.greenAccent,
    child: _dinoSprite(game),
  ),
  UpgradeType.maxLives => const _ShopIcon(
    color: Colors.red,
    child: Icon(Icons.favorite, color: Colors.red, size: 24),
  ),
  UpgradeType.startShield => _ShopIcon(
    color: Colors.lightBlueAccent,
    badge: const Icon(Icons.play_arrow, size: 12, color: Colors.white),
    child: Image.asset('assets/images/power_ups/shield.png'),
  ),
  UpgradeType.batCarry => _ShopIcon(
    color: Colors.purpleAccent,
    badge: const Icon(Icons.timer, size: 11, color: Colors.white),
    child: _batSprite(game),
  ),
};

// Icon of a one-game item. Items which give a number of
// something at the start show that number as a badge.
Widget _consumableIcon(Consumable type, NinjaRun game) => switch (type) {
  Consumable.startRockets => _ShopIcon(
    color: Colors.amber,
    badge: _badgeText('${ConsumableItem.startRocketCount}'),
    child: Image.asset('assets/images/power_ups/missile.png'),
  ),
  Consumable.doubleScore => const _ShopIcon(
    color: Colors.amber,
    child: Text(
      'x2',
      style: TextStyle(
        fontSize: 16,
        color: Colors.amber,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  Consumable.startBursts => _ShopIcon(
    color: Colors.deepOrangeAccent,
    badge: _badgeText('${ConsumableItem.startBurstCount}'),
    child: const Icon(
      Icons.local_fire_department,
      color: Colors.deepOrangeAccent,
      size: 24,
    ),
  ),
};

Widget _badgeText(String text) => Text(
  text,
  style: const TextStyle(
    fontSize: 10,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  ),
);

// The first run frame of the helper dino.
Widget _dinoSprite(NinjaRun game) => SpriteWidget(
  sprite: Sprite(
    game.images.fromCache('DinoSprites - tard.png'),
    srcPosition: Vector2(4 * 24, 0),
    srcSize: Vector2.all(24),
  ),
);

// The first frame of the helper bat, facing right like when it carries.
Widget _batSprite(NinjaRun game) => Transform.flip(
  flipX: true,
  child: SpriteWidget(
    sprite: Sprite(
      game.images.fromCache('Bat/Flying (46x30).png'),
      srcSize: Vector2(46, 30),
    ),
  ),
);

// A round glass icon tinted with [color], with an optional
// small [badge] at its bottom right corner.
class _ShopIcon extends StatelessWidget {
  static const _size = 40.0;
  static const _badgeSize = 16.0;

  final Color color;
  final Widget child;
  final Widget? badge;

  const _ShopIcon({required this.color, required this.child, this.badge});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: _size,
            height: _size,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withAlpha(45),
              border: Border.all(color: color.withAlpha(150)),
            ),
            child: FittedBox(child: child),
          ),
          if (badge != null)
            Positioned(
              right: -3,
              bottom: -3,
              child: Container(
                width: _badgeSize,
                height: _badgeSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.lerp(color, Colors.black, 0.35),
                  border: Border.all(color: Colors.white70, width: 1),
                ),
                child: badge,
              ),
            ),
        ],
      ),
    );
  }
}

class _UpgradeRow extends StatelessWidget {
  final Upgrade upgrade;
  final PlayerData playerData;
  final AppStrings s;
  final NinjaRun game;

  const _UpgradeRow(this.upgrade, this.playerData, this.s, this.game);

  // Value of the upgrade's effect when it is at the given level.
  num _value(int level) => switch (upgrade.type) {
    UpgradeType.rocketCapacity => PlayerData.baseMaxRockets + level,
    UpgradeType.magnetDuration =>
      (PlayerData.baseMagnetDuration + PlayerData.magnetSecondsPerLevel * level)
          .round(),
    UpgradeType.shieldStrength => 1 + level,
    UpgradeType.dinoLife => PlayerData.baseDinoLife + level,
    UpgradeType.maxLives => PlayerData.baseMaxLives + level,
    UpgradeType.startShield => level,
    UpgradeType.batCarry =>
      (PlayerData.baseCarryDuration + PlayerData.carrySecondsPerLevel * level)
          .round(),
  };

  @override
  Widget build(BuildContext context) {
    final level = playerData.upgradeLevel(upgrade.type);
    final maxed = level >= upgrade.maxLevel;
    final cost = maxed ? 0 : upgrade.costs[level];

    // Current effect, and the effect after buying the next level.
    final effect = maxed
        ? s.upgradeValue(upgrade.type, _value(level))
        : '${s.upgradeValue(upgrade.type, _value(level))} → '
              '${s.upgradeValue(upgrade.type, _value(level + 1))}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          _upgradeIcon(upgrade.type, game),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.upgradeName(upgrade.type),
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  '${s.level(level, upgrade.maxLevel)} · $effect',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          FilledButton(
            style: _shopButtonStyle(),
            onPressed: maxed || playerData.diamonds < cost
                ? null
                : () => playerData.buyUpgrade(upgrade.type),
            child: maxed ? _buttonText(s.maxed, s) : _DiamondPrice(cost),
          ),
        ],
      ),
    );
  }
}

class _SkinTile extends StatelessWidget {
  final Skin skin;
  final PlayerData playerData;
  final AppStrings s;
  final NinjaRun game;

  const _SkinTile(this.skin, this.playerData, this.s, this.game);

  @override
  Widget build(BuildContext context) {
    final owned = playerData.ownsSkin(skin.id);
    final inUse = playerData.skin.id == skin.id;

    final Widget label;
    final VoidCallback? onPressed;
    if (inUse) {
      label = _buttonText(s.equipped, s);
      onPressed = null;
    } else if (owned) {
      label = _buttonText(s.equip, s);
      onPressed = () => playerData.selectSkin(skin.id);
    } else {
      label = _DiamondPrice(skin.price);
      onPressed = playerData.diamonds < skin.price
          ? null
          : () => playerData.buySkin(skin.id);
    }

    // First frame of the run animation, recoloured with this skin.
    final preview = SpriteWidget(
      sprite: Sprite(
        game.images.fromCache('run-player.png'),
        srcPosition: Vector2.zero(),
        srcSize: Vector2(64, 44),
      ),
    );

    return Container(
      width: 112,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(inUse ? 50 : 20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: inUse ? Colors.amber : Colors.white.withAlpha(60),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 48,
            child: skin.colorFilter == null
                ? preview
                : ColorFiltered(colorFilter: skin.colorFilter!, child: preview),
          ),
          Text(
            s.skinName(skin.id),
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
          const SizedBox(height: 4),
          FilledButton(
            style: _shopButtonStyle(),
            onPressed: onPressed,
            child: label,
          ),
        ],
      ),
    );
  }
}

class _BackgroundTile extends StatelessWidget {
  final Background background;
  final PlayerData playerData;
  final AppStrings s;
  final NinjaRun game;

  const _BackgroundTile(this.background, this.playerData, this.s, this.game);

  @override
  Widget build(BuildContext context) {
    final owned = playerData.ownsBackground(background.id);
    final inUse = playerData.background.id == background.id;

    final Widget label;
    final VoidCallback? onPressed;
    if (inUse) {
      label = _buttonText(s.equipped, s);
      onPressed = null;
    } else if (owned) {
      label = _buttonText(s.equip, s);
      onPressed = () {
        playerData.selectBackground(background.id);
        game.applyBackground();
      };
    } else {
      label = _DiamondPrice(background.price);
      onPressed = playerData.diamonds < background.price
          ? null
          : () {
              if (playerData.buyBackground(background.id)) {
                game.applyBackground();
              }
            };
    }

    return Container(
      width: 152,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(inUse ? 50 : 20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: inUse ? Colors.amber : Colors.white.withAlpha(60),
        ),
      ),
      child: Column(
        children: [
          // All the layers on top of each other, as in the game.
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 136,
              height: 76,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  for (final layer in background.layers)
                    Image.asset(
                      'assets/images/$layer',
                      fit: BoxFit.cover,
                      alignment: Alignment.bottomLeft,
                      filterQuality: FilterQuality.none,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            s.backgroundName(background.id),
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
          const SizedBox(height: 4),
          FilledButton(
            style: _shopButtonStyle(),
            onPressed: onPressed,
            child: label,
          ),
        ],
      ),
    );
  }
}

class _ConsumableRow extends StatelessWidget {
  final ConsumableItem item;
  final PlayerData playerData;
  final AppStrings s;
  final NinjaRun game;

  const _ConsumableRow(this.item, this.playerData, this.s, this.game);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          _consumableIcon(item.type, game),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.consumableName(item.type),
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  '${s.owned(playerData.consumableCount(item.type))} · '
                  '${s.usedNextGame}',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          FilledButton(
            style: _shopButtonStyle(),
            onPressed: playerData.diamonds < item.price
                ? null
                : () => playerData.buyConsumable(item),
            child: _DiamondPrice(item.price),
          ),
        ],
      ),
    );
  }
}

class _CosmeticTile extends StatelessWidget {
  final Cosmetic item;
  final PlayerData playerData;
  final AppStrings s;
  final NinjaRun game;

  const _CosmeticTile(this.item, this.playerData, this.s, this.game);

  // Starts the newly chosen music right away.
  void _changed() {
    if (item.group == CosmeticGroup.music && game.settings.bgm) {
      AudioManager.instance.stopBgm();
      game.startMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    final owned = playerData.ownsCosmetic(item);
    final inUse = playerData.cosmetic(item.group).id == item.id;

    final Widget label;
    final VoidCallback? onPressed;
    if (inUse) {
      label = _buttonText(s.equipped, s);
      onPressed = null;
    } else if (owned) {
      label = _buttonText(s.equip, s);
      onPressed = () {
        playerData.selectCosmetic(item);
        _changed();
      };
    } else {
      label = _DiamondPrice(item.price);
      onPressed = playerData.diamonds < item.price
          ? null
          : () {
              if (playerData.buyCosmetic(item)) {
                _changed();
              }
            };
    }

    return Container(
      width: 112,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(inUse ? 50 : 20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: inUse ? Colors.amber : Colors.white.withAlpha(60),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 48, child: Center(child: _preview())),
          Text(
            s.cosmeticName(item),
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
          const SizedBox(height: 4),
          FilledButton(
            style: _shopButtonStyle(),
            onPressed: onPressed,
            child: label,
          ),
        ],
      ),
    );
  }

  Widget _preview() {
    switch (item.group) {
      case CosmeticGroup.music:
        return const Icon(Icons.music_note, color: Colors.white, size: 36);
      case CosmeticGroup.shieldColor:
        // A small glass ball, like the shield in the game.
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withAlpha(150)),
            gradient: RadialGradient(
              center: const Alignment(-0.3, -0.3),
              colors: [
                Colors.white.withAlpha(30),
                item.color!.withAlpha(0x50),
                item.color!.withAlpha(0xC0),
              ],
              stops: const [0, 0.65, 1],
            ),
          ),
        );
      case CosmeticGroup.rocketStyle:
        if (item.id == 'missile') {
          return Transform.rotate(
            angle: pi / 4,
            child: Image.asset(
              'assets/images/power_ups/missile.png',
              width: 36,
            ),
          );
        }
        return _filtered(
          SpriteWidget(
            sprite: Sprite(
              game.images.fromCache('bullet/Move.png'),
              srcPosition: Vector2.zero(),
              srcSize: Vector2.all(46),
            ),
          ),
        );
      case CosmeticGroup.dinoColor:
        // The first run frame of the dino.
        return _filtered(
          SpriteWidget(
            sprite: Sprite(
              game.images.fromCache('DinoSprites - tard.png'),
              srcPosition: Vector2(4 * 24, 0),
              srcSize: Vector2.all(24),
            ),
          ),
        );
    }
  }

  Widget _filtered(Widget child) {
    final filter = item.hueFilter;
    return filter == null
        ? child
        : ColorFiltered(colorFilter: filter, child: child);
  }
}
