import 'dart:convert';

import 'package:deskit/model/widget_data.dart';
import 'package:deskit/timer.dart';
import 'package:json_annotation/json_annotation.dart';

part 'timer_data.g.dart';

@JsonSerializable(nullable: false)
class TimerData extends WidgetData<Timer> {
  static const TYPE = 'Timer';

  int total;
  int now;

  TimerData(this.total, this.now) : super(TYPE);

  factory TimerData.fromString(String jsonString) =>
      _$TimerDataFromJson(jsonDecode(jsonString));

  @override
  String toString() => jsonEncode(_$TimerDataToJson(this));

  TimerData copyWith({int total, int now}) {
    return TimerData(total ?? this.total, now ?? this.now);
  }
}
