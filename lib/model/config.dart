import 'dart:convert';

import 'package:deskit/deskit_widget.dart';
import 'package:deskit/model/coin_config.dart';
import 'package:deskit/model/value_keeper_config.dart';
import 'package:deskit/model/widget_type_info.dart';
import 'package:deskit/repository/widget_data_repository.dart';
import 'package:flutter/cupertino.dart';

import '../edit_widget_page.dart';

abstract class Config<T extends DeskitWidget> {
  String type;
  WidgetTypeInfo typeInfo;

  Config(this.type);

  T build(int id, WidgetDataRepository repository, GlobalKey key);

  ConfigEditList buildEditList(EditWidgetPageState parentState);

  String toJson();

  static Config fromJson(String json) {
    var map = jsonDecode(json);
    switch (map['type']) {
      case ValueKeeperConfig.TYPE:
        return ValueKeeperConfig.fromJson(json);
      case CoinConfig.TYPE:
        return CoinConfig.fromJson(json);
      default:
        return null;
    }
  }

  Config copy() {
    return Config.fromJson(toJson());
  }
}
