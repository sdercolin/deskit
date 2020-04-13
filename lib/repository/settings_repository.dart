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

  void _writeAll() async {
    final dao = await this.dao;
    await dao.clear();
    await dao.addAll(_data);
  }

  void add(Settings settings) {
    _data.add(settings);
    _writeAll();
  }

  void update(Settings settings) {
    final index = settings.id;
    _data[index] = settings;
    _writeAll();
  }

  void select(int id) {
    _data = _data.map((element) {
      final selected = element.id == id;
      return element.copy(selected: selected);
    }).toList();
    _writeAll();
  }
}
