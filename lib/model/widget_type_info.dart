import 'package:deskit/model/coin_config.dart';
import 'package:deskit/model/config.dart';
import 'package:deskit/model/value_keeper_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum WidgetTypeInfo {
  VALUE_KEEPER,
  COIN,
}

extension WidgetTypeInfoExtension on WidgetTypeInfo {
  String get name {
    switch (this) {
      case WidgetTypeInfo.VALUE_KEEPER:
        return 'Counter';
      case WidgetTypeInfo.COIN:
        return 'Coin toss';
      default:
        return null;
    }
  }

  String get description {
    switch (this) {
      case WidgetTypeInfo.VALUE_KEEPER:
        return 'Retain a value that can be incremented or decremented by a customized interval';
      case WidgetTypeInfo.COIN:
        return 'Randomly generate a result of coin toss';
      default:
        return null;
    }
  }

  IconData get icon{

    switch (this) {
      case WidgetTypeInfo.VALUE_KEEPER:
        return Icons.exposure_plus_1;
      case WidgetTypeInfo.COIN:
        return Icons.remove_circle_outline;
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
      default:
        return null;
    }
  }
}
