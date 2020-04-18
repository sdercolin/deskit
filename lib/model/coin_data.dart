import 'dart:convert';

import 'package:deskit/coin.dart';
import 'package:deskit/model/widget_data.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'coin_data.g.dart';

@JsonSerializable(nullable: false)
class CoinData extends WidgetData<Coin> {
  static const TYPE = 'Coin';

  List<CoinTossResult> results;

  CoinData(List<CoinTossResult> results)
      : results = results ?? <CoinTossResult>[],
        super(TYPE);

  factory CoinData.fromString(String jsonString) =>
      _$CoinDataFromJson(jsonDecode(jsonString));

  @override
  String toString() => jsonEncode(_$CoinDataToJson(this));
}

@JsonSerializable(nullable: false)
class CoinTossResult {
  int total;
  int obverse;
  int time;

  CoinTossResult(this.total, this.obverse, this.time);

  factory CoinTossResult.fromJson(Map<String, dynamic> json) =>
      _$CoinTossResultFromJson(json);

  Map<String, dynamic> toJson() => _$CoinTossResultToJson(this);

  String buildText() {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(time);
    final formatter = DateFormat('HH:mm:ss');
    final timeText = formatter.format(dateTime);
    return timeText + ' ' + buildSimpleText();
  }

  String buildSimpleText() {
    return total > 1
        ? 'Obverse: $obverse/$total'
        : (obverse == 1 ? 'Obverse' : 'Reverse');
  }
}
