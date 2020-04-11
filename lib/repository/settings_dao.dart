import 'package:desktop_game_helper/model/settings.dart';
import 'package:floor/floor.dart';

@dao
abstract class SettingsDao {
  @Query('SELECT * FROM Settings')
  Future<List<Settings>> getAll();

  @Query('SELECT * FROM Settings WHERE id = :id')
  Future<Settings> get(int id);

  @update
  Future<int> updateAll(List<Settings> settingsList);

  @insert
  Future<void> add(Settings settings);

  @delete
  Future<int> deleteAll(List<Settings> settings);
}
