import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/widgets/hud.dart';
import '../game/ninja_run.dart';
import '/widgets/menu_text.dart';
import '/widgets/main_menu.dart';
import '/models/player_data.dart';
import '/game/audio_manager.dart';

// This represents the game over overlay,
// displayed with ninja runs out of lives.
class GameOverMenu extends StatelessWidget {
  // An unique identified for this overlay.
  static const id = 'GameOverMenu';

  // Reference to parent game.
  final NinjaRun game;

  const GameOverMenu(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    final s = game.settings.strings;
    return ChangeNotifierProvider.value(
      value: game.playerData,
      child: Center(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: Colors.black.withAlpha(100),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 100,
                ),
                child: Wrap(
                  direction: Axis.vertical,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  children: [
                    Text(
                      s.gameOver,
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    ),
                    Selector<PlayerData, int>(
                      selector: (_, playerData) => playerData.currentScore,
                      builder: (_, score, __) {
                        return Text(
                          s.yourScore(score),
                          style: const TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                    // Pay diamonds to keep playing with one life.
                    Consumer<PlayerData>(
                      builder: (_, playerData, __) {
                        final cost = playerData.reviveCost;
                        return ElevatedButton(
                          onPressed: playerData.diamonds >= cost
                              ? game.revive
                              : null,
                          // The default disabled colours can't be
                          // seen on the dark card.
                          style: ElevatedButton.styleFrom(
                            disabledBackgroundColor: Colors.white24,
                            disabledForegroundColor: Colors.white54,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              MenuText(
                                s.revive,
                                fontSize: s.buttonFontSize,
                                isMyanmar: s.isMyanmar,
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.diamond,
                                color: Color(0xFF4DD0E1),
                                size: 20,
                              ),
                              Text(
                                '$cost',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    ElevatedButton(
                      child: MenuText(
                        s.restart,
                        fontSize: s.buttonFontSize,
                        isMyanmar: s.isMyanmar,
                      ),
                      onPressed: () {
                        game.overlays.remove(GameOverMenu.id);
                        game.overlays.add(Hud.id);
                        game.resumeEngine();
                        game.reset();
                        game.startGamePlay();
                        AudioManager.instance.resumeBgm();
                      },
                    ),
                    ElevatedButton(
                      child: MenuText(
                        s.exit,
                        fontSize: s.buttonFontSize,
                        isMyanmar: s.isMyanmar,
                      ),
                      onPressed: () {
                        game.overlays.remove(GameOverMenu.id);
                        game.overlays.add(MainMenu.id);
                        game.resumeEngine();
                        game.reset();
                        AudioManager.instance.resumeBgm();
                      },
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
