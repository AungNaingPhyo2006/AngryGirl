import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game/ninja_run.dart';
import '/models/settings.dart';
import '/models/app_strings.dart';
import '/widgets/menu_text.dart';
import '/widgets/main_menu.dart';
import '/widgets/enemy_names_menu.dart';
import '/widgets/about_menu.dart';
import '/game/audio_manager.dart';

// This represents the settings menu overlay.
class SettingsMenu extends StatelessWidget {
  // An unique identified for this overlay.
  static const id = 'SettingsMenu';

  // Reference to parent game.
  final NinjaRun game;

  const SettingsMenu(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: game.settings,
      // Rebuild everything when the language changes.
      child: Selector<Settings, AppStrings>(
        selector: (_, settings) => settings.strings,
        builder: (context, s, _) => Center(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.9,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.black.withAlpha(100),
                child: Stack(
                  children: [
                    Padding(
                      // Room for the back button on the left.
                      padding: const EdgeInsets.fromLTRB(60, 8, 40, 8),
                      // Compact rows, so that all of them fit on short screens.
                      child: ListTileTheme(
                        data: const ListTileThemeData(
                          visualDensity: VisualDensity.compact,
                        ),
                        child: ListView(
                          children: [
                            Selector<Settings, bool>(
                              selector: (_, settings) => settings.bgm,
                              builder: (context, bgm, __) {
                                return SwitchListTile(
                                  title: MenuText(
                                    s.music,
                                    fontSize: s.menuFontSize,
                                    isMyanmar: s.isMyanmar,
                                    color: Colors.white,
                                  ),
                                  value: bgm,
                                  onChanged: (bool value) {
                                    Provider.of<Settings>(
                                      context,
                                      listen: false,
                                    ).bgm = value;
                                    if (value) {
                                      game.startMusic();
                                    } else {
                                      AudioManager.instance.stopBgm();
                                    }
                                  },
                                );
                              },
                            ),
                            Selector<Settings, bool>(
                              selector: (_, settings) => settings.sfx,
                              builder: (context, sfx, __) {
                                return SwitchListTile(
                                  title: MenuText(
                                    s.effects,
                                    fontSize: s.menuFontSize,
                                    isMyanmar: s.isMyanmar,
                                    color: Colors.white,
                                  ),
                                  value: sfx,
                                  onChanged: (bool value) {
                                    Provider.of<Settings>(
                                      context,
                                      listen: false,
                                    ).sfx = value;
                                  },
                                );
                              },
                            ),
                            ListTile(
                              title: MenuText(
                                s.language,
                                fontSize: s.menuFontSize,
                                isMyanmar: s.isMyanmar,
                                color: Colors.white,
                              ),
                              trailing: SegmentedButton<String>(
                                showSelectedIcon: false,
                                style: SegmentedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  selectedForegroundColor: Colors.black,
                                  selectedBackgroundColor: Colors.white,
                                ),
                                segments: const [
                                  ButtonSegment(
                                    value: AppStrings.myanmar,
                                    label: MenuText(
                                      'မြန်မာ',
                                      fontSize: 14,
                                      isMyanmar: true,
                                    ),
                                  ),
                                  ButtonSegment(
                                    value: AppStrings.english,
                                    label: Text('EN'),
                                  ),
                                ],
                                selected: {game.settings.language},
                                onSelectionChanged: (selection) =>
                                    game.settings.language = selection.first,
                              ),
                            ),
                            // Lined up with the switches above, with the arrow
                            // placed under the switches.
                            ListTile(
                              title: MenuText(
                                s.enemyNames,
                                fontSize: s.menuFontSize,
                                isMyanmar: s.isMyanmar,
                                color: Colors.white,
                              ),
                              trailing: const SizedBox(
                                width: 52,
                                child: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              onTap: () {
                                game.overlays.remove(SettingsMenu.id);
                                game.overlays.add(EnemyNamesMenu.id);
                              },
                            ),
                            ListTile(
                              title: MenuText(
                                s.about,
                                fontSize: s.menuFontSize,
                                isMyanmar: s.isMyanmar,
                                color: Colors.white,
                              ),
                              trailing: const SizedBox(
                                width: 52,
                                child: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              onTap: () {
                                game.overlays.remove(SettingsMenu.id);
                                game.overlays.add(AboutMenu.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Back button at the top left, so it is never
                    // scrolled out of sight.
                    Positioned(
                      left: 8,
                      top: 8,
                      child: IconButton(
                        onPressed: () {
                          game.overlays.remove(SettingsMenu.id);
                          game.overlays.add(MainMenu.id);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white,
                        ),
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
}
