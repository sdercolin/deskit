import 'package:flutter/material.dart';

class TextFieldAlertDialog {
  static Future<String> show(BuildContext context, String title,
      String initialValue) {
    final _controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Row(
            children: <Widget>[
              Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true
                  ))
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(_controller.text);
              },
            ),
          ],
        );
      },
    );
  }
}
