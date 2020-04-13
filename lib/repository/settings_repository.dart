import 'package:desktop_game_helper/model/settings.dart';
import 'package:desktop_game_helper/repository/app_database.dart';
import 'package:desktop_game_helper/repository/settings_dao.dart';

class SettingsRepository {
  Future<SettingsDao> get dao async {
    _dao ??=
        (await $FloorAppDatabase.databaseBuilder('app.db').build()).settingsDao;
    return _dao;
  }

  SettingsDao _dao;

  var _data = <Settings>[];

  Settings getCurrent() {
    return _data.firstWhere((element) => element.selected, orElse: () => null);
  }

  void fetch() async {
    _data = await (await dao).getAll();
  }

  void add(Settings settings) async {
    _data.add(settings);
    await _add(settings);
  }

  void _add(Settings settings) async {
    await (await dao).addAll([settings]);
  }

  void update(Settings settings) async {
    final index = settings.id;
    _data[index] = settings;
    await _update(settings);
  }

  void updateSync(Settings settings) {
    final index = settings.id;
    _data[index] = settings;
    _update(settings);
  }

  void _update(Settings settings) async {
    await (await dao).updateAll([settings]);
  }

  void select(int id) {
    _data = _data.map((element) {
      final selected = element.id == id;
      return element.copy(selected: selected);
    }).toList();
    _writeAll();
  }

  void _writeAll() async {
    final dao = await this.dao;
    await dao.clear();
    await dao.addAll(_data);
  }
}
