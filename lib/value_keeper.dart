import 'package:flutter/material.dart';

class ValueKeeper extends StatefulWidget {
  ValueKeeper({Key key}) : super(key: key);

  @override
  _ValueKeeperState createState() => _ValueKeeperState();
}

class _ValueKeeperState extends State<ValueKeeper> {
  static final _counterDefault = 0;
  var _counter = _counterDefault;
  final _focus = FocusNode();
  var _isFocus = false;

  TextEditingController _textEditingController;

  void _incrementCounter() {
    setState(() {
      _counter++;
      _refreshCounterDisplay();
      _focus.unfocus();
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
      _refreshCounterDisplay();
      _focus.unfocus();
    });
  }

  void _refreshCounterDisplay() {
    _textEditingController.text = _counter.toString();
  }

  void _onFocusChange() {
    setState(() {
      _isFocus = _focus.hasFocus;
      if (!_isFocus) {
        if (_textEditingController.text.isEmpty) {
          _counter = _counterDefault;
        } else {
          var parsedValue = int.tryParse(_textEditingController.text);
          if (parsedValue != null) _counter = parsedValue;
        }
        _refreshCounterDisplay();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: _counter.toString());
    _focus.addListener(_onFocusChange);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_drop_up),
            onPressed: _incrementCounter,
            iconSize: 50,
          ),
          Padding(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: TextField(
              style: Theme.of(context).textTheme.headline3,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              controller: _textEditingController,
              focusNode: _focus,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: _counterDefault.toString()),
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_drop_down),
            onPressed: _decrementCounter,
            iconSize: 50,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}
