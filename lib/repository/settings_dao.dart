import 'package:desktop_game_helper/model/settings.dart';
import 'package:floor/floor.dart';

@dao
abstract class SettingsDao {
  @Query('SELECT * FROM Settings')
  Future<List<Settings>> getAll();

  @insert
  Future<void> addAll(List<Settings> settingsList);

  @Query('DELETE FROM Settings')
  Future<void> clear();
}
