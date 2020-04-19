import 'dart:io';

import 'package:deskit/common/snack_bar_util.dart';
import 'package:deskit/common/text_edit_alert_dialog.dart';
import 'package:deskit/common/time_picker_alert_dialog.dart';
import 'package:deskit/common/time_util.dart';
import 'package:deskit/consts/style.dart';
import 'package:deskit/model/coin_config.dart';
import 'package:deskit/model/config.dart';
import 'package:deskit/model/dice_config.dart';
import 'package:deskit/model/timer_config.dart';
import 'package:deskit/model/value_keeper_config.dart';
import 'package:deskit/model/widget_type_info.dart';
import 'package:deskit/value_keeper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class EditWidgetPage extends StatefulWidget {
  static const routeName = '/editWidget';

  @override
  EditWidgetPageState createState() => EditWidgetPageState();
}

class EditWidgetPageState extends State<EditWidgetPage> {
  final key = GlobalKey<ScaffoldState>();

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

    final preview = currentConfig.build(null, null, null, key, this);
    final list = currentConfig.buildEditList(this);
    final typeName = currentConfig.typeInfo.name;
    final title =
        args.isNew ? 'Add widget: $typeName' : 'Edit widget: $typeName';
    return Scaffold(
      key: key,
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
    return <Widget>[
      _DropdownConfigItem<ValueKeeperStyle>(
        parentState,
        'Style',
        () => config.style,
        (value) => config.style = value,
        ValueKeeperStyle.values,
        ValueKeeperStyle.values.map((e) => e.displayName).toList(),
      ).build(),
      _StringEditConfigItem(
        context,
        parentState,
        'Display name',
        () => config.name,
        (value) => config.name = value,
      ).build(),
      _IntegerEditConfigItem(
        context,
        parentState,
        'Initial value',
        -ValueKeeperConfig.maxAbsoluteValue,
        ValueKeeperConfig.maxAbsoluteValue,
        () => config.initialValue,
        (value) => config.initialValue = value,
      ).build(),
      _IntegerEditConfigItem(
        context,
        parentState,
        'Interval',
        1,
        ValueKeeperConfig.maxInterval,
        () => config.interval,
        (value) => config.interval = value,
        isVisible: !config.requestIntervalEveryTime,
      ).build(),
      _SwitchConfigItem(
        parentState,
        'Display interval',
        () => config.displayInterval,
        (value) => config.displayInterval = value,
        isVisible: !config.requestIntervalEveryTime,
      ).build(),
      _SwitchConfigItem(
        parentState,
        'Ask for interval every time',
        () => config.requestIntervalEveryTime,
        (value) {
          config.requestIntervalEveryTime = value;
          if (value) {
            config.displayInterval = false;
          }
        },
      ).build(),
      SizedBox(height: 10),
    ].where((element) => element != null).toList();
  }
}

class CoinConfigEditList extends ConfigEditList<CoinConfig> {
  CoinConfigEditList(CoinConfig originalConfig, EditWidgetPageState parentState)
      : super(originalConfig, parentState);

  @override
  List<Widget> buildList(BuildContext context, CoinConfig config) {
    return <Widget>[
      _StringEditConfigItem(
        context,
        parentState,
        'Display name',
        () => config.name,
        (value) => config.name = value,
      ).build(),
      _SwitchConfigItem(
        parentState,
        'Show history',
        () => config.showHistory,
        (value) => config.showHistory = value,
      ).build(),
      _SwitchConfigItem(
        parentState,
        'Long press to request multiple',
        () => config.longPressMultiple,
        (value) => config.longPressMultiple = value,
      ).build(),
      _SwitchConfigItem(
        parentState,
        'Popup result',
        () => config.popupResult,
        (value) => config.popupResult = value,
      ).build(),
      SizedBox(height: 10),
    ];
  }
}

class DiceConfigEditList extends ConfigEditList<DiceConfig> {
  DiceConfigEditList(DiceConfig originalConfig, EditWidgetPageState parentState)
      : super(originalConfig, parentState);

