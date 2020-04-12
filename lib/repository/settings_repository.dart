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

  Future<Settings> getCurrent() async {
    final all = await (await dao).getAll();
    return all.firstWhere((element) => element.selected, orElse: () => null);
  }

  void add(Settings settings) async {
    await (await dao).add(settings);
  }

  void update(Settings settings) async {
    await (await dao).updateAll([settings]);
  }

  void select(int id) async {
    final dao = await this.dao;
    final all = await dao.getAll();
    final edited = all.map((it) {
      final selected = it.id == id;
      return it.copy(selected: selected);
    }).toList();
    await dao.updateAll(edited);
  }
}
