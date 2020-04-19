import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimePickerAlertDialog {
  static Future<Duration> show(
      BuildContext context, String title, Duration initialTime) async {
    var duration = initialTime;
    var confirmed = false;
    await showDialog<Duration>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Wrap(
            children: [
              CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hms,
                initialTimerDuration: initialTime,
                onTimerDurationChanged: (value) {
                  duration = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                confirmed = true;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return confirmed ? duration : null;
  }
}
