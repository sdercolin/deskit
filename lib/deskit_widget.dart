import 'package:deskit/main.dart';
import 'package:deskit/model/config.dart';
import 'package:deskit/model/widget_data.dart';
import 'package:deskit/repository/widget_data_repository.dart';
import 'package:flutter/material.dart';

abstract class DeskitWidget<T> extends StatefulWidget {
  DeskitWidget(
    this.config,
    this.id,
    this.repository,
    Key key,
    this.scaffoldKey,
    this.parentState,
  ) : super(key: key);

  final Config config;
  final WidgetDataRepository repository;
  final int id;
  final GlobalKey scaffoldKey;
  final State parentState;
}

abstract class DeskitWidgetState<T extends DeskitWidget<T>> extends State<T> {
  WidgetData<T> defaultData;
  WidgetData<T> data;

  BuildContext get scaffoldContext => widget.scaffoldKey.currentContext;

  bool verifyData(WidgetData data) {
    return data is WidgetData<T>;
  }

  void updateData(WidgetData<T> newData) {
    data = newData;
    widget.repository?.updateAtSync(data, widget.id);
  }

  void preBuild() {
    defaultData = widget.config.getDefaultData();
    final newData = widget.repository?.get(widget.id);
    if (newData != null) {
      if (verifyData((newData))) {
        updateData(newData);
        setupUI();
      } else {
        widget.repository?.updateAtSync(data, widget.id);
      }
    } else {
      widget.repository?.addAtSync(data, widget.id);
    }
  }

  void setupUI() {}

  void unfocus() {}

  void onButtonClick() {
    final parentState = widget.parentState;
    if (parentState is HomePageState) {
      parentState.resetFocus();
    }
  }

  void reset() {
    setState(() {
      updateData(defaultData);
      setupUI();
    });
  }

  @override
  void initState() {
    super.initState();
    defaultData = widget.config.getDefaultData();
    data = defaultData;
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    } else {
      fn.call();
    }
  }

  Widget wrapWithNameTag(Widget body, String name) {
    if (name.isNotEmpty) {
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
                    name,
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
}
