import 'dart:convert';

import 'package:deskit/model/value_keeper_data.dart';
import 'package:deskit/model/widget_data.dart';
import 'package:deskit/model/widget_type_info.dart';
import 'package:deskit/repository/widget_data_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../edit_widget_page.dart';
import '../value_keeper.dart';
import 'config.dart';

part 'value_keeper_config.g.dart';

@JsonSerializable(nullable: false)
class ValueKeeperConfig extends Config<ValueKeeper> {
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
  ValueKeeper build(int id, WidgetDataRepository repository, GlobalKey key,
      GlobalKey<ScaffoldState> scaffoldKey) {
    return ValueKeeper(this, id, repository, key, scaffoldKey);
  }

  @override
  ConfigEditList buildEditList(EditWidgetPageState parentState) =>
      ValueKeeperConfigEditList(this, parentState);

  @override
  WidgetData getDefaultData() {
    return ValueKeeperData(initialValue);
  }

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
  String toString() => jsonEncode(_$ValueKeeperConfigToJson(this));

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
