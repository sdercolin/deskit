import 'dart:math';

import 'package:deskit/model/coin_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'deskit_widget.dart';
import 'model/coin_data.dart';

class Coin extends DeskitWidget<Coin> {
  Coin(this.config, id, repository, key) : super(config, id, repository, key);

  @override
  final CoinConfig config;

  @override
  _CoinState createState() {
    return _CoinState();
  }
}

class _CoinState extends DeskitWidgetState<Coin> {
  List<CoinTossResult> get _results => (data as CoinData).results;

  set _results(List<CoinTossResult> newResults) {
    updateData(CoinData(newResults));
  }

  void _toss() {
    final random = Random();
    final total = widget.config.number;
    var obverse = 0;
    for (var i = 0; i < total; i++) {
      obverse += random.nextBool() ? 1 : 0;
    }
    final newResults = _results.toList();
    newResults.add(
        CoinTossResult(total, obverse, DateTime.now().millisecondsSinceEpoch));
    setState(() {
      _results = newResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    preBuild();
    final config = widget.config;
    final number = config.number;

    final fontSize = config.showHistory ? 20.0 : 12.0;
    final button = RaisedButton(
      color: Colors.amber,
      child: Text(
        number > 1 ? 'Coin × ${number}' : 'Coin',
        style: TextStyle(fontSize: fontSize),
        textAlign: TextAlign.center,
      ),
      onPressed: _toss,
    );

    Widget body;
    if (config.showHistory) {
      body = Container(
        padding: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
        constraints: BoxConstraints(maxHeight: 130),
        child: Row(
          children: [
            Expanded(
              child: Container(
                color: Color.fromARGB(5, 0, 0, 0),
                padding: EdgeInsets.all(10),
                child: _results.isEmpty
                    ? Center(child: Text('No history'))
                    : ListView(
                        children: _results
                            .map((result) => Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 3),
                                  child: Text(
                                    result.buildText(),
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ))
                            .toList()
                            .reversed
                            .toList(),
                      ),
              ),
            ),
            SizedBox(width: 20),
            Container(
              height: double.infinity,
              width: 120,
              child: button,
            ),
          ],
        ),
      );
    } else {
      body = Container(
        padding: EdgeInsets.symmetric(horizontal: 35, vertical: 10),
        constraints: BoxConstraints(maxHeight: 70),
        child: Row(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                color: Color.fromARGB(5, 0, 0, 0),
                padding: EdgeInsets.all(10),
                child: Text(
                  _results.isEmpty
                      ? 'No result'
                      : _results.last.buildSimpleText(),
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(width: 20),
            Container(
              height: double.infinity,
              width: 60,
              child: button,
            ),
          ],
        ),
      );
    }
    return wrapWithNameTag(body, config.name);
  }

  @override
  void setupUI() {}
}
