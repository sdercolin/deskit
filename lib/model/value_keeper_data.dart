import 'dart:convert';

import 'package:deskit/model/widget_data.dart';
import 'package:json_annotation/json_annotation.dart';

import '../value_keeper.dart';

part 'value_keeper_data.g.dart';

@JsonSerializable(nullable: false)
class ValueKeeperData extends WidgetData<ValueKeeper> {
  static const TYPE = 'ValueKeeper';
  static const defaultValue = 0;

  int value;

  ValueKeeperData(this.value) : super(TYPE);

  factory ValueKeeperData.fromString(String jsonString) =>
      _$ValueKeeperDataFromJson(jsonDecode(jsonString));

  @override
  String toString() => jsonEncode(_$ValueKeeperDataToJson(this));
}
