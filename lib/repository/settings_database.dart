import 'dart:async';

import 'package:desktop_game_helper/model/settings.dart';
import 'package:desktop_game_helper/repository/settings_dao.dart';
import 'package:floor/floor.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'settings_database.g.dart';

@Database(version: 1, entities: [Settings])
abstract class SettingsDatabase extends FloorDatabase {
  SettingsDao get settingsDao;
}
