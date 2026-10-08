import 'dart:ui';

import 'package:flutter/material.dart';

import '../game/ninja_run.dart';
import '/models/settings.dart';
import '/widgets/settings_menu.dart';

// This represents the overlay where the player can change the
// names shown above enemies. An empty name hides the enemy's name.
class EnemyNamesMenu extends StatefulWidget {
  // An unique identified for this overlay.
  static const id = 'EnemyNamesMenu';

  // Reference to parent game.
  final NinjaRun game;

  const EnemyNamesMenu(this.game, {super.key});

  @override
  State<EnemyNamesMenu> createState() => _EnemyNamesMenuState();
}

class _EnemyNamesMenuState extends State<EnemyNamesMenu> {
  late final Map<String, TextEditingController> _controllers = {
    for (final id in Settings.defaultEnemyNames.keys)
      id: TextEditingController(text: widget.game.settings.enemyName(id)),
  };

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.game.settings;

    final ids = _controllers.keys.toList();

    // The card is sized from the space left by the keyboard (not the
    // screen size), so that the focused text field stays visible.
    return LayoutBuilder(
      builder: (context, constraints) => Center(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: SizedBox(
            width: constraints.maxWidth * 0.8,
            height: constraints.maxHeight * 0.8,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.black.withAlpha(100),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 40,
                ),
                children: [
                  Text(
                    settings.strings.enemyNames,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  Text(
                    settings.strings.enemyNamesHint,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  // Two name fields per row.
                  for (var i = 0; i < ids.length; i += 2)
                    Row(
                      children: [
                        for (final id in ids.skip(i).take(2))
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: _nameField(id, settings),
                            ),
                          ),
                      ],
                    ),
                  TextButton(
                    onPressed: () {
                      widget.game.overlays.remove(EnemyNamesMenu.id);
                      widget.game.overlays.add(SettingsMenu.id);
                    },
                    child: const Icon(Icons.arrow_back_ios_rounded),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _nameField(String id, Settings settings) {
    final controller = _controllers[id]!;
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: settings.strings.enemyLabel(id),
        labelStyle: const TextStyle(color: Colors.white70),
        hintText: Settings.defaultEnemyNames[id],
        hintStyle: const TextStyle(color: Colors.white38),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear, color: Colors.white70),
          onPressed: () {
            controller.clear();
            settings.setEnemyName(id, '');
          },
        ),
      ),
      onChanged: (value) => settings.setEnemyName(id, value),
    );
  }
}
