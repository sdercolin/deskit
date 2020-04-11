import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

import '../value_keeper.dart';
import 'config.dart';

part 'value_keeper_config.g.dart';

@JsonSerializable(nullable: false)
class ValueKeeperConfig extends Config {
  static const TYPE = 'ValueKeeper';
  ValueKeeperStyle style;
  int interval;
  bool displayInterval;
  String name;

  ValueKeeperConfig(
    this.style, {
    this.interval = 1,
    this.displayInterval = false,
    this.name = '',
  }) : super(TYPE);

  @override
  Widget build() {
    return ValueKeeper(this);
  }

  factory ValueKeeperConfig.fromJson(String json) {
    return _$ValueKeeperConfigFromJson(jsonDecode(json));
  }

  @override
  String toJson() {
    return jsonEncode(_$ValueKeeperConfigToJson(this));
  }
}
