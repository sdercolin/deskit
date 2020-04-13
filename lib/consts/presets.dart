import 'package:desktop_game_helper/model/settings.dart';
import 'package:desktop_game_helper/model/value_keeper_config.dart';

import '../value_keeper.dart';

class Presets {
  static final defaultSettings = Settings.build(
    0,
    [
      ValueKeeperConfig(
          style: ValueKeeperStyle.LARGE,
          displayInterval: true,
          name: 'Large size',
          initialValue: 8000,
          interval: 100),
      ValueKeeperConfig(style: ValueKeeperStyle.SMALL, name: 'Small size')
    ],
    'default',
    true,
  );
}
