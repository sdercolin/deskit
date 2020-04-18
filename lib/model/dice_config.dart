import 'dart:convert';

import 'package:deskit/dice.dart';
import 'package:deskit/edit_widget_page.dart';
import 'package:deskit/model/config.dart';
import 'package:deskit/model/dice_data.dart';
import 'package:deskit/model/widget_data.dart';
import 'package:deskit/model/widget_type_info.dart';
import 'package:deskit/repository/widget_data_repository.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dice_config.g.dart';

@JsonSerializable(nullable: false)
class DiceConfig extends Config<Dice> {
  static const TYPE = 'Dice';

  @override
  final typeInfo = WidgetTypeInfo.DICE;

  static const maxNumber = 10;
  static const minSides = 2;
  static const maxSides = 999;

  String name;
  int sides;
  bool requestSidesEveryTime;
  bool showHistory;
  bool longPressMultiple;
  bool popupResult;

  DiceConfig({
    this.name = '',
    this.sides = 6,
    this.showHistory = true,
    this.longPressMultiple = true,
    this.popupResult = true,
    this.requestSidesEveryTime = false,
  }) : super(TYPE);

  @override
  Dice build(int id, WidgetDataRepository repository, GlobalKey key,
      GlobalKey scaffoldKey, State parentState) {
    return Dice(this, id, repository, key, scaffoldKey, parentState);
  }

  @override
  ConfigEditList buildEditList(EditWidgetPageState parentState) {
    return DiceConfigEditList(this, parentState);
  }

  @override
  WidgetData getDefaultData() {
    return DiceData([]);
  }

  factory DiceConfig.fromJson(String json) {
    final item = _$DiceConfigFromJson(jsonDecode(json));
    item.name ??= '';
    item.showHistory ??= true;
    item.longPressMultiple ??= true;
    item.popupResult ??= true;
    return item;
  }

  @override
  String toString() => jsonEncode(_$DiceConfigToJson(this));
}
