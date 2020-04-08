import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final String title = 'Desktop Game Helper (devcode)';
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.requestFocus(new FocusNode());
        }
      },
      child: MaterialApp(
        title: title,
        theme: ThemeData(
          primarySwatch: Colors.pink,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(title: title),
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
  static final int _counterDefault = 0;
  int _counter = _counterDefault;
  FocusNode _focus = new FocusNode();
  bool _isFocus = false;

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
          int parsedValue = int.tryParse(_textEditingController.text);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
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
      ),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}
