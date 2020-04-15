import 'package:deskit/repository/widget_data_repository.dart';
import 'package:flutter/cupertino.dart';

import 'model/config.dart';

abstract class DeskitWidget<T> extends StatefulWidget {
  DeskitWidget(this.config, this.id, this.repository, Key key)
      : super(key: key);

  final Config config;
  final WidgetDataRepository repository;
  final int id;
}

abstract class DeskitWidgetState<T extends StatefulWidget> extends State<T> {
  void reset();
}
