import 'package:desktop_game_helper/common/snack_bar_util.dart';
import 'package:desktop_game_helper/common/text_edit_alert_dialog.dart';
import 'package:desktop_game_helper/repository/widget_data_repository.dart';
import 'package:flutter/material.dart';

import 'model/value_keeper_config.dart';
import 'model/value_keeper_data.dart';

class ValueKeeper extends StatefulWidget {
  ValueKeeper(this.config, this.repository, this.id);

  final ValueKeeperConfig config;
  final WidgetDataRepository repository;
  final int id;

  @override
  _ValueKeeperState createState() {
    return _ValueKeeperState();
  }
}

class _ValueKeeperState extends State<ValueKeeper> {
  var _defaultValue;
  var _value;
  final _focus = FocusNode();
  var _isFocus = false;

  TextEditingController _textEditingController;

  void _setValue(int newValue) {
    _value = newValue;
    widget.repository?.updateAt(ValueKeeperData(newValue), widget.id);
  }

  void _increment(BuildContext context) async {
    int interval;
    if (widget.config.requestIntervalEveryTime) {
      interval = await _requestInterval(context, true);
    } else {
      interval = widget.config.interval;
    }
    if (interval == null) {
      return;
    }
    var newValue = _value + interval;
    newValue = ValueKeeperConfig.validateValue(newValue);
    setState(() {
      _setValue(newValue);
      _refresh();
      _focus.unfocus();
    });
  }

  void _decrement(BuildContext context) async {
    int interval;
    if (widget.config.requestIntervalEveryTime) {
      interval = await _requestInterval(context, false);
    } else {
      interval = widget.config.interval;
    }
    if (interval == null) {
      return;
    }
    var newValue = _value - interval;
    newValue = ValueKeeperConfig.validateValue(newValue);
    setState(() {
      _setValue(newValue);
      _refresh();
      _focus.unfocus();
    });
  }

  Future<int> _requestInterval(BuildContext context, bool incremental) async {
    final title = incremental ? 'Increment by' : 'Decrement by';
    final inputText = await TextFieldAlertDialog.show(
      context,
      title,
      '',
      inputType: TextInputType.number,
    );
    int input;
    if (inputText != null) {
      input = int.tryParse(inputText);
    } else {
      return null;
    }
    if (input != null && input > 0) {
      return input;
    } else {
      SnackBarUtil.show(context, 'You should input a positive integer.');
      return null;
    }
  }

  void _reset() {
    setState(() {
      _setValue(_defaultValue);
      _refresh();
      _focus.unfocus();
    });
  }

  void _refresh() {
    _textEditingController.text = _value.toString();
  }

  void _onFocusChange() {
    setState(() {
      _isFocus = _focus.hasFocus;
      if (!_isFocus) {
        if (_textEditingController.text.isEmpty) {
          _setValue(_defaultValue);
        } else {
          var parsedValue = int.tryParse(_textEditingController.text);
          if (parsedValue != null) {
            _setValue(ValueKeeperConfig.validateValue(parsedValue));
          }
        }
        _refresh();
      }
    });
  }

