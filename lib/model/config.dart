import 'dart:convert';

import 'package:deskit/deskit_widget.dart';
import 'package:deskit/model/coin_config.dart';
import 'package:deskit/model/dice_config.dart';
import 'package:deskit/model/value_keeper_config.dart';
import 'package:deskit/model/widget_data.dart';
import 'package:deskit/model/widget_type_info.dart';
import 'package:deskit/repository/widget_data_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../edit_widget_page.dart';

abstract class Config<T extends DeskitWidget> {
  String type;
  WidgetTypeInfo typeInfo;

  Config(this.type);

  T build(int id, WidgetDataRepository repository, GlobalKey key,
      GlobalKey<ScaffoldState> scaffoldKey);

  ConfigEditList buildEditList(EditWidgetPageState parentState);

  WidgetData getDefaultData();

  @override
  String toString();

  static Config fromString(String jsonString) {
    var json = jsonDecode(jsonString);
    switch (json['type']) {
      case ValueKeeperConfig.TYPE:
        return ValueKeeperConfig.fromJson(jsonString);
      case CoinConfig.TYPE:
        return CoinConfig.fromJson(jsonString);
      case DiceConfig.TYPE:
        return DiceConfig.fromJson(jsonString);
      default:
        return null;
    }
  }

  Config copy() {
    return Config.fromString(toString());
  }
}
