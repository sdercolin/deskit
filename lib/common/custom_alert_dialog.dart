import 'package:flutter/material.dart';

class CustomAlertDialog {
  static Future<void> show(BuildContext context, Widget content,
      {Color backgroundColor}) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: content,
          backgroundColor: backgroundColor,
        );
      },
    );
  }
}
