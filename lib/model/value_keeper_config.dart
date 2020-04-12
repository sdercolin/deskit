import 'dart:convert';

import 'package:desktop_game_helper/model/widget_type_info.dart';
import 'package:desktop_game_helper/repository/widget_data_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

import '../edit_widget_page.dart';
import '../value_keeper.dart';
import 'config.dart';

part 'value_keeper_config.g.dart';

@JsonSerializable(nullable: false)
class ValueKeeperConfig extends Config {
  static const TYPE = 'ValueKeeper';

  @override
  final typeInfo = WidgetTypeInfo.VALUE_KEEPER;

  static const maxInterval = 10000;
  static const _maxAbsoluteValue = 99999999;

  ValueKeeperStyle style;
  int interval;
  bool displayInterval;
  String name;

  ValueKeeperConfig({
    this.style = ValueKeeperStyle.LARGE,
    this.interval = 1,
    this.displayInterval = false,
    this.name = '',
  }) : super(TYPE);

  @override
  Widget build(WidgetDataRepository repository, int id) {
    return ValueKeeper(this, repository, id);
  }

  @override
  ConfigEditList buildEditList(EditWidgetPageState parentState) =>
      ValueKeeperConfigEditList(this, parentState);

  factory ValueKeeperConfig.fromJson(String json) =>
      _$ValueKeeperConfigFromJson(jsonDecode(json));

  @override
  String toJson() => jsonEncode(_$ValueKeeperConfigToJson(this));

  static int validateValue(int value) {
    if (value > _maxAbsoluteValue) {
      return _maxAbsoluteValue;
    } else if (value < -_maxAbsoluteValue) {
      return -_maxAbsoluteValue;
    } else {
      return value;
    }
  }
}
