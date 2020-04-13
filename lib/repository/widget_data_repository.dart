import 'package:desktop_game_helper/model/widget_data.dart';
import 'package:desktop_game_helper/repository/app_database.dart';
import 'package:desktop_game_helper/repository/widget_data_dao.dart';

class WidgetDataRepository {
  Future<WidgetDataDao> get dao async {
    _dao ??= (await $FloorAppDatabase.databaseBuilder('app.db').build())
        .widgetDataDao;
    return _dao;
  }

  WidgetDataDao _dao;

  List<WidgetDataEntity> _data = [];

  WidgetData get(int index) {
    return _data
        .firstWhere((element) => element.id == index, orElse: () => null)
        ?.data;
  }

  void fetch() async {
    _data = await (await dao).getAll();
  }

  void addAtSync(WidgetData data, int index) {
    final newEntity = WidgetDataEntity.build(index, data);
    _data.add(newEntity);
    _add(newEntity);
  }

  void _add(WidgetDataEntity entity) async {
    await (await dao).addAll([entity]);
  }

  void updateAtSync(WidgetData data, int index) {
    final updated = WidgetDataEntity.build(index, data);
    _data[index] = updated;
    _update(updated);
  }

  void _update(WidgetDataEntity entity) async {
    await (await dao).updateAll([entity]);
  }

  void removeAt(int index) async {
    final edited = _data.toList();
    edited.removeAt(index);
    _rearrangeIds(edited);
    _data = edited;
    await _writeAll();
  }

  void reorderSync(int oldIndex, int newIndex) {
    final edited = _data.toList();
    final reorderedItem = edited.removeAt(oldIndex);
    edited.insert(newIndex, reorderedItem);
    _rearrangeIds(edited);
    _data = edited;
    _writeAll();
  }

  void _writeAll() async {
    final dao = await this.dao;
    await dao.clear();
    await dao.addAll(_data);
  }

  void _rearrangeIds(List<WidgetDataEntity> list) {
    final copy = list.toList();
    list.clear();
    copy.asMap().forEach((index, value) {
      list.add(WidgetDataEntity(index, value.dataText));
    });
  }
}
