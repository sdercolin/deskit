import 'dart:convert';

import 'package:deskit/deskit_widget.dart';
import 'package:deskit/model/widget_type_info.dart';
import 'package:deskit/repository/widget_data_repository.dart';
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
  static const maxAbsoluteValue = 99999999;

  ValueKeeperStyle style;
  int interval;
  bool displayInterval;
  String name;
  bool requestIntervalEveryTime;
  int initialValue;

  ValueKeeperConfig({
    this.style = ValueKeeperStyle.LARGE,
    this.interval = 1,
    this.displayInterval = false,
    this.name = '',
    this.requestIntervalEveryTime = false,
    this.initialValue = 0,
  }) : super(TYPE);

  @override
  DeskitWidget build(WidgetDataRepository repository, int id, GlobalKey key) {
    return ValueKeeper(this, repository, id, key);
  }

  @override
  ConfigEditList buildEditList(EditWidgetPageState parentState) =>
      ValueKeeperConfigEditList(this, parentState);

  factory ValueKeeperConfig.fromJson(String json) {
    final item = _$ValueKeeperConfigFromJson(jsonDecode(json));
    item.style ??= ValueKeeperStyle.LARGE;
    item.interval ??= 1;
    item.displayInterval ??= false;
    item.name ??= '';
    item.requestIntervalEveryTime ??= false;
    item.initialValue ??= 0;
    return item;
  }

  @override
  String toJson() => jsonEncode(_$ValueKeeperConfigToJson(this));

  static int validateValue(int value) {
    if (value > maxAbsoluteValue) {
      return maxAbsoluteValue;
    } else if (value < -maxAbsoluteValue) {
      return -maxAbsoluteValue;
    } else {
      return value;
    }
  }
}
