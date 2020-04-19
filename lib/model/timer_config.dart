import 'dart:convert';

import 'package:deskit/edit_widget_page.dart';
import 'package:deskit/model/config.dart';
import 'package:deskit/model/timer_data.dart';
import 'package:deskit/model/widget_data.dart';
import 'package:deskit/model/widget_type_info.dart';
import 'package:deskit/repository/widget_data_repository.dart';
import 'package:deskit/timer.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'timer_config.g.dart';

@JsonSerializable(nullable: false)
class TimerConfig extends Config<Timer> {
  static const TYPE = 'Timer';

  @override
  final typeInfo = WidgetTypeInfo.TIMER;

  String name;
  int totalSec;
  bool showProgressBar;
  bool vibrate;
  bool sound;
  bool requestTotalEveryTime;

  TimerConfig({
    this.name = '',
    this.totalSec = 60,
    this.showProgressBar = true,
    this.vibrate = true,
    this.sound = false,
    this.requestTotalEveryTime = false,
  }) : super(TYPE);

  @override
  Timer build(int id, WidgetDataRepository repository, GlobalKey key,
      GlobalKey scaffoldKey, State parentState) {
    return Timer(this, id, repository, key, scaffoldKey, parentState);
  }

  @override
  ConfigEditList buildEditList(EditWidgetPageState parentState) {
    return TimerConfigEditList(this, parentState);
  }

  @override
  WidgetData getDefaultData() {
    return TimerData(
      requestTotalEveryTime ? 0 : totalSec,
      requestTotalEveryTime ? 0 : totalSec,
    );
  }

  factory TimerConfig.fromJson(String json) {
    final item = _$TimerConfigFromJson(jsonDecode(json));
    item.name ??= '';
    item.totalSec ??= 60;
    item.showProgressBar ??= true;
    item.vibrate ??= true;
    item.sound ??= false;
    item.requestTotalEveryTime ??= false;
    return item;
  }

  @override
  String toString() => jsonEncode(_$TimerConfigToJson(this));
}
