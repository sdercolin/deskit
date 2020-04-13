import 'package:desktop_game_helper/model/widget_data.dart';
import 'package:floor/floor.dart';

@dao
abstract class WidgetDataDao {
  @Query('SELECT * FROM WidgetDataEntity')
  Future<List<WidgetDataEntity>> getAll();

  @Query('SELECT * FROM WidgetDataEntity WHERE id = :id')
  Future<List<WidgetDataEntity>> get(int id);

  @update
  Future<int> updateAll(List<WidgetDataEntity> widgetDataEntities);

  @insert
  Future<void> addAll(List<WidgetDataEntity> widgetDataEntities);

  @delete
  Future<int> deleteAll(List<WidgetDataEntity> widgetDataEntities);

  @Query('DELETE FROM WidgetDataEntity')
  Future<void> clear();
}
