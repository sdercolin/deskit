import 'package:flutter/cupertino.dart';

abstract class Config {
  String type;

  Config(this.type);

  Widget build();
}
