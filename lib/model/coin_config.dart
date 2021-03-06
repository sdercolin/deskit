import 'dart:convert';

import 'package:deskit/coin.dart';
import 'package:deskit/edit_widget_page.dart';
import 'package:deskit/model/coin_data.dart';
import 'package:deskit/model/config.dart';
import 'package:deskit/model/widget_data.dart';
import 'package:deskit/model/widget_type_info.dart';
import 'package:deskit/repository/widget_data_repository.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'coin_config.g.dart';

@JsonSerializable(nullable: false)
class CoinConfig extends Config<Coin> {
  static const TYPE = 'Coin';

  @override
  final typeInfo = WidgetTypeInfo.COIN;

  static const maxNumber = 999;

  String name;
  bool showHistory;
  bool longPressMultiple;
  bool popupResult;

  CoinConfig({
    this.name = '',
    this.showHistory = true,
    this.longPressMultiple = true,
    this.popupResult = true,
  }) : super(TYPE);

  @override
  Coin build(int id, WidgetDataRepository repository, GlobalKey key,
      GlobalKey scaffoldKey, State parentState) {
    return Coin(this, id, repository, key, scaffoldKey, parentState);
  }

  @override
  ConfigEditList buildEditList(EditWidgetPageState parentState) {
    return CoinConfigEditList(this, parentState);
  }

  @override
  WidgetData getDefaultData() {
    return CoinData([]);
  }

  factory CoinConfig.fromJson(String json) {
    final item = _$CoinConfigFromJson(jsonDecode(json));
    item.name ??= '';
    item.showHistory ??= true;
    item.longPressMultiple ??= true;
    item.popupResult ??= true;
    return item;
  }

  @override
  String toString() => jsonEncode(_$CoinConfigToJson(this));
}
