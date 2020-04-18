import 'package:deskit/model/coin_config.dart';
import 'package:deskit/model/dice_config.dart';
import 'package:deskit/model/settings.dart';
import 'package:deskit/model/value_keeper_config.dart';

import '../value_keeper.dart';

class Presets {
  static final defaultSettings = Settings.build(
    0,
    [
      ValueKeeperConfig(
          style: ValueKeeperStyle.LARGE,
          displayInterval: true,
          name: 'Large counter',
          initialValue: 8000,
          interval: 100),
      ValueKeeperConfig(style: ValueKeeperStyle.SMALL, name: 'Small counter'),
      CoinConfig(name: 'Coin', showHistory: false),
      DiceConfig(name: 'Dice')
    ],
    'default',
    true,
  );
}
