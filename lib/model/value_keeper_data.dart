import 'dart:convert';

import 'package:desktop_game_helper/model/widget_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'value_keeper_data.g.dart';

@JsonSerializable(nullable: false)
class ValueKeeperData extends WidgetData {
  static const TYPE = 'ValueKeeper';
  static const defaultValue = 0;

  int value;

  ValueKeeperData(this.value) : super(TYPE);

  factory ValueKeeperData.fromJson(String json) =>
      _$ValueKeeperDataFromJson(jsonDecode(json));

  @override
  String toJson() => jsonEncode(_$ValueKeeperDataToJson(this));
}
