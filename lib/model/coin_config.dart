import 'dart:convert';

import 'package:deskit/coin.dart';
import 'package:deskit/model/coin_data.dart';
import 'package:deskit/model/widget_data.dart';
import 'package:deskit/model/widget_type_info.dart';
import 'package:deskit/repository/widget_data_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

import '../edit_widget_page.dart';
import 'config.dart';

part 'coin_config.g.dart';

@JsonSerializable(nullable: false)
class CoinConfig extends Config<Coin> {
  static const TYPE = 'Coin';

  @override
  final typeInfo = WidgetTypeInfo.COIN;

  static const maxNumber = 10;

  int number;
  String name;

  CoinConfig({this.number = 1, this.name = ''}) : super(TYPE);

  @override
  Coin build(int id, WidgetDataRepository repository, GlobalKey key) {
    return Coin(this, id, repository, key);
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
    item.number ??= 1;
    item.name ??= '';
    return item;
  }

  @override
  String toString() => jsonEncode(_$CoinConfigToJson(this));
}
