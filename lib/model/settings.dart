import 'dart:convert';

import 'package:deskit/model/config.dart';
import 'package:floor/floor.dart';

@entity
class Settings {
  @primaryKey
  final int id;
  final String configsText;
  final String name;
  final bool selected;

  @ignore
  List<Config> get configs {
    return (jsonDecode(configsText) as List)
        .map((e) => Config.fromString(e))
        .toList();
  }

  Settings(this.id, this.configsText, this.name, this.selected);

  Settings.build(this.id, List<Config> configs, this.name, this.selected)
      : configsText = jsonEncode(configs.map((e) => e.toString()).toList());

  Settings copy({List<Config> configs, String name, bool selected}) {
    final configsText = configs != null
        ? jsonEncode(configs.map((e) => e.toString()).toList())
        : this.configsText;
    return Settings(
        id, configsText, name ?? this.name, selected ?? this.selected);
  }

  Settings removeConfigItemAt(int index) {
    final configs = this.configs;
    configs.removeAt(index);
    return copy(configs: configs);
  }
}
