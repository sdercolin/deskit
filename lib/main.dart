import 'dart:async';

import 'package:desktop_game_helper/add_widget_page.dart';
import 'package:desktop_game_helper/common/snack_bar_util.dart';
import 'package:desktop_game_helper/edit_widget_page.dart';
import 'package:desktop_game_helper/repository/settings_repository.dart';
import 'package:desktop_game_helper/repository/widget_data_repository.dart';
import 'package:desktop_game_helper/value_keeper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'model/settings.dart';
import 'model/value_keeper_config.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'Desktop Game Helper (devcode)';
    return GestureDetector(
      onTap: () {
        var currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.requestFocus(FocusNode());
        }
      },
      child: MaterialApp(
        title: title,
        theme: ThemeData(
          primarySwatch: Colors.amber,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(title: title),
        routes: {
          EditWidgetPage.routeName: (context) => EditWidgetPage(),
          AddWidgetPage.routeName: (context) => AddWidgetPage(),
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final default_settings = Settings.build(
    0,
    [
      ValueKeeperConfig(style: ValueKeeperStyle.LARGE),
      ValueKeeperConfig(style: ValueKeeperStyle.SMALL),
      ValueKeeperConfig(
          style: ValueKeeperStyle.LARGE,
          displayInterval: true,
          interval: 100,
          name: 'counter 3 counter 3 counter 3 counter 3 counter 3 counter 3'),
      ValueKeeperConfig(
          style: ValueKeeperStyle.SMALL,
          displayInterval: true,
          interval: 100,
          name: 'counter 4'),
    ],
    'default',
    true,
  );

  final _settingsRepository = SettingsRepository();
  final _widgetDataRepository = WidgetDataRepository();

  final _streamController = StreamController<Settings>.broadcast();

  final _slidableController = SlidableController();

  void _updateAsync() async {
    await _widgetDataRepository.fetch();
    final value = await _settingsRepository.getCurrent();
    if (value == null) {
      _settingsRepository.add(default_settings);
      _settingsRepository.select(default_settings.id);
      _streamController.add(default_settings);
    } else {
      _streamController.add(value);
    }
  }

  void _showRemoveConfirmDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Remove widget'),
        content: Text('Are you sure to remove this widget?'),
        actions: <Widget>[
          FlatButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          FlatButton(
            child: Text('Remove'),
            onPressed: () async {
              final current = await _settingsRepository.getCurrent();
              final edited = current.removeConfigItemAt(index);
              await _settingsRepository.update(edited);
              await _widgetDataRepository.removeAt(index);
              Navigator.pop(context);
              _updateAsync();
            },
          ),
        ],
      ),
    );
  }

  void _editWidget(BuildContext context, Settings settings, int index) async {
    final result = await Navigator.pushNamed(
      context,
      EditWidgetPage.routeName,
      arguments: EditWidgetPageArguments(settings.configs[index]),
    );

    if (result != null) {
      final current = await _settingsRepository.getCurrent();
      final configs = current.configs.toList();
      configs[index] = result;
      final edited = current.copy(configs: configs);
      await _settingsRepository.update(edited);
      await _updateAsync();

      SnackBarUtil.show(context, 'You have edited a widget.');
    }
  }

  void _reorderWidget(int oldIndex, int newIndex) async {
    // update settings
    final currentSettings = await _settingsRepository.getCurrent();
    final configs = currentSettings.configs.toList();
    final moved = configs.removeAt(oldIndex);
    configs.insert(newIndex, moved);
    final editedSettings = currentSettings.copy(configs: configs);
    await _settingsRepository.update(editedSettings);

    // update data
    await _widgetDataRepository.reorder(oldIndex, newIndex);

    await _updateAsync();
  }

  void _addWidget(BuildContext context) async {
    final result = await Navigator.pushNamed(context, AddWidgetPage.routeName);
    if (result != null) {
      final current = await _settingsRepository.getCurrent();
      final configs = current.configs.toList();
      configs.add(result);
      final edited = current.copy(configs: configs);
      await _settingsRepository.update(edited);
      await _updateAsync();

      SnackBarUtil.show(context, 'You have successfully added a widget.');
    }
  }

  @override
  void initState() {
    _updateAsync();
    super.initState();
  }

  Widget _buildList(Settings settings) {
    final items = <Widget>[];
    settings.configs.asMap().forEach((index, config) {
      items.add(Wrap(
        key: Key(index.toString()),
        children: [
          Slidable(
            controller: _slidableController,
            actionPane: SlidableDrawerActionPane(),
            child: Column(
              children: <Widget>[
                config.build(_widgetDataRepository, index),
                Divider(
                  height: 0.3,
                  color: Color.alphaBlend(Colors.white70, Colors.grey),
                ),
              ],
            ),
            actions: <Widget>[
              IconSlideAction(
                caption: 'Remove',
                color: Colors.red,
                icon: Icons.delete,
                onTap: () => _showRemoveConfirmDialog(context, index),
              ),
              IconSlideAction(
                caption: 'Edit',
                color: Colors.amber,
                icon: Icons.settings,
                onTap: () => _editWidget(context, settings, index),
              ),
            ],
          )
        ],
      ));
    });
    return ReorderableListView(
      onReorder: (int oldIndex, int newIndex) {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        _reorderWidget(oldIndex, newIndex);
      },
      children: items,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          Builder(
              builder: (context) => IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => _addWidget(context),
                  )),
        ],
      ),
      backgroundColor: Color.alphaBlend(Colors.black12, Colors.white),
      body: StreamBuilder(
          stream: _streamController.stream,
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Container(
                color: Colors.white,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else {
              return _buildList(snapshot.data);
            }
          }),
    );
  }
}
