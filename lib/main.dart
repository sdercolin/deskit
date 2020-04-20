import 'dart:async';

import 'package:deskit/add_widget_page.dart';
import 'package:deskit/common/snack_bar_util.dart';
import 'package:deskit/consts/presets.dart';
import 'package:deskit/deskit_widget.dart';
import 'package:deskit/edit_widget_page.dart';
import 'package:deskit/model/settings.dart';
import 'package:deskit/repository/settings_repository.dart';
import 'package:deskit/repository/widget_data_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:wakelock/wakelock.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'Deskit';

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return GestureDetector(
      onTap: () {
        final currentFocus = FocusScope.of(context);
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
        home: HomePage(title: title),
        routes: {
          EditWidgetPage.routeName: (context) => EditWidgetPage(),
          AddWidgetPage.routeName: (context) => AddWidgetPage(),
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final key = GlobalKey<HomePageState>();

  var _reordering = false;

  final default_settings = Presets.defaultSettings;

  final _settingsRepository = SettingsRepository();
  final _widgetDataRepository = WidgetDataRepository();

  final _streamController = StreamController<Settings>.broadcast();

  final _slidableController = SlidableController();

  final _myWidgetStateKeys = <GlobalKey<DeskitWidgetState>>[];

  void _updateAsync() async {
    await _widgetDataRepository.fetch();
    await _settingsRepository.fetch();
    _update();
  }

  void _update() {
    final value = _settingsRepository.getCurrent();
    if (value == null) {
      _writeDefaultSettings();
      _streamController.add(default_settings);
    } else {
      _streamController.add(value);
    }
  }

  void resetFocus() {
    _myWidgetStateKeys.forEach((element) {
      element.currentState.unfocus();
    });
  }

  void _writeDefaultSettings() async {
    await _settingsRepository.add(default_settings);
    await _settingsRepository.select(default_settings.id);
  }

  void _confirmRemoveWidget(BuildContext context, int index) {
    resetFocus();
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
              final current = _settingsRepository.getCurrent();
              final edited = current.removeConfigItemAt(index);
              await _settingsRepository.update(edited);
              await _widgetDataRepository.removeAt(index);
              Navigator.pop(context);
              _update();
            },
          ),
        ],
      ),
    );
  }

  void _confirmResetAll(BuildContext context) {
    resetFocus();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Reset all widgets'),
        content: Text('Are you sure to reset all widgets?'),
        actions: <Widget>[
          FlatButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          FlatButton(
            child: Text('Reset'),
            onPressed: () async {
              _myWidgetStateKeys.forEach((key) {
                key.currentState.reset();
              });
              Navigator.pop(context);
              resetFocus();
            },
          ),
        ],
      ),
    );
  }

  void _resetWidget(int index) async {
    _myWidgetStateKeys[index].currentState.reset();
    resetFocus();
  }

  void _editWidget(BuildContext context, Settings settings, int index) async {
    resetFocus();
    final result = await Navigator.pushNamed(
      context,
      EditWidgetPage.routeName,
      arguments: EditWidgetPageArguments(settings.configs[index]),
    ) as EditWidgetPageResult;

    final config = result?.config;

    if (config != null) {
      final current = _settingsRepository.getCurrent();
      final configs = current.configs.toList();
      configs[index] = config;
      final edited = current.copy(configs: configs);
      await _settingsRepository.update(edited);
      if (result?.requestResetData == true) {
        await _widgetDataRepository.removeAt(index);
      }
      _update();

      SnackBarUtil.show(context, 'You have edited a widget.');
    }
  }

  void _toggleReordering(BuildContext context) {
    resetFocus();
    setState(() {
      _reordering = !_reordering;
    });
    if (_reordering) {
      SnackBarUtil.show(
          context, 'You can now long press widgets to reorder them.');
    }
  }

  void _reorderWidget(int oldIndex, int newIndex) {
    final currentSettings = _settingsRepository.getCurrent();
    final configs = currentSettings.configs.toList();
    final moved = configs.removeAt(oldIndex);
    configs.insert(newIndex, moved);
    final editedSettings = currentSettings.copy(configs: configs);

    // Use sync methods To shorten processing time
    _settingsRepository.updateSync(editedSettings);
    _widgetDataRepository.reorderSync(oldIndex, newIndex);

    _update();
  }

  void _addWidget(BuildContext context) async {
    final currentSettings = _settingsRepository.getCurrent();
    final result = await Navigator.pushNamed(context, AddWidgetPage.routeName,
            arguments: AddWidgetPageArguments(currentSettings))
        as EditWidgetPageResult;
    if (result?.config != null) {
      final current = _settingsRepository.getCurrent();
      final configs = current.configs.toList();
      configs.add(result?.config);
      final edited = current.copy(configs: configs);
      await _settingsRepository.update(edited);
      _update();

      SnackBarUtil.show(context, 'You have successfully added a widget.');
    }
  }

  @override
  void initState() {
    _updateAsync();
    super.initState();
  }

  Widget _buildWidgets(BuildContext context, Settings settings) {
    _myWidgetStateKeys.clear();
    final widgetWrappers = <Widget>[];
    settings.configs.asMap().forEach((index, config) {
      final widgetKey = GlobalKey<DeskitWidgetState>();
      _myWidgetStateKeys.add(widgetKey);
      final widget =
          config.build(index, _widgetDataRepository, widgetKey, key, this);
      widgetWrappers.add(Wrap(
        key: Key(index.toString()),
        children: [
          Slidable(
            controller: _slidableController,
            actionPane: SlidableDrawerActionPane(),
            child: Column(
              children: <Widget>[
                widget,
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
                onTap: () => _confirmRemoveWidget(context, index),
              ),
              IconSlideAction(
                caption: 'Edit',
                color: Colors.amber,
                icon: Icons.settings,
                onTap: () => _editWidget(context, settings, index),
              ),
            ],
            secondaryActions: [
              IconSlideAction(
                caption: 'Reset',
                color: Color.alphaBlend(Colors.white70, Colors.amber),
                icon: Icons.refresh,
                onTap: () => _resetWidget(index),
              ),
            ],
          )
        ],
      ));
    });
    return _reordering
        ? ReorderableListView(
            onReorder: (int oldIndex, int newIndex) {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              _reorderWidget(oldIndex, newIndex);
            },
            children: widgetWrappers,
          )
        : ListView(
            primary: false,
            children: widgetWrappers,
          );
  }

  @override
  Widget build(BuildContext context) {
    Wakelock.enable();
    return Scaffold(
      key: key,
      appBar: AppBar(
        title: _reordering ? Text('Reorder widgets') : Text(widget.title),
        centerTitle: false,
        actions: _reordering
            ? <Widget>[
                Builder(
                    builder: (context) => IconButton(
                          icon: Icon(Icons.done),
                          onPressed: () => _toggleReordering(context),
                        )),
              ]
            : <Widget>[
                Builder(
                    builder: (context) => IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: () => _confirmResetAll(context),
                        )),
                Builder(
                    builder: (context) => IconButton(
                          icon: Icon(Icons.import_export),
                          onPressed: () => _toggleReordering(context),
                        )),
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
              return _buildWidgets(context, snapshot.data);
            }
          }),
    );
  }
}