  @override
  void initState() {
    _defaultValue = widget.config.initialValue;
    _value = _defaultValue;
    _textEditingController = TextEditingController(text: _value.toString());
    _focus.addListener(_onFocusChange);
    final data = widget.repository?.get(widget.id);
    if (data != null) {
      if (data is ValueKeeperData) {
        _value = data.value;
        _refresh();
      } else {
        widget.repository?.updateAt(ValueKeeperData(_value), widget.id);
      }
    } else {
      widget.repository?.addAt(ValueKeeperData(_value), widget.id);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    _defaultValue = config.initialValue;

    Widget plusButton;
    Widget minusButton;
    if (config.requestIntervalEveryTime) {
      plusButton = IconButton(
        icon: Icon(Icons.add_circle_outline),
        onPressed: () => _increment(context),
        iconSize: config.style.roundButtonSize,
      );
      minusButton = IconButton(
        icon: Icon(Icons.remove_circle_outline),
        onPressed: () => _decrement(context),
        iconSize: config.style.roundButtonSize,
      );
    } else if (config.displayInterval) {
      plusButton = FlatButton.icon(
        icon: Icon(Icons.add_circle_outline),
        onPressed: () => _increment(context),
        label: Text(config.interval.toString()),
      );
      minusButton = FlatButton.icon(
        icon: Icon(Icons.remove_circle_outline),
        onPressed: () => _decrement(context),
        label: Text(config.interval.toString()),
      );
    } else {
      plusButton = IconButton(
        icon: Icon(config.style.arrowButtonIconPlus),
        onPressed: () => _increment(context),
        iconSize: config.style.arrowButtonSize,
      );
      minusButton = IconButton(
        icon: Icon(config.style.arrowButtonIconMinus),
        onPressed: () => _decrement(context),
        iconSize: config.style.arrowButtonSize,
      );
    }

    final resetButton = InkWell(
      child: Icon(Icons.refresh, size: config.style.resetButtonSize),
      onTap: () => SnackBarUtil.show(
          context, 'Long press this button to reset the widget.'),
      onLongPress: _reset,
    );

    final textField = TextField(
      style: config.style.getTextFieldStyle(context),
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      controller: _textEditingController,
      focusNode: _focus,
      decoration: InputDecoration(
          border: OutlineInputBorder(), hintText: _defaultValue.toString()),
    );

    Widget body;

    switch (widget.config.style) {
      case ValueKeeperStyle.SMALL:
        body = Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              resetButton,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  minusButton,
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: textField,
                    ),
                  ),
                  plusButton,
                ],
              ),
            ],
          ),
        );
        break;
      case ValueKeeperStyle.LARGE:
        body = Container(
          padding: EdgeInsets.only(top: 10, bottom: 10, left: 60, right: 10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    plusButton,
                    textField,
                    minusButton,
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: resetButton,
              ),
            ],
          ),
        );
        break;
      default:
        break;
    }

    if (config.name.isNotEmpty) {
      return Container(
        color: Colors.white,
        child: Stack(
          children: <Widget>[
            Container(
              color: Color.alphaBlend(Colors.white30, Colors.amberAccent),
              child: Padding(
                padding:
                    EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 5),
                child: Container(
                  constraints: BoxConstraints(maxWidth: 100),
                  child: Text(
                    config.name,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 5),
              child: body,
            ),
          ],
        ),
      );
    } else {
      return Container(color: Colors.white, child: body);
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}

enum ValueKeeperStyle { SMALL, LARGE }

extension ValueKeeperStyleExtension on ValueKeeperStyle {
  IconData get arrowButtonIconPlus {
    switch (this) {
      case ValueKeeperStyle.SMALL:
        return Icons.arrow_right;
      case ValueKeeperStyle.LARGE:
        return Icons.arrow_drop_up;
      default:
        return null;
    }
  }

  IconData get arrowButtonIconMinus {
    switch (this) {
      case ValueKeeperStyle.SMALL:
        return Icons.arrow_left;
      case ValueKeeperStyle.LARGE:
        return Icons.arrow_drop_down;
      default:
        return null;
    }
  }

  double get arrowButtonSize {
    switch (this) {
      case ValueKeeperStyle.SMALL:
        return 40;
      case ValueKeeperStyle.LARGE:
        return 50;
      default:
        return null;
    }
  }

  double get roundButtonSize {
    switch (this) {
      case ValueKeeperStyle.SMALL:
        return 25;
      case ValueKeeperStyle.LARGE:
        return 30;
      default:
        return null;
    }
  }

  double get resetButtonSize {
    switch (this) {
      case ValueKeeperStyle.SMALL:
        return 20;
      case ValueKeeperStyle.LARGE:
        return 25;
      default:
        return null;
    }
  }

  String get displayName {
    switch (this) {
      case ValueKeeperStyle.SMALL:
        return 'Small';
      case ValueKeeperStyle.LARGE:
        return 'Large';
      default:
        return null;
    }
  }

  TextStyle getTextFieldStyle(BuildContext context) {
    switch (this) {
      case ValueKeeperStyle.SMALL:
        return Theme.of(context).textTheme.headline6;
      case ValueKeeperStyle.LARGE:
        return Theme.of(context).textTheme.headline3;
      default:
        return null;
    }
  }
}