  @override
  List<Widget> buildList(BuildContext context, DiceConfig config) {
    return <Widget>[
      _StringEditConfigItem(
        context,
        parentState,
        'Display name',
        () => config.name,
        (value) => config.name = value,
      ).build(),
      _IntegerEditConfigItem(
        context,
        parentState,
        'Number of sides',
        DiceConfig.minSides,
        DiceConfig.maxSides,
        () => config.sides,
        (value) => config.sides = value,
        isVisible: !config.requestSidesEveryTime,
      ).build(),
      _SwitchConfigItem(
        parentState,
        'Show history',
        () => config.showHistory,
        (value) => config.showHistory = value,
      ).build(),
      _SwitchConfigItem(
        parentState,
        'Long press to request multiple',
        () => config.longPressMultiple,
        (value) => config.longPressMultiple = value,
      ).build(),
      _SwitchConfigItem(
        parentState,
        'Popup result',
        () => config.popupResult,
        (value) => config.popupResult = value,
      ).build(),
      _SwitchConfigItem(
        parentState,
        'Ask for number of sides every time',
        () => config.requestSidesEveryTime,
        (value) => config.requestSidesEveryTime = value,
      ).build(),
      SizedBox(height: 10),
    ];
  }
}

class TimerConfigEditList extends ConfigEditList<TimerConfig> {
  TimerConfigEditList(
      TimerConfig originalConfig, EditWidgetPageState parentState)
      : super(originalConfig, parentState);

  @override
  List<Widget> buildList(BuildContext context, TimerConfig config) {
    return <Widget>[
      _StringEditConfigItem(
        context,
        parentState,
        'Display name',
        () => config.name,
        (value) => config.name = value,
      ).build(),
      _TimePickerConfigItem(
        context,
        parentState,
        'Time',
        () => config.totalSec,
        (value) => config.totalSec = value,
        isVisible: !config.requestTotalEveryTime,
      ).build(),
      _SwitchConfigItem(
        parentState,
        'Show progress bar',
        () => config.showProgressBar,
        (value) => config.showProgressBar = value,
      ).build(),
      _SwitchConfigItem(
        parentState,
        'Vibration',
        () => config.vibrate,
        (value) => config.vibrate = value,
      ).build(),
      _SwitchConfigItem(
        parentState,
        'Sound',
        () => config.sound,
        (value) => config.sound = value,
      ).build(),
      _SwitchConfigItem(
        parentState,
        'Ask for time when reset',
        () => config.requestTotalEveryTime,
        (value) => config.requestTotalEveryTime = value,
      ).build(),
      (config.sound || config.vibrate)
          ? Container(
              color: Color.alphaBlend(Colors.white38, Colors.amber),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Note:',
                    style: Style.PreferenceTitle,
                  ),
                  SizedBox(height: 5),
                  Text(
                    Platform.isIOS
                        ? 'Vibration and sound would only be played in a short duration and only once; If your device is in silent mode, the sound would not be played.'
                        : 'Vibration and sound would only be played for at most 10 seconds.',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ],
              ),
            )
          : SizedBox.shrink(),
      SizedBox(height: 10),
    ];
  }
}

abstract class _ConfigItem {
  final itemPadding = EdgeInsets.symmetric(horizontal: 20);
  final itemConstraints = BoxConstraints(minHeight: 60);
  final bool isVisible;

  final EditWidgetPageState parentState;

  _ConfigItem(this.parentState, {this.isVisible = true});

  Widget build();
}

class _StringEditConfigItem extends _ValueEditConfigItem {
  _StringEditConfigItem(
    BuildContext context,
    EditWidgetPageState parentState,
    title,
    getValue,
    void Function(String) setValue,
  ) : super(context, parentState, title, getValue, (input) {
          if (input == null) {
            return;
          }
          parentState.update(() {
            setValue.call(input);
          });
        });
}

class _IntegerEditConfigItem extends _ValueEditConfigItem {
  _IntegerEditConfigItem(
    BuildContext context,
    parentState,
    title,
    int min,
    int max,
    int Function() getValue,
    Function(int) setValue, {
    isVisible = true,
  }) : super(
          context,
          parentState,
          title,
          () => getValue.call().toString(),
          (input) {
            if (input == null) {
              return;
            }
            final intResult = int.tryParse(input);
            if (intResult != null && intResult >= min && intResult <= max) {
              parentState.update(() {
                setValue(intResult);
              });
            } else {
              SnackBarUtil.show(context,
                  '$title should be an integer between $min and $max.');
            }
          },
          inputType: TextInputType.number,
          isVisible: isVisible,
        );
}

