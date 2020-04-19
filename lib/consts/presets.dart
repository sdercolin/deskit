import 'package:deskit/model/coin_config.dart';
import 'package:deskit/model/dice_config.dart';
import 'package:deskit/model/settings.dart';
import 'package:deskit/model/timer_config.dart';
import 'package:deskit/model/value_keeper_config.dart';
import 'package:deskit/value_keeper.dart';

class Presets {
  static final defaultSettings = Settings.build(
    0,
    [
      ValueKeeperConfig(
          style: ValueKeeperStyle.LARGE,
          displayInterval: true,
          name: 'Counter',
          initialValue: 8000,
          interval: 100),
      TimerConfig(name: 'Timer', totalSec: 10),
      CoinConfig(name: 'Coin', showHistory: false),
      DiceConfig(name: 'Dice')
    ],
    'Showcase',
    true,
  );
}
