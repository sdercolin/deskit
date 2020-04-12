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
  static final _defaultValue = ValueKeeperData.defaultValue;
  var _value = _defaultValue;
  final _focus = FocusNode();
  var _isFocus = false;

  TextEditingController _textEditingController;

  void _setValue(int newValue) {
    _value = newValue;
    widget.repository?.updateAt(ValueKeeperData(newValue), widget.id);
  }

  void _incrementCounter() {
    setState(() {
      var newValue = _value + widget.config.interval;
      newValue = ValueKeeperConfig.validateValue(newValue);
      _setValue(newValue);
      _refresh();
      _focus.unfocus();
    });
  }

  void _decrementCounter() {
    setState(() {
      var newValue = _value - widget.config.interval;
      newValue = ValueKeeperConfig.validateValue(newValue);
      _setValue(newValue);
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

    Widget plusButton;
    Widget minusButton;
    if (config.displayInterval) {
      plusButton = FlatButton.icon(
        icon: Icon(Icons.add_circle_outline),
        onPressed: _incrementCounter,
        label: Text(config.interval.toString()),
      );
      minusButton = FlatButton.icon(
        icon: Icon(Icons.remove_circle_outline),
        onPressed: _decrementCounter,
        label: Text(config.interval.toString()),
      );
    } else {
      plusButton = IconButton(
        icon: Icon(config.style.arrowButtonIconPlus),
        onPressed: _incrementCounter,
        iconSize: config.style.arrowButtonSize,
      );
      minusButton = IconButton(
        icon: Icon(config.style.arrowButtonIconMinus),
        onPressed: _decrementCounter,
        iconSize: config.style.arrowButtonSize,
      );
    }

    Widget body;

    switch (widget.config.style) {
      case ValueKeeperStyle.SMALL:
        body = Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              minusButton,
              SizedBox(
                width: 200,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: TextField(
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    controller: _textEditingController,
                    focusNode: _focus,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: _defaultValue.toString()),
                  ),
                ),
              ),
              plusButton,
            ],
          ),
        );
        break;
      case ValueKeeperStyle.LARGE:
        body = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              plusButton,
              Padding(
                padding: EdgeInsets.only(left: 70.0, right: 70.0),
                child: TextField(
                  style: Theme.of(context).textTheme.headline3,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  controller: _textEditingController,
                  focusNode: _focus,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: _defaultValue.toString()),
                ),
              ),
              minusButton,
            ],
          ),
        );
        break;
      default:
        break;
    }

    if (config.name?.isNotEmpty == true) {
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
        return 30;
      case ValueKeeperStyle.LARGE:
        return 50;
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
}
