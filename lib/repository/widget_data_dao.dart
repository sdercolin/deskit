import 'package:desktop_game_helper/model/widget_data.dart';
import 'package:floor/floor.dart';

@dao
abstract class WidgetDataDao {
  @Query('SELECT * FROM WidgetDataEntity')
  Future<List<WidgetDataEntity>> getAll();

  @insert
  Future<void> addAll(List<WidgetDataEntity> widgetDataEntities);

  @Query('DELETE FROM WidgetDataEntity')
  Future<void> clear();
}
