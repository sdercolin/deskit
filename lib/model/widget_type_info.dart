import 'package:deskit/model/coin_config.dart';
import 'package:deskit/model/config.dart';
import 'package:deskit/model/dice_config.dart';
import 'package:deskit/model/timer_config.dart';
import 'package:deskit/model/value_keeper_config.dart';
import 'package:flutter/material.dart';

enum WidgetTypeInfo { VALUE_KEEPER, COIN, DICE, TIMER }

extension WidgetTypeInfoExtension on WidgetTypeInfo {
  String get name {
    switch (this) {
      case WidgetTypeInfo.VALUE_KEEPER:
        return 'Counter';
      case WidgetTypeInfo.COIN:
        return 'Coin toss';
      case WidgetTypeInfo.DICE:
        return 'Dice roller';
      case WidgetTypeInfo.TIMER:
        return 'Timer';
      default:
        return null;
    }
  }

  String get description {
    switch (this) {
      case WidgetTypeInfo.VALUE_KEEPER:
        return 'Retains an integer value that can be incremented or decremented by a customized interval';
      case WidgetTypeInfo.COIN:
        return 'Randomly generates a set of booleans';
      case WidgetTypeInfo.DICE:
        return 'Randomly generates a set of integers within the given range';
      case WidgetTypeInfo.TIMER:
        return 'Counts down from a specified time interval';
      default:
        return null;
    }
  }

  IconData get icon {
    switch (this) {
      case WidgetTypeInfo.VALUE_KEEPER:
        return Icons.exposure_plus_1;
      case WidgetTypeInfo.COIN:
        return Icons.remove_circle_outline;
      case WidgetTypeInfo.DICE:
        return Icons.add_box;
      case WidgetTypeInfo.TIMER:
        return Icons.timer;
      default:
        return null;
    }
  }

  Config createDefaultConfig() {
    switch (this) {
      case WidgetTypeInfo.VALUE_KEEPER:
        return ValueKeeperConfig();
      case WidgetTypeInfo.COIN:
        return CoinConfig();
      case WidgetTypeInfo.DICE:
        return DiceConfig();
      case WidgetTypeInfo.TIMER:
        return TimerConfig();
      default:
        return null;
    }
  }
}
