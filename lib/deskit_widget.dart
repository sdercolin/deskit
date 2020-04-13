import 'package:flutter/cupertino.dart';

abstract class DeskitWidget<T> extends StatefulWidget {
  DeskitWidget(Key key) : super(key: key);
}

abstract class DeskitWidgetState<T extends StatefulWidget> extends State<T> {
  void reset();
}
