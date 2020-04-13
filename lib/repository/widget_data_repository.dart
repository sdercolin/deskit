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

  List<WidgetDataEntity> _cache = [];

  WidgetData get(int index) {
    return _cache
        .firstWhere((element) => element.id == index, orElse: () => null)
        ?.data;
  }

  void fetch() async {
    _cache = await (await dao).getAll();
  }

  void addAt(WidgetData data, int index) async {
    final newEntity = WidgetDataEntity.build(index, data);
    await (await dao).addAll([newEntity]);
    await fetch();
  }

  void add(WidgetData data) async {
    final all = await (await dao).getAll();
    final newId = all.length;
    await addAt(data, newId);
  }

  void updateAt(WidgetData data, int index) async {
    final updated = WidgetDataEntity.build(index, data);
    await (await dao).updateAll([updated]);
    await fetch();
  }

  void removeAt(int index) async {
    final dao = await this.dao;
    final all = await dao.getAll();
    final edited = all.toList();
    edited.removeAt(index);
    _rearrangeIds(edited);
    await dao.deleteAll(all);
    await dao.addAll(edited);
    await fetch();
  }

  void reorder(int oldIndex, int newIndex) async {
    final dao = await this.dao;
    final all = await dao.getAll();
    final edited = all.toList();
    final reorderedItem = edited.removeAt(oldIndex);
    edited.insert(newIndex, reorderedItem);
    _rearrangeIds(edited);
    await dao.deleteAll(all);
    await dao.addAll(edited);
    await fetch();
  }

  void _rearrangeIds(List<WidgetDataEntity> list) {
    final copy = list.toList();
    list.clear();
    copy.asMap().forEach((index, value) {
      list.add(WidgetDataEntity(index, value.dataText));
    });
  }
}
