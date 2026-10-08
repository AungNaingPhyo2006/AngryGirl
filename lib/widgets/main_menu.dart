import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/widgets/hud.dart';
import '/widgets/menu_text.dart';
import '/models/app_strings.dart';
import '../game/ninja_run.dart';
import '/widgets/settings_menu.dart';
import '/widgets/shop_menu.dart';

// This represents the main menu overlay.
class MainMenu extends StatelessWidget {
  // An unique identified for this overlay.
  // MainMenu.id ဆိုတာ overlay ထဲမှာအသုံးပြုဖို့ unique identifier ပါ။
  static const id = 'MainMenu';

  // Reference to parent game.
  //game ဆိုတာ parent game (NinjaRun) ကို reference လုပ်ထားတာဖြစ်ပြီး MainMenu မှ game logic တွေကို access လုပ်ဖို့လိုတယ်။
  final NinjaRun game;

  const MainMenu(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    final s = game.settings.strings;
    return Center(
      // BackdropFilter: နောက်က blur effect ဖြစ်အောင်လုပ်တယ်။ sigmaX နဲ့ sigmaY က blur level တွေ။
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
                vertical: 16,
                horizontal: 100,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Angry Girl',
                    style: TextStyle(fontSize: 36, color: Colors.white),
                  ),
                  for (final button in [
                    _button(s.play, s, () {
                      game.overlays.remove(
                        MainMenu.id,
                      ); // MainMenu overlay ဖျက်
                      game.overlays.add(
                        Hud.id,
                      ); //HUD overlay (score, life, etc) ပြပါ
                      // Started after the hud is added, so that the hud
                      // guide of a new player is drawn above it.
                      game.startGamePlay(); // game logic စတင်
                    }),
                    // Stands out until a new player has finished it.
                    _button(
                      s.tutorial,
                      s,
                      highlight: !game.settings.tutorialDone,
                      () {
                        game.overlays.remove(MainMenu.id);
                        game.overlays.add(Hud.id);
                        game.startTutorial();
                      },
                    ),
                    _button(s.shop, s, () {
                      game.overlays.remove(MainMenu.id);
                      game.overlays.add(ShopMenu.id);
                    }),
                    _button(s.settings, s, () {
                      game.overlays.remove(MainMenu.id);
                      game.overlays.add(SettingsMenu.id);
                    }),
                    _button(s.exit, s, () {
                      SystemNavigator.pop(); // Exit the app
                    }),
                  ]) ...[const SizedBox(height: _gap), button],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Space above each button.
  static const _gap = 10.0;

  Widget _button(
    String text,
    AppStrings s,
    VoidCallback onPressed, {
    bool highlight = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: highlight
          ? ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            )
          : null,
      child: MenuText(text, fontSize: s.buttonFontSize, isMyanmar: s.isMyanmar),
    );
  }
}
