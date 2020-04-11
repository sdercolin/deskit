import 'package:desktop_game_helper/settings.dart';
import 'package:desktop_game_helper/value_keeper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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

    final listView = ListView.separated(
      itemBuilder: (context, index) {
        if (settings.configs.length <= index) {
          return null;
        }
        return Slidable(
          actionPane: SlidableDrawerActionPane(),
          child: settings.configs[index].build(),
          actions: <Widget>[
            IconSlideAction(
              caption: 'Remove',
              color: Colors.red,
              icon: Icons.delete,
            ),
            IconSlideAction(
              caption: 'Edit',
              color: Colors.amber,
              icon: Icons.settings,
            ),
          ],
        );
      },
      itemCount: settings.configs.length,
      separatorBuilder: (context, index) {
        return Divider(
          height: 0.3,
          color: Color.alphaBlend(Colors.white70, Colors.grey),
        );
      },
    );

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        backgroundColor: Color.alphaBlend(Colors.black12, Colors.white),
        body: listView);
  }
}
