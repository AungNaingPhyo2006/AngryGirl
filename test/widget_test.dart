import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_game/models/shop.dart';
import 'package:flutter_game/models/player_data.dart';

void main() {
  group('PlayerData', () {
    test('rockets are clamped between 0 and maxRockets', () {
      final playerData = PlayerData();

      playerData.rockets = 100;
      expect(playerData.rockets, PlayerData.baseMaxRockets);

      playerData.rockets = -3;
      expect(playerData.rockets, 0);
    });

    test('upgrade getters use the base values with no upgrades', () {
      final playerData = PlayerData();

      expect(playerData.maxRockets, PlayerData.baseMaxRockets);
      expect(playerData.magnetDuration, PlayerData.baseMagnetDuration);
      expect(playerData.maxShieldCharges, 1);
      expect(playerData.dinoLife, PlayerData.baseDinoLife);
    });
  });

  group('Upgrade', () {
    test('every upgrade type has exactly one upgrade', () {
      for (final type in UpgradeType.values) {
        expect(Upgrade.all.where((u) => u.type == type).length, 1);
      }
    });

    test('maxLevel is the number of costs', () {
      final upgrade = Upgrade.of(UpgradeType.shieldStrength);
      expect(upgrade.maxLevel, upgrade.costs.length);
    });
  });
}
