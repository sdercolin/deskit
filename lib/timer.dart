import 'dart:async' as async;

import 'package:deskit/common/time_util.dart';
import 'package:deskit/deskit_widget.dart';
import 'package:deskit/model/timer_config.dart';
import 'package:deskit/model/timer_data.dart';
import 'package:flutter/material.dart';

class Timer extends DeskitWidget<Timer> {
  Timer(this.config, id, repository, key, scaffoldKey, parentState)
      : super(config, id, repository, key, scaffoldKey, parentState);

  @override
  final TimerConfig config;

  @override
  _TimerState createState() {
    return _TimerState();
  }
}

class _TimerState extends DeskitWidgetState<Timer> {
  int get _now => (data as TimerData).now;

  int get _total => (data as TimerData).total;

  double get _progress => _total == 0 ? 1 : _now / _total;

  set _now(int newValue) {
    updateData((data as TimerData).copyWith(now: newValue));
  }

  async.Timer _internalTimer;

  var _running = false;

  void _run() {
    setState(() {
      _running = true;
    });
    _internalTimer = async.Timer.periodic(
      Duration(seconds: 1),
      (timer) {
        setState(() {
          _now = _now - 1;
        });
        if (_now == 0) {
          timer.cancel();
          _running = false;
          notifyFinish();
        }
      },
    );
  }

  void _pause() {
    setState(() {
      _running = false;
      _internalTimer?.cancel();
      _internalTimer = null;
    });
  }

  @override
  void reset() {
    _running = false;
    _internalTimer?.cancel();
    _internalTimer = null;
    super.reset();
  }

  void notifyFinish() {}

  @override
  Widget build(BuildContext context) {
    preBuild();

    final config = widget.config;

    Widget body;

    body = Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 10),
          IconButton(
            iconSize: 55,
            icon: Icon(
              _running ? Icons.clear : Icons.refresh,
              color: Color.fromARGB(60, 0, 0, 0),
            ),
            onPressed: reset,
          ),
          SizedBox(width: 25),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                child: CircularProgressIndicator(
                  value: _progress,
                  backgroundColor: Color.alphaBlend(
                      Color.fromARGB(230, 255, 255, 255), Colors.amber),
                ),
                height: 150,
                width: 150,
              ),
              Column(
                children: [
                  Text(
                    DurationUtil.formatSeconds(_now),
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  Text(
                    DurationUtil.formatSeconds(_total),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(width: 20),
          IconButton(
            iconSize: 65,
            icon: Icon(
              _running ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: Colors.amber,
            ),
            onPressed: () {
              if (!_running) {
                _run();
              } else {
                _pause();
              }
            },
          ),
        ],
      ),
    );

    return wrapWithNameTag(body, config.name);
  }
}

enum TimerStyle { CIRCULAR, LINEAR }

extension TimerStyleExtension on TimerStyle {
  String get displayName {
    switch (this) {
      case TimerStyle.CIRCULAR:
        return 'Circular';
      case TimerStyle.LINEAR:
        return 'Linear';
      default:
        return null;
    }
  }
}
