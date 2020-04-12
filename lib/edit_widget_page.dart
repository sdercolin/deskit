import 'package:desktop_game_helper/model/config.dart';
import 'package:desktop_game_helper/model/value_keeper_config.dart';
import 'package:desktop_game_helper/value_keeper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'common/text_edit_alert_dialog.dart';
import 'consts/style.dart';
import 'model/widget_type_info.dart';

class EditWidgetPage extends StatefulWidget {
  static const routeName = '/editWidget';

  @override
  EditWidgetPageState createState() => EditWidgetPageState();
}

class EditWidgetPageState extends State<EditWidgetPage> {
  Config currentConfig;

  void update(Function() updateFunction) {
    setState(() {
      updateFunction.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final EditWidgetPageArguments args =
        ModalRoute.of(context).settings.arguments;

    currentConfig ??= args.originalConfig.copy();

    final preview = currentConfig.build(null, null);
    final list = currentConfig.buildEditList(this);
    final typeName = currentConfig.typeInfo.name;
    final title =
        args.isNew ? 'Add widget: $typeName' : 'Edit widget: $typeName';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
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

class EditWidgetPageArguments {
  final Config originalConfig;
  final bool isNew;

  EditWidgetPageArguments(this.originalConfig, {this.isNew = false});
}

abstract class ConfigEditList<T extends Config> extends StatelessWidget {
  final T originalConfig;
  final EditWidgetPageState parentState;

  ConfigEditList(this.originalConfig, this.parentState);

  List<Widget> buildList(BuildContext context, T config);

  @override
  Widget build(BuildContext context) {
    final contents = buildList(context, parentState.currentConfig);
    return SingleChildScrollView(
      child: Column(
        children: [
          Column(
            children: contents,
          ),
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
      Config originalConfig, EditWidgetPageState parentState)
      : super(originalConfig, parentState);

  @override
  List<Widget> buildList(BuildContext context, ValueKeeperConfig config) {
    final itemPadding = EdgeInsets.symmetric(horizontal: 20);
    final itemConstraints = BoxConstraints(minHeight: 60);

    return [
      Container(
        constraints: itemConstraints,
        padding: itemPadding,
        child: Row(
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
      ),
      InkWell(
        child: Container(
          constraints: itemConstraints,
          padding: itemPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                child: Text(
                  'Edit display name',
                  textAlign: TextAlign.left,
                  style: Style.PreferenceTitle,
                ),
              ),
              Container(
                constraints: BoxConstraints(maxWidth: 200),
                child: config.name?.isNotEmpty == true
                    ? Text(
                        config.name,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      )
                    : Text(
                        'Undefined',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
              ),
            ],
          ),
        ),
        onTap: () async {
          final result = await TextFieldAlertDialog.show(
              context, 'Edit display name', config.name ?? '');
          if (result != null) {
            parentState.update(() {
              config.name = result;
            });
          }
        },
      ),
      InkWell(
        child: Container(
          constraints: itemConstraints,
          padding: itemPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                child: Text(
                  'Interval',
                  textAlign: TextAlign.left,
                  style: Style.PreferenceTitle,
                ),
              ),
              Container(
                child: Text(config.interval.toString()),
              ),
            ],
          ),
        ),
        onTap: () async {
          final result = await TextFieldAlertDialog.show(
              context, 'Edit interval', config.interval.toString() ?? '',
              inputType: TextInputType.number);
          if (result != null) {
            final intResult = int.tryParse(result);
            final max = ValueKeeperConfig.maxInterval;
            if (intResult != null && intResult > 0 && intResult <= max) {
              parentState.update(() {
                config.interval = intResult;
              });
            } else {
              Scaffold.of(context)
                ..removeCurrentSnackBar()
                ..showSnackBar(SnackBar(
                    content: Text(
                        'Interval should be an integer between 1 and $max.')));
            }
          }
        },
      ),
      Container(
        constraints: itemConstraints,
        padding: itemPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Text(
                'Display interval',
                textAlign: TextAlign.left,
                style: Style.PreferenceTitle,
              ),
            ),
            Container(
              child: Checkbox(
                value: config.displayInterval,
                onChanged: (value) {
                  parentState.update(() {
                    config.displayInterval = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 10),
    ];
  }
}