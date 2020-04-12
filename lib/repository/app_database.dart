import 'dart:async';

import 'package:desktop_game_helper/model/settings.dart';
import 'package:desktop_game_helper/model/widget_data.dart';
import 'package:desktop_game_helper/repository/settings_dao.dart';
import 'package:desktop_game_helper/repository/widget_data_dao.dart';
import 'package:floor/floor.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'app_database.g.dart';

@Database(version: 2, entities: [Settings, WidgetDataEntity])
abstract class AppDatabase extends FloorDatabase {
  SettingsDao get settingsDao;

  WidgetDataDao get widgetDataDao;
}
