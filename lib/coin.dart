import 'package:deskit/model/coin_config.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'deskit_widget.dart';

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
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  @override
  void reset() {
    // TODO: implement reset
  }
}
