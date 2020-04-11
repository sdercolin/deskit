import 'package:desktop_game_helper/model/settings.dart';
import 'package:desktop_game_helper/repository/settings_database.dart';

class SettingsRepository {
  Future<SettingsDatabase> _getDatabase() async {
    return await $FloorSettingsDatabase.databaseBuilder('settings.db').build();
  }

  Future<Settings> getCurrent() async {
    final all = await (await _getDatabase()).settingsDao.getAll();
    return all.firstWhere((element) => element.selected, orElse: () => null);
  }

  void add(Settings settings) async {
    await (await _getDatabase()).settingsDao.add(settings);
  }

  void update(Settings settings) async {
    final database = await _getDatabase();
    await database.settingsDao.updateAll([settings]);
  }

  void select(int id) async {
    final database = await _getDatabase();
    final all = await database.settingsDao.getAll();
    final edited = all.map((it) {
      final selected = it.id == id;
      return it.copy(selected: selected);
    }).toList();
    await database.settingsDao.updateAll(edited);
  }
}
