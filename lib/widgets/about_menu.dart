import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../game/ninja_run.dart';
import '/widgets/settings_menu.dart';

// This represents the about overlay. It shows a short description
// of the game, the app version and the developer name and email.
class AboutMenu extends StatelessWidget {
  // An unique identified for this overlay.
  static const id = 'AboutMenu';

  static const _developer = 'Aung Naing Phyo';
  static const _developerEmail = 'aung.anp.2006@gmail.com';

  // Reference to parent game.
  final NinjaRun game;

  const AboutMenu(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    final s = game.settings.strings;
    return Center(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: Colors.black.withAlpha(100),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 60),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      'Angry Girl',
                      style: TextStyle(fontSize: 30, color: Colors.white),
                    ),
                    // Version is read from pubspec.yaml at runtime.
                    FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        final info = snapshot.data;
                        return Text(
                          info == null
                              ? ''
                              : s.version(info.version, info.buildNumber),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.developedBy(_developer),
                      style: const TextStyle(fontSize: 15, color: Colors.white),
                    ),
                    // Opens the email app with the developer email filled in.
                    InkWell(
                      onTap: () => launchUrl(
                        Uri(scheme: 'mailto', path: _developerEmail),
                      ),
                      child: const Text(
                        _developerEmail,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white70,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        game.overlays.remove(AboutMenu.id);
                        game.overlays.add(SettingsMenu.id);
                      },
                      child: const Icon(Icons.arrow_back_ios_rounded),
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
