import 'dart:convert';

import 'package:deskit/dice.dart';
import 'package:deskit/model/widget_data.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dice_data.g.dart';

@JsonSerializable(nullable: false)
class DiceData extends WidgetData<Dice> {
  static const TYPE = 'Dice';

  List<DiceRollResult> results;

  DiceData(List<DiceRollResult> results)
      : results = results ?? <DiceRollResult>[],
        super(TYPE);

  factory DiceData.fromString(String jsonString) =>
      _$DiceDataFromJson(jsonDecode(jsonString));

  @override
  String toString() => jsonEncode(_$DiceDataToJson(this));
}

@JsonSerializable(nullable: false)
class DiceRollResult {
  int sides;
  List<int> rolls;
  int time;

  DiceRollResult(this.sides, this.rolls, this.time);

  factory DiceRollResult.fromJson(Map<String, dynamic> json) =>
      _$DiceRollResultFromJson(json);

  Map<String, dynamic> toJson() => _$DiceRollResultToJson(this);

  int get sum => rolls.fold(0, (pre, value) => pre + value);

  String get rollsText => rolls.map((e) => e.toString()).toList().join(', ');

  String buildText() {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(time);
    final formatter = DateFormat('HH:mm:ss');
    final timeText = formatter.format(dateTime);
    return timeText + ' Result: ' + buildSimpleText();
  }

  String buildSimpleText() {
    return rolls.length > 1 ? '$sum ($rollsText)' : '$sum';
  }
}
