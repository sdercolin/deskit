import 'dart:math';

import 'package:deskit/common/custom_alert_dialog.dart';
import 'package:deskit/common/snack_bar_util.dart';
import 'package:deskit/common/text_edit_alert_dialog.dart';
import 'package:deskit/deskit_widget.dart';
import 'package:deskit/model/coin_config.dart';
import 'package:deskit/model/coin_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class Coin extends DeskitWidget<Coin> {
  Coin(this.config, id, repository, key, scaffoldKey, parentState)
      : super(config, id, repository, key, scaffoldKey, parentState);

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

  void _toss(BuildContext context, int total, bool popup) async {
    onButtonClick();
    final random = Random();
    var obverse = 0;
    for (var i = 0; i < total; i++) {
      obverse += random.nextBool() ? 1 : 0;
    }
    final newResults = _results.toList();
    newResults.add(
        CoinTossResult(total, obverse, DateTime.now().millisecondsSinceEpoch));

    if (popup) {
      final content = total == 1
          ? Text(
              obverse > 0 ? 'Obverse' : 'Reverse',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 40),
            )
          : Column(
              children: [
                Text(
                  'Obverse / Total',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
                Text(
                  '$obverse / $total',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 50),
                )
              ],
            );

      await CustomAlertDialog.show(
          widget.scaffoldKey.currentContext,
          Container(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              children: [content],
            ),
          ),
          backgroundColor:
              Color.alphaBlend(Color.fromARGB(180, 0, 0, 0), Colors.white));
    }

    setState(() {
      _results = newResults;
    });
  }

  void _requestMultiple(BuildContext context, bool popup) async {
    onButtonClick();
    final resultText = await TextFieldAlertDialog.show(
        scaffoldContext, 'Number of coins', '',
        inputType: TextInputType.number);
    if (resultText == null) {
      return;
    }
    final resultInt = int.tryParse(resultText);
    final min = 1;
    final max = CoinConfig.maxNumber;
    if (resultInt != null && resultInt >= min && resultInt <= max) {
      _toss(context, resultInt, popup);
    } else {
      SnackBarUtil.show(
          context, 'The number should be an integer between $min and $max.');
    }
  }

  @override
  Widget build(BuildContext context) {
    fetchData();
    final config = widget.config;

    final fontSize = config.showHistory ? 20.0 : 12.0;
    final button = RaisedButton(
        color: Colors.amber,
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            'Coin',
            style: TextStyle(fontSize: fontSize),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ),
        onPressed: () => _toss(context, 1, config.popupResult),
        onLongPress: config.longPressMultiple
            ? () => _requestMultiple(context, config.popupResult)
            : null);

    Widget body;
    if (config.showHistory) {
      body = Container(
        padding: EdgeInsets.only(left: 35, right: 35, top: 15, bottom: 20),
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
                        primary: false,
                        children: _results
                            .map((result) => Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 3),
                                  child: Text(
                                    result.buildText(),
                                    style: TextStyle(fontSize: 12),
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
        padding: EdgeInsets.only(left: 35, right: 35, top: 10, bottom: 15),
        constraints: BoxConstraints(maxHeight: 70),
        child: Row(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                color: Color.fromARGB(5, 0, 0, 0),
                padding: EdgeInsets.all(10),
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    _results.isEmpty
                        ? 'No result'
                        : _results.last.buildSimpleText(),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            SizedBox(width: 20),
            Container(
              height: double.infinity,
              width: 70,
              child: button,
            ),
          ],
        ),
      );
    }
    return wrapWithNameTag(body, config.name);
  }
}
