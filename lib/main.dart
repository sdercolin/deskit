import 'package:desktop_game_helper/settings.dart';
import 'package:desktop_game_helper/value_keeper.dart';
import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    final settings = Settings([
      ValueKeeperConfig(ValueKeeperStyle.LARGE),
      ValueKeeperConfig(ValueKeeperStyle.SMALL),
      ValueKeeperConfig(ValueKeeperStyle.LARGE,
          displayInterval: true,
          interval: 100,
          name: 'counter 3 counter 3 counter 3 counter 3 counter 3 counter 3'),
      ValueKeeperConfig(ValueKeeperStyle.SMALL,
          displayInterval: true, interval: 100, name: 'counter 4'),
    ]);

    final listView = ListView.builder(itemBuilder: (context, index) {
      if (settings.configs.length <= index) {
        return null;
      }
      return ListTile(
        title: settings.configs[index].build(),
      );
    });

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        backgroundColor: Color.alphaBlend(Colors.black12, Colors.white),
        body: listView);
  }
}
