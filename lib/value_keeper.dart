import 'package:deskit/common/snack_bar_util.dart';
import 'package:deskit/common/text_edit_alert_dialog.dart';
import 'package:deskit/deskit_widget.dart';
import 'package:flutter/material.dart';

import 'model/value_keeper_config.dart';
import 'model/value_keeper_data.dart';

class ValueKeeper extends DeskitWidget<ValueKeeper> {
  ValueKeeper(this.config, id, repository, key)
      : super(config, id, repository, key);

  @override
  final ValueKeeperConfig config;

  @override
  _ValueKeeperState createState() {
    return _ValueKeeperState();
  }
}

class _ValueKeeperState extends DeskitWidgetState<ValueKeeper> {
  int get _value => (data as ValueKeeperData).value;

  set _value(int newValue) {
    updateData(ValueKeeperData(newValue));
  }

  final _focus = FocusNode();
  var _isFocus = false;

  TextEditingController _textEditingController;

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
      _value = newValue;
      setupUI();
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
      _value = newValue;
      setupUI();
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

  @override
  void setupUI() {
    _textEditingController.text = _value.toString();
    _focus.unfocus();
  }

  void _onFocusChange() {
    setState(() {
      _isFocus = _focus.hasFocus;
      if (!_isFocus) {
        if (_textEditingController.text.isEmpty) {
          _value = (defaultData as ValueKeeperData).value;
        } else {
          var parsedValue = int.tryParse(_textEditingController.text);
          if (parsedValue != null) {
            _value = ValueKeeperConfig.validateValue(parsedValue);
          }
        }
        setupUI();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: _value.toString());
    _focus.addListener(_onFocusChange);
  }

  @override
  Widget build(BuildContext context) {
    preBuild();

    final config = widget.config;

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
      onLongPress: reset,
    );

    final textField = TextField(
      style: config.style.getTextFieldStyle(context),
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      controller: _textEditingController,
      focusNode: _focus,
      decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: (defaultData as ValueKeeperData).value.toString()),
    );

    Widget body;

    switch (widget.config.style) {
      case ValueKeeperStyle.SMALL:
        body = Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
              resetButton,
            ],
          ),
        );
        break;
      case ValueKeeperStyle.LARGE:
        body = Container(
          padding: EdgeInsets.only(top: 5, bottom: 5, left: 60, right: 10),
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

    return wrapWithNameTag(body, config.name);
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
        return Icons.keyboard_arrow_up;
      default:
        return null;
    }
  }

  IconData get arrowButtonIconMinus {
    switch (this) {
      case ValueKeeperStyle.SMALL:
        return Icons.arrow_left;
      case ValueKeeperStyle.LARGE:
        return Icons.keyboard_arrow_down;
      default:
        return null;
    }
  }

  double get arrowButtonSize {
    switch (this) {
      case ValueKeeperStyle.SMALL:
        return 30;
      case ValueKeeperStyle.LARGE:
        return 35;
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
