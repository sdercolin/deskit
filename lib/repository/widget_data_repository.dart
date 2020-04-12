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
    final removed = all.toList();
    removed.removeAt(index);
    final edited = <WidgetDataEntity>[];
    var id = 0;
    for (var item in removed) {
      edited.add(WidgetDataEntity(id, item.dataText));
      id++;
    }
    await dao.deleteAll(all);
    await dao.addAll(edited);
    await fetch();
  }
}
