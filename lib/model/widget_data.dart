import 'dart:convert';

import 'package:deskit/deskit_widget.dart';
import 'package:deskit/model/coin_data.dart';
import 'package:deskit/model/value_keeper_data.dart';
import 'package:floor/floor.dart';

abstract class WidgetData<T extends DeskitWidget> {
  String type;

  WidgetData(this.type);

  @override
  String toString();

  static WidgetData fromString(String jsonString) {
    var map = jsonDecode(jsonString);
    switch (map['type']) {
      case ValueKeeperData.TYPE:
        return ValueKeeperData.fromString(jsonString);
      case CoinData.TYPE:
        return CoinData.fromString(jsonString);
      default:
        return null;
    }
  }

  WidgetData copy() {
    return WidgetData.fromString(toString());
  }
}

@entity
class WidgetDataEntity {
  @primaryKey
  final int id;
  final String dataText;

  WidgetData get data => WidgetData.fromString(dataText);

  WidgetDataEntity(this.id, this.dataText);

  WidgetDataEntity.build(this.id, WidgetData data) : dataText = data.toString();
}
