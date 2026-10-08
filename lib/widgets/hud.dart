import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game/ninja_run.dart';
import '/game/audio_manager.dart';
import '/models/player_data.dart';
import '/game/collectibles.dart';
import '/game/tutorial.dart';
import '/models/tutorial_step.dart';
import '/widgets/main_menu.dart';
import '/widgets/menu_text.dart';
import '/widgets/pause_menu.dart';

// This represents the head up display in game.
// It consists of, current score, high score,
// a pause button and number of remaining lives.
class Hud extends StatelessWidget {
  // An unique identified for this overlay.
  static const id = 'Hud';

  // Keys of the parts explained by the hud guide.
  static final scoreKey = GlobalKey();
  static final diamondsKey = GlobalKey();
  static final pauseKey = GlobalKey();
  static final livesKey = GlobalKey();
  static final powerUpsKey = GlobalKey();
  static final fireKey = GlobalKey();
  static final burstKey = GlobalKey();

  // Reference to parent game.
  final NinjaRun game;

  const Hud(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    final s = game.settings.strings;
    return ChangeNotifierProvider.value(
      value: game.playerData,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Column(
                      key: scoreKey,
                      children: [
                        Selector<PlayerData, int>(
                          selector: (_, playerData) => playerData.currentScore,
                          builder: (_, score, __) {
                            return Text(
                              s.score(score),
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                        Selector<PlayerData, int>(
                          selector: (_, playerData) => playerData.highScore,
                          builder: (_, highScore, __) {
                            return Text(
                              s.highScore(highScore),
                              style: const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ],
                    ),
                    // Collected diamonds.
                    Selector<PlayerData, int>(
                      key: diamondsKey,
                      selector: (_, playerData) => playerData.diamonds,
                      builder: (_, diamonds, __) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.diamond,
                            color: Color(0xFF4DD0E1),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$diamonds',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                TextButton(
                  key: pauseKey,
                  onPressed: () {
                    game.overlays.remove(Hud.id);
                    game.overlays.add(PauseMenu.id);
                    game.pauseEngine();
                    AudioManager.instance.pauseBgm();
                  },
                  child: const Icon(Icons.pause, color: Colors.white),
                ),
                Selector<PlayerData, (double, int)>(
                  key: livesKey,
                  selector: (_, playerData) =>
                      (playerData.lives, playerData.maxLives),
                  builder: (_, data, __) {
                    final (lives, maxLives) = data;
                    return Row(
                      children: List.generate(
                        maxLives,
                        (index) => _Heart(fill: (lives - index).clamp(0, 1)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Active power-ups.
          Positioned(
            left: 56,
            bottom: 16,
            child: Selector<PlayerData, (int, int, int, int)>(
              key: powerUpsKey,
              selector: (_, playerData) => (
                playerData.shieldCharges,
                playerData.magnetTime.ceil(),
                playerData.doubleScoreTime.ceil(),
                playerData.carryTime.ceil(),
              ),
              builder: (_, data, __) => Row(
                children: [
                  // With the shield upgrade, it shows the hits it can block.
                  if (data.$1 > 0)
                    _PowerUpChip(
                      icon: _powerUpImage(PowerUpType.shield),
                      count: data.$1 > 1 ? data.$1 : null,
                    ),
                  if (data.$2 > 0)
                    _PowerUpChip(
                      icon: _powerUpImage(PowerUpType.magnet),
                      seconds: data.$2,
                    ),
                  // Double score bought in the shop.
                  if (data.$3 > 0)
                    _PowerUpChip(
                      icon: const Text(
                        'x2',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      seconds: data.$3,
                    ),
                  // Carried by the helper bat.
                  if (data.$4 > 0)
                    _PowerUpChip(icon: _batImage(), seconds: data.$4),
                ],
              ),
            ),
          ),
          Positioned(
            right: 56,
            bottom: 16,
            child: Selector<PlayerData, (int, int, int)>(
              key: fireKey,
              selector: (_, playerData) => (
                playerData.rockets,
                playerData.maxRockets,
                playerData.currentScore,
              ),
              builder: (_, data, __) => _ChargeButton(
                icon: Icons.rocket_launch,
                count: data.$1,
                maxCount: data.$2,
                score: data.$3,
                scorePerCharge: PlayerData.scorePerRocket,
                onPressed: game.fireRocket,
              ),
            ),
          ),
          // Burst button, on the left of the fire button.
          Positioned(
            right: 56 + _ChargeButton.size + 16,
            bottom: 16,
            child: Selector<PlayerData, (int, int)>(
              key: burstKey,
              selector: (_, playerData) =>
                  (playerData.bursts, playerData.currentScore),
              builder: (_, data, __) => _ChargeButton(
                icon: Icons.local_fire_department,
                count: data.$1,
                maxCount: PlayerData.maxBursts,
                score: data.$2,
                scorePerCharge: PlayerData.scorePerBurst,
                onPressed: game.dropBombs,
              ),
            ),
          ),
          // What to do next in the tutorial.
          if (game.tutorial case final tutorial?)
            Positioned(
              top: 64,
              left: 16,
              right: 16,
              child: Center(child: _TutorialBanner(game, tutorial)),
            ),
        ],
      ),
    );
  }
}

// Shows the instruction of the current tutorial step, and how the
// player did. Once the tutorial is over, it offers to play a real game.
class _TutorialBanner extends StatelessWidget {
  final NinjaRun game;
  final TutorialManager tutorial;

  const _TutorialBanner(this.game, this.tutorial);

  @override
  Widget build(BuildContext context) {
    final s = game.settings.strings;
    return ValueListenableBuilder(
      valueListenable: tutorial.state,
      builder: (_, state, __) {
        final (step, feedback) = state;
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(90),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withAlpha(90)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    s.tutorialStep(step),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  if (feedback != TutorialFeedback.none)
                    Text(
                      feedback == TutorialFeedback.great
                          ? s.tutorialGreat
                          : s.tutorialTryAgain,
                      style: TextStyle(
                        fontSize: 16,
                        color: feedback == TutorialFeedback.great
                            ? Colors.greenAccent
                            : Colors.orangeAccent,
                      ),
                    ),
                  if (step == TutorialStep.done)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          _button(s.play, s.buttonFontSize, s.isMyanmar, () {
                            // Added again, so that the banner is gone.
                            game.overlays.remove(Hud.id);
                            game.overlays.add(Hud.id);
                            game.reset();
                            game.startGamePlay();
                          }),
                          _button(s.exit, s.buttonFontSize, s.isMyanmar, () {
                            game.overlays.remove(Hud.id);
                            game.overlays.add(MainMenu.id);
                            game.reset();
                          }),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _button(
    String text,
    double fontSize,
    bool isMyanmar,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(fixedSize: const Size(140, 44)),
      child: MenuText(text, fontSize: fontSize * 0.8, isMyanmar: isMyanmar),
    );
  }
}

// Fire or burst button with a frosted glass background, showing the
// number of charges (rockets or bursts) the player has. A charge is
// earned every [scorePerCharge] points.
class _ChargeButton extends StatelessWidget {
  static const size = 72.0;

  final IconData icon;
  final int count;
  final int maxCount;
  final int score;
  final int scorePerCharge;
  final VoidCallback onPressed;

  const _ChargeButton({
    required this.icon,
    required this.count,
    required this.maxCount,
    required this.score,
    required this.scorePerCharge,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = count > 0;

    // Progress towards the next charge, shown along the border.
    // It stays full once the maximum number of charges is held.
    final full = count >= maxCount;
    final progress = full ? 1.0 : (score % scorePerCharge) / scorePerCharge;

    return Stack(
      children: [
        _button(enabled),
        Positioned.fill(
          child: IgnorePointer(
            // A new key for every charge earned, so that the progress
            // starts again from empty instead of running backwards.
            child: TweenAnimationBuilder<double>(
              key: ValueKey(full ? -1 : score ~/ scorePerCharge),
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              builder: (_, value, __) => CustomPaint(
                painter: _ProgressRingPainter(
                  progress: value,
                  color: full ? Colors.greenAccent : Colors.amber,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _button(bool enabled) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Material(
            color: Colors.white.withAlpha(40),
            shape: CircleBorder(
              side: BorderSide(color: Colors.white.withAlpha(90)),
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: enabled ? onPressed : null,
              child: SizedBox(
                width: size,
                height: size,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 28),
                    Text(
                      '$count / $maxCount',
                      style: const TextStyle(color: Colors.white),
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
}

// Draws [progress] (0 to 1) of a ring around a round button,
// clockwise from the top.
class _ProgressRingPainter extends CustomPainter {
  static const _strokeWidth = 3.0;

  final double progress;
  final Color color;

  _ProgressRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) {
      return;
    }

    // Keep the stroke inside the button.
    final ring = Rect.fromLTWH(
      0,
      0,
      size.width,
      size.height,
    ).deflate(_strokeWidth / 2);
    canvas.drawArc(
      ring,
      -pi / 2,
      2 * pi * progress.clamp(0, 1),
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter old) =>
      old.progress != progress || old.color != color;
}

// A small glass chip showing an active power-up,
// and the seconds left for timed ones.
class _PowerUpChip extends StatelessWidget {
  final Widget icon;
  final int? seconds;
  final int? count;

  const _PowerUpChip({required this.icon, this.seconds, this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withAlpha(90)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                if (seconds != null || count != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(
                      seconds != null ? '${seconds}s' : 'x$count',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// A life heart, which is full, half full or empty for [fill] 1, 0.5 or 0.
class _Heart extends StatelessWidget {
  final double fill;

  const _Heart({required this.fill});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Icon(Icons.favorite_border, color: Colors.red),
        ClipRect(
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: fill,
            // Without this, Align takes all the height it is allowed.
            heightFactor: 1,
            child: const Icon(Icons.favorite, color: Colors.red),
          ),
        ),
      ],
    );
  }
}

// The first frame of the bat sheet, which has 7 frames of 46x30.
Widget _batImage() => SizedBox(
  width: 34,
  height: 22,
  child: ClipRect(
    child: OverflowBox(
      maxWidth: double.infinity,
      alignment: Alignment.centerLeft,
      child: Image.asset(
        'assets/images/Bat/Flying (46x30).png',
        height: 22,
        fit: BoxFit.fitHeight,
      ),
    ),
  ),
);

Widget _powerUpImage(PowerUpType type) => Image.asset(
  'assets/images/${PowerUpItem.image(type)}',
  width: 22,
  height: 22,
);
