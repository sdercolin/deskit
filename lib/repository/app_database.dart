import 'dart:async';

import 'package:deskit/model/settings.dart';
import 'package:deskit/model/widget_data.dart';
import 'package:deskit/repository/settings_dao.dart';
import 'package:deskit/repository/widget_data_dao.dart';
import 'package:floor/floor.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'app_database.g.dart';

@Database(version: 2, entities: [Settings, WidgetDataEntity])
abstract class AppDatabase extends FloorDatabase {
  SettingsDao get settingsDao;

  WidgetDataDao get widgetDataDao;
}
