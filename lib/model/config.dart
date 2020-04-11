import 'dart:convert';

import 'package:desktop_game_helper/model/value_keeper_config.dart';
import 'package:flutter/cupertino.dart';

abstract class Config {
  String type;

  Config(this.type);

  Widget build();

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
}
