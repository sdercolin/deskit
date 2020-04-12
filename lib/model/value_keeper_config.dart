import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

import '../configuration_page.dart';
import '../value_keeper.dart';
import 'config.dart';

part 'value_keeper_config.g.dart';

@JsonSerializable(nullable: false)
class ValueKeeperConfig extends Config {
  static const TYPE = 'ValueKeeper';
  ValueKeeperStyle style;
  int interval;
  bool displayInterval;
  String name;

  ValueKeeperConfig(
    this.style, {
    this.interval = 1,
    this.displayInterval = false,
    this.name = '',
  }) : super(TYPE);

  @override
  Widget build() => ValueKeeper(this);

  @override
  String getEditPageTitle() =>
      'Configure value keeper' + (name?.isNotEmpty == true ? ': $name' : '');

  @override
  ConfigEditList buildEditList(ConfigurationPageState parentState) =>
      ValueKeeperConfigEditList(this, parentState);

  factory ValueKeeperConfig.fromJson(String json) =>
      _$ValueKeeperConfigFromJson(jsonDecode(json));

  @override
  String toJson() => jsonEncode(_$ValueKeeperConfigToJson(this));
}
