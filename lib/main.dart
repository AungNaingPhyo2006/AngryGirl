import 'package:flame/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'game/ninja_run.dart';
import 'models/settings.dart';
import 'models/app_strings.dart';
import 'widgets/main_menu.dart';
import 'models/player_data.dart';
import 'widgets/hud.dart';
import 'widgets/hud_guide.dart';
import 'widgets/pause_menu.dart';
import 'widgets/about_menu.dart';
import 'widgets/shop_menu.dart';
import 'widgets/enemy_names_menu.dart';
import 'widgets/settings_menu.dart';
import 'widgets/game_over_menu.dart';

Future<void> main() async {
  // Ensures that all bindings are initialized
  // before was start calling hive and flame code
  // dealing with platform channels.
  WidgetsFlutterBinding.ensureInitialized();

  // Initializes hive and register the adapters.
  await initHive();
  runApp(const NinjaRunApp());
}

// This function will initilize hive with apps documents directory.
// Additionally it will also register all the hive adapters.
Future<void> initHive() async {
  // For web hive does not need to be initialized.
  if (!kIsWeb) {
    final dir = await getApplicationDocumentsDirectory(); // Get local path
    Hive.init(dir.path); // Initialize Hive there
  }

  Hive.registerAdapter<PlayerData>(
    PlayerDataAdapter(),
  ); // Register PlayerData model
  Hive.registerAdapter<Settings>(SettingsAdapter()); // Register Settings model
}

// The main widget for this game.
class NinjaRunApp extends StatelessWidget {
  const NinjaRunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ninja Run',
      theme: ThemeData(
        fontFamily: 'Audiowide',
        // Audiowide has no Myanmar letters, so those are drawn with this.
        fontFamilyFallback: const ['NotoSerifMyanmar'],
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Settings up some default theme for elevated buttons.
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            // No vertical padding, so that the tall lines of
            // Myanmar texts are not clipped by the fixed height.
            padding: EdgeInsets.zero,
            fixedSize: const Size(200, 60),
          ),
        ),
      ),
      home: Scaffold(
        body: GameWidget<NinjaRun>.controlled(
          // This will dislpay a loading bar until [NinjaRun] completes
          // its onLoad method.
          loadingBuilder: (conetxt) => const Center(
            child: SizedBox(width: 200, child: LinearProgressIndicator()),
          ),
          // Register all the overlays that will be used by this game.
          overlayBuilderMap: {
            MainMenu.id: (_, game) => _withLanguage(game, MainMenu(game)),
            PauseMenu.id: (_, game) => _withLanguage(game, PauseMenu(game)),
            Hud.id: (_, game) => _withLanguage(game, Hud(game)),
            HudGuide.id: (_, game) => _withLanguage(game, HudGuide(game)),
            GameOverMenu.id: (_, game) =>
                _withLanguage(game, GameOverMenu(game)),
            SettingsMenu.id: (_, game) =>
                _withLanguage(game, SettingsMenu(game)),
            AboutMenu.id: (_, game) => _withLanguage(game, AboutMenu(game)),
            ShopMenu.id: (_, game) => _withLanguage(game, ShopMenu(game)),
            EnemyNamesMenu.id: (_, game) =>
                _withLanguage(game, EnemyNamesMenu(game)),
          },
          // By default MainMenu overlay will be active.
          initialActiveOverlays: const [MainMenu.id],
          gameFactory: () => NinjaRun(
            // Use a fixed resolution camera to avoid manually
            // scaling and handling different screen sizes.
            camera: CameraComponent.withFixedResolution(
              width: 360,
              height: 180,
            ),
          ),
        ),
      ),
    );
  }
}

// Myanmar letters are taller than English ones, so texts of an overlay
// are drawn a little smaller while Myanmar is the selected language.
// Overlays may be built before the game has loaded its settings,
// so they are shown only once the game is loaded.
Widget _withLanguage(NinjaRun game, Widget overlay) {
  if (!game.isLoaded) {
    return FutureBuilder<void>(
      future: game.loaded,
      builder: (context, snapshot) =>
          snapshot.connectionState == ConnectionState.done
          ? _withLanguage(game, overlay)
          : const SizedBox.shrink(),
    );
  }
  return ListenableBuilder(
    listenable: game.settings,
    builder: (context, child) {
      final isMyanmar = game.settings.language == AppStrings.myanmar;
      final scale = MediaQuery.textScalerOf(context).scale(1);
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(isMyanmar ? scale * 0.85 : scale),
        ),
        child: child!,
      );
    },
    child: overlay,
  );
}
