import 'package:flutter/cupertino.dart';

class FocusUtil {
  static void unfocusAll(BuildContext context) {
    var currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.requestFocus(FocusNode());
    }
  }
}
