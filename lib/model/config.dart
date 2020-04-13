import 'dart:convert';

import 'package:deskit/deskit_widget.dart';
import 'package:deskit/model/value_keeper_config.dart';
import 'package:deskit/model/widget_type_info.dart';
import 'package:deskit/repository/widget_data_repository.dart';
import 'package:flutter/cupertino.dart';

import '../edit_widget_page.dart';

abstract class Config {
  String type;
  WidgetTypeInfo typeInfo;

  Config(this.type);

  DeskitWidget build(WidgetDataRepository repository, int id, GlobalKey key);

  ConfigEditList buildEditList(EditWidgetPageState parentState);

  String toJson();

  factory Config.fromJson(String json) {
    var map = jsonDecode(json);
    switch (map['type']) {
      case ValueKeeperConfig.TYPE:
        return ValueKeeperConfig.fromJson(json);
      default:
        return null;
    }
  }

  Config copy() {
    return Config.fromJson(toJson());
  }
}
