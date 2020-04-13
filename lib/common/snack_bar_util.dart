import 'package:flutter/material.dart';

class SnackBarUtil {
  static void show(BuildContext context, String text) {
    Scaffold.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          duration: Duration(seconds: 2),
        ),
      );
  }
}
