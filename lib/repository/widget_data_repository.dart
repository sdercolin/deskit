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

  void _writeAll() async {
    final dao = await this.dao;
    await dao.clear();
    await dao.addAll(_data);
  }

  void addAt(WidgetData data, int index) {
    final newEntity = WidgetDataEntity.build(index, data);
    _data.add(newEntity);
    _writeAll();
  }

  void add(WidgetData data) {
    final newId = _data.length;
    addAt(data, newId);
  }

  void updateAt(WidgetData data, int index) {
    final updated = WidgetDataEntity.build(index, data);
    _data[index] = updated;
    _writeAll();
  }

  void removeAt(int index) {
    final edited = _data.toList();
    edited.removeAt(index);
    _rearrangeIds(edited);
    _data = edited;
    _writeAll();
  }

  void reorder(int oldIndex, int newIndex) async {
    final edited = _data.toList();
    final reorderedItem = edited.removeAt(oldIndex);
    edited.insert(newIndex, reorderedItem);
    _rearrangeIds(edited);
    _data = edited;
    _writeAll();
  }

  void _rearrangeIds(List<WidgetDataEntity> list) {
    final copy = list.toList();
    list.clear();
    copy.asMap().forEach((index, value) {
      list.add(WidgetDataEntity(index, value.dataText));
    });
  }
}
