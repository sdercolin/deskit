import 'package:deskit/common/snack_bar_util.dart';
import 'package:deskit/model/coin_config.dart';
import 'package:deskit/model/config.dart';
import 'package:deskit/model/value_keeper_config.dart';
import 'package:deskit/value_keeper.dart';
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

    final preview = currentConfig.build(null, null, null);
    final list = currentConfig.buildEditList(this);
    final typeName = currentConfig.typeInfo.name;
    final title =
        args.isNew ? 'Add widget: $typeName' : 'Edit widget: $typeName';
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
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

  final itemPadding = EdgeInsets.symmetric(horizontal: 20);
  final itemConstraints = BoxConstraints(minHeight: 60);

  List<Widget> buildList(BuildContext context, T config);

  @override
  Widget build(BuildContext context) {
    final contents = buildList(context, parentState.currentConfig);
    return Flexible(
      child: ListView.builder(itemBuilder: (context, index) {
        if (index < contents.length) {
          return contents[index];
        } else if (index == contents.length) {
          return ButtonBar(
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
          );
        } else {
          return null;
        }
      }),
    );
  }
}

class ValueKeeperConfigEditList extends ConfigEditList<ValueKeeperConfig> {
  ValueKeeperConfigEditList(
      Config originalConfig, EditWidgetPageState parentState)
      : super(originalConfig, parentState);

  @override
  List<Widget> buildList(BuildContext context, ValueKeeperConfig config) {
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
                  'Display name',
                  textAlign: TextAlign.left,
                  style: Style.PreferenceTitle,
                ),
              ),
              Container(
                constraints: BoxConstraints(maxWidth: 200),
                child: config.name.isNotEmpty
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
              context, 'Edit display name', config.name);
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
                  'Initial value',
                  textAlign: TextAlign.left,
                  style: Style.PreferenceTitle,
                ),
              ),
              Container(
                child: Text(config.initialValue.toString()),
              ),
            ],
          ),
        ),
        onTap: () async {
          final result = await TextFieldAlertDialog.show(
              context, 'Edit initial value', config.initialValue.toString(),
              inputType: TextInputType.number);
          if (result != null) {
            final intResult = int.tryParse(result);
            final min = -ValueKeeperConfig.maxAbsoluteValue;
            final max = ValueKeeperConfig.maxAbsoluteValue;
            if (intResult != null && intResult >= min && intResult <= max) {
              parentState.update(() {
                config.initialValue = intResult;
              });
            } else {
              SnackBarUtil.show(context,
                  'Initial value should be an integer between $min and $max.');
            }
          }
        },
      ),
      config.requestIntervalEveryTime
          ? null
          : InkWell(
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
                    context, 'Edit interval', config.interval.toString(),
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
      config.requestIntervalEveryTime
          ? null
          : Container(
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
                    child: Switch(
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
      Container(
        constraints: itemConstraints,
        padding: itemPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Text(
                'Request interval every time',
                textAlign: TextAlign.left,
                style: Style.PreferenceTitle,
              ),
            ),
            Container(
              child: Switch(
                value: config.requestIntervalEveryTime,
                onChanged: (value) {
                  parentState.update(() {
                    config.requestIntervalEveryTime = value;
                    if (value) {
                      config.displayInterval = false;
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 10),
    ].where((element) => element != null).toList();
  }
}

class CoinConfigEditList extends ConfigEditList<CoinConfig> {
  CoinConfigEditList(CoinConfig originalConfig, EditWidgetPageState parentState)
      : super(originalConfig, parentState);

  @override
  List<Widget> buildList(BuildContext context, CoinConfig config) {
    return [
      InkWell(
        child: Container(
          constraints: itemConstraints,
          padding: itemPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                child: Text(
                  'Display name',
                  textAlign: TextAlign.left,
                  style: Style.PreferenceTitle,
                ),
              ),
              Container(
                constraints: BoxConstraints(maxWidth: 200),
                child: config.name.isNotEmpty
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
              context, 'Edit display name', config.name);
          if (result != null) {
            parentState.update(() {
              config.name = result;
            });
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
                'Show history',
                textAlign: TextAlign.left,
                style: Style.PreferenceTitle,
              ),
            ),
            Container(
              child: Switch(
                value: config.showHistory,
                onChanged: (value) {
                  parentState.update(() {
                    config.showHistory = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      Container(
        constraints: itemConstraints,
        padding: itemPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Text(
                'Long press to request multiple',
                textAlign: TextAlign.left,
                style: Style.PreferenceTitle,
              ),
            ),
            Container(
              child: Switch(
                value: config.longPressMultiple,
                onChanged: (value) {
                  parentState.update(() {
                    config.longPressMultiple = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      Container(
        constraints: itemConstraints,
        padding: itemPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Text(
                'Popup result',
                textAlign: TextAlign.left,
                style: Style.PreferenceTitle,
              ),
            ),
            Container(
              child: Switch(
                value: config.popupResult,
                onChanged: (value) {
                  parentState.update(() {
                    config.popupResult = value;
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
