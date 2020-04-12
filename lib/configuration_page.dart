import 'package:desktop_game_helper/model/config.dart';
import 'package:desktop_game_helper/model/value_keeper_config.dart';
import 'package:desktop_game_helper/value_keeper.dart';
import 'package:flutter/material.dart';

import 'consts/style.dart';

class ConfigurationPage extends StatefulWidget {
  static const routeName = '/configure';

  @override
  ConfigurationPageState createState() => ConfigurationPageState();
}

class ConfigurationPageState extends State<ConfigurationPage> {
  Config currentConfig;

  void update(Function() updateFunction) {
    setState(() {
      updateFunction.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ConfigurationPageArguments args =
        ModalRoute.of(context).settings.arguments;

    currentConfig ??= args.originalConfig.copy();

    final preview = currentConfig.build();
    final list = currentConfig.buildEditList(this);
    return Scaffold(
      appBar: AppBar(
        title: Text(list.title),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: preview,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Divider(
              height: 0.3,
              color: Color.alphaBlend(Colors.white70, Colors.grey),
            ),
          ),
          list
        ],
      ),
    );
  }
}

class ConfigurationPageArguments {
  final Config originalConfig;

  ConfigurationPageArguments(this.originalConfig);
}

abstract class ConfigEditList<T extends Config> extends StatelessWidget {
  final T originalConfig;
  final String title;
  final ConfigurationPageState parentState;

  ConfigEditList(this.originalConfig, this.parentState)
      : title = originalConfig.getEditPageTitle();

  List<Widget> buildList(T config);

  @override
  Widget build(BuildContext context) {
    final contents = buildList(parentState.currentConfig);
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: contents,
            ),
          ),
          SizedBox(height: 15),
          ButtonBar(
            buttonPadding: EdgeInsets.all(15),
            children: <Widget>[
              RaisedButton(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context, null);
                },
              ),
              RaisedButton(
                color: Colors.amber,
                textColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text('Save'),
                onPressed: () {
                  Navigator.pop(context, parentState.currentConfig);
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}

class ValueKeeperConfigEditList extends ConfigEditList<ValueKeeperConfig> {
  ValueKeeperConfigEditList(
      Config originalConfig, ConfigurationPageState parentState)
      : super(originalConfig, parentState);

  @override
  List<Widget> buildList(ValueKeeperConfig config) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Text(
              'Style',
              textAlign: TextAlign.left,
              style: Style.PreferenceTitle,
            ),
          ),
          DropdownButton<ValueKeeperStyle>(
            value: config.style,
            elevation: 16,
            underline: Container(height: 2),
            items: ValueKeeperStyle.values
                .map((ValueKeeperStyle value) =>
                    DropdownMenuItem<ValueKeeperStyle>(
                      value: value,
                      child: Text(value.displayName),
                    ))
                .toList(),
            onChanged: (ValueKeeperStyle value) {
              parentState.update(() {
                config.style = value;
              });
            },
          ),
        ],
      ),
    ];
  }
}
