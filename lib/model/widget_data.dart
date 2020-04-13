import 'dart:convert';

import 'package:deskit/model/value_keeper_data.dart';
import 'package:floor/floor.dart';

abstract class WidgetData {
  String type;

  WidgetData(this.type);

  String toJson();

  factory WidgetData.fromJson(String json) {
    var map = jsonDecode(json);
    switch (map['type']) {
      case ValueKeeperData.TYPE:
        return ValueKeeperData.fromJson(json);
      default:
        return null;
    }
  }

  WidgetData copy() {
    return WidgetData.fromJson(toJson());
  }
}

@entity
class WidgetDataEntity {
  @primaryKey
  final int id;
  final String dataText;

  WidgetData get data => WidgetData.fromJson(dataText);

  WidgetDataEntity(this.id, this.dataText);

  WidgetDataEntity.build(this.id, WidgetData data) : dataText = data.toJson();
}
