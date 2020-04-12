import 'dart:async';

import 'package:desktop_game_helper/configuration_page.dart';
import 'package:desktop_game_helper/repository/settings_repository.dart';
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
          ConfigurationPage.routeName: (context) => ConfigurationPage(),
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
      ValueKeeperConfig(ValueKeeperStyle.LARGE),
      ValueKeeperConfig(ValueKeeperStyle.SMALL),
      ValueKeeperConfig(ValueKeeperStyle.LARGE,
          displayInterval: true,
          interval: 100,
          name: 'counter 3 counter 3 counter 3 counter 3 counter 3 counter 3'),
      ValueKeeperConfig(ValueKeeperStyle.SMALL,
          displayInterval: true, interval: 100, name: 'counter 4'),
    ],
    'default',
    true,
  );

  final _settingsRepository = SettingsRepository();

  final _streamController = StreamController<Settings>.broadcast();

  final _slidableController = SlidableController();

  void _updateAsync() async {
    final value = await _settingsRepository.getCurrent();
    if (value == null) {
      _settingsRepository.add(default_settings);
      _settingsRepository.select(default_settings.id);
      _streamController.add(default_settings);
    } else {
      _streamController.add(value);
    }
  }

  @override
  void initState() {
    _updateAsync();
    super.initState();
  }

  Widget _buildList(Settings settings) {
    return ListView.separated(
      itemBuilder: (context, index) {
        if (settings.configs.length <= index) {
          return null;
        }
        return Slidable(
          key: Key(index.toString()),
          controller: _slidableController,
          actionPane: SlidableDrawerActionPane(),
          child: settings.configs[index].build(),
          actions: <Widget>[
            IconSlideAction(
              caption: 'Remove',
              color: Colors.red,
              icon: Icons.delete,
              onTap: () => showDialog(
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
                        Navigator.pop(context);
                        _updateAsync();
                      },
                    ),
                  ],
                ),
              ),
            ),
            IconSlideAction(
              caption: 'Edit',
              color: Colors.amber,
              icon: Icons.settings,
              onTap: () async {
                final result = await Navigator.pushNamed(
                  context,
                  ConfigurationPage.routeName,
                  arguments:
                      ConfigurationPageArguments(settings.configs[index]),
                );

                if (result != null) {
                  final current = await _settingsRepository.getCurrent();
                  final configs = current.configs.toList();
                  configs[index] = result;
                  final edited = current.copy(configs: configs);
                  await _settingsRepository.update(edited);
                  await _updateAsync();

                  Scaffold.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(
                        SnackBar(content: Text('Configuration edited.')));
                }
              },
            ),
          ],
        );
      },
      itemCount: settings.configs.length,
      separatorBuilder: (_, __) => Divider(
        height: 0.3,
        color: Color.alphaBlend(Colors.white70, Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
