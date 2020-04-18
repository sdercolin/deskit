import 'dart:math';

import 'package:deskit/model/dice_config.dart';
import 'package:flutter/material.dart';

import 'common/custom_alert_dialog.dart';
import 'common/snack_bar_util.dart';
import 'common/text_edit_alert_dialog.dart';
import 'deskit_widget.dart';
import 'model/dice_data.dart';

class Dice extends DeskitWidget<Dice> {
  Dice(this.config, id, repository, key, scaffoldKey)
      : super(config, id, repository, key, scaffoldKey);

  @override
  final DiceConfig config;

  @override
  _DiceState createState() {
    return _DiceState();
  }
}

class _DiceState extends DeskitWidgetState<Dice> {
  List<DiceRollResult> get _results => (data as DiceData).results;

  set _results(List<DiceRollResult> newResults) {
    updateData(DiceData(newResults));
  }

  void _roll(int number, DiceConfig config) async {
    int sides;
    if (config.requestSidesEveryTime) {
      final resultText = await TextFieldAlertDialog.show(
          scaffoldContext, 'Number of sides', '',
          inputType: TextInputType.number);
      if (resultText == null) {
        return;
      }
      final resultInt = int.tryParse(resultText);
      final min = DiceConfig.minSides;
      final max = DiceConfig.maxSides;
      if (resultInt != null && resultInt >= min && resultInt <= max) {
        sides = resultInt;
      } else {
        SnackBarUtil.show(
            context, 'The number should be an integer between $min and $max.');
        return;
      }
    }

    final random = Random();
    final rolls = <int>[];
    for (var i = 0; i < number; i++) {
      final roll = random.nextInt(sides) + 1;
      rolls.add(roll);
    }
    final newResults = _results.toList();
    final newResult =
        DiceRollResult(number, rolls, DateTime.now().millisecondsSinceEpoch);
    newResults.add(newResult);

    final diceDescription = '${number}d${sides}';
    final sum = newResult.sum;
    final details = newResult.rollsText;

    if (config.popupResult) {
      final content = Column(
        children: [
          Text(
            diceDescription,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          SizedBox(height: 30),
          Text(
            sum.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 50),
          ),
          number > 1 ? SizedBox(height: 30) : null,
          number > 1
              ? Text(
                  details,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                )
              : null
        ].where((element) => element != null).toList(),
      );

      await CustomAlertDialog.show(
          scaffoldContext,
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
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

  void _requestMultiple(DiceConfig config) async {
    final resultText = await TextFieldAlertDialog.show(
        scaffoldContext, 'Number of dices', '',
        inputType: TextInputType.number);
    if (resultText == null) {
      return;
    }
    final resultInt = int.tryParse(resultText);
    final min = 1;
    final max = DiceConfig.maxNumber;
    if (resultInt != null && resultInt >= min && resultInt <= max) {
      _roll(resultInt, config);
    } else {
      SnackBarUtil.show(
          context, 'The number should be an integer between $min and $max.');
    }
  }

  @override
  Widget build(BuildContext context) {
    preBuild();
    final config = widget.config;

    final fontSize = config.showHistory ? 20.0 : 12.0;
    final button = RaisedButton(
        color: Colors.amber,
        child: Text(
          config.requestSidesEveryTime ? 'dX' : 'd${config.sides}',
          style: TextStyle(fontSize: fontSize),
          textAlign: TextAlign.center,
        ),
        onPressed: () => _roll(1, config),
        onLongPress:
            config.longPressMultiple ? () => _requestMultiple(config) : null);

    Widget body;
    if (config.showHistory) {
      body = Container(
        padding: EdgeInsets.only(left: 35, right: 35, top: 15, bottom: 20),
        constraints: BoxConstraints(maxHeight: 150),
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
              width: 80,
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