abstract class _ValueEditConfigItem extends _ConfigItem {
  _ValueEditConfigItem(
    this.context,
    parentState,
    this.title,
    this.getValue,
    this.setValue, {
    isVisible = true,
    this.inputType,
  }) : super(parentState, isVisible: isVisible);

  final String title;
  final String Function() getValue;
  final void Function(String) setValue;
  final BuildContext context;
  final TextInputType inputType;

  @override
  Widget build() {
    if (!isVisible) {
      return SizedBox.shrink();
    }
    return InkWell(
      child: Container(
        constraints: itemConstraints,
        padding: itemPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Text(
                title,
                textAlign: TextAlign.left,
                style: Style.PreferenceTitle,
              ),
            ),
            Container(
              constraints: BoxConstraints(maxWidth: 200),
              child: getValue.call()?.isNotEmpty == true
                  ? Text(
                      getValue.call(),
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      textAlign: TextAlign.right,
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
            context, title, getValue.call(),
            inputType: inputType);
        setValue(result);
      },
    );
  }
}

class _TimePickerConfigItem extends _ConfigItem {
  _TimePickerConfigItem(
    this.context,
    parentState,
    this.title,
    this.getValue,
    this.setValue, {
    isVisible = true,
  }) : super(parentState, isVisible: isVisible);

  final BuildContext context;
  final String title;
  final int Function() getValue;
  final void Function(int) setValue;

  @override
  Widget build() {
    if (!isVisible) {
      return SizedBox.shrink();
    }
    return InkWell(
      child: Container(
        constraints: itemConstraints,
        padding: itemPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Text(
                title,
                textAlign: TextAlign.left,
                style: Style.PreferenceTitle,
              ),
            ),
            Container(
              constraints: BoxConstraints(maxWidth: 200),
              child: Text(
                DurationUtil.formatSeconds(getValue.call()),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
      onTap: () async {
        final result = await TimePickerAlertDialog.show(
            context, title, Duration(seconds: getValue.call()));
        if (result != null) {
          if (result == Duration.zero) {
            SnackBarUtil.show(context, '$title should not be zero.');
            return;
          }
          parentState.update(() => setValue(result.inSeconds));
        }
      },
    );
  }
}

class _SwitchConfigItem extends _ConfigItem {
  _SwitchConfigItem(
    parentState,
    this.title,
    this.getValue,
    this.setValue, {
    isVisible = true,
  }) : super(parentState, isVisible: isVisible);

  final String title;
  final bool Function() getValue;
  final void Function(bool) setValue;

  @override
  Widget build() {
    if (!isVisible) {
      return SizedBox.shrink();
    }
    return Container(
      constraints: itemConstraints,
      padding: itemPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Text(
              title,
              textAlign: TextAlign.left,
              style: Style.PreferenceTitle,
            ),
          ),
          Container(
            child: Switch(
              value: getValue.call(),
              onChanged: (value) {
                parentState.update(() {
                  setValue.call(value);
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownConfigItem<T> extends _ConfigItem {
  _DropdownConfigItem(
    parentState,
    this.title,
    this.getValue,
    this.setValue,
    this.options,
    this.optionNames, {
    isVisible = true,
  }) : super(parentState, isVisible: isVisible);

  final String title;
  final T Function() getValue;
  final void Function(T) setValue;
  final List<T> options;
  final List<String> optionNames;

  @override
  Widget build() {
    if (!isVisible) {
      return SizedBox.shrink();
    }
    return Container(
      constraints: itemConstraints,
      padding: itemPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Text(
              title,
              textAlign: TextAlign.left,
              style: Style.PreferenceTitle,
            ),
          ),
          DropdownButton<T>(
            value: getValue.call(),
            elevation: 16,
            items: options
                .asMap()
                .map((index, value) => MapEntry(
                    index,
                    DropdownMenuItem<T>(
                      value: value,
                      child: Text(optionNames[index]),
                    )))
                .values
                .toList(),
            onChanged: (T value) {
              parentState.update(() {
                setValue.call(value);
              });
            },
          ),
        ],
      ),
    );
  }
}
