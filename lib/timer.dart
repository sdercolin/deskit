import 'dart:async' as async;

import 'package:deskit/common/custom_alert_dialog.dart';
import 'package:deskit/common/snack_bar_util.dart';
import 'package:deskit/common/time_picker_alert_dialog.dart';
import 'package:deskit/common/time_util.dart';
import 'package:deskit/deskit_widget.dart';
import 'package:deskit/model/timer_config.dart';
import 'package:deskit/model/timer_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:vibration/vibration.dart';

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

class _TimerState extends DeskitWidgetState<Timer>
    with SingleTickerProviderStateMixin {
  int get _now => (data as TimerData).now;

  int get _total => (data as TimerData).total;

  double get _progress => _total == 0 ? 1 : _now / _total;

  set _now(int newValue) {
    updateData((data as TimerData).copyWith(now: newValue));
  }

  set _total(int newValue) {
    updateData((data as TimerData).copyWith(total: newValue));
  }

  async.Timer _internalTimer;

  var _running = false;

  Animation _animation;
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    fetchData();
    _animationController =
        AnimationController(duration: Duration(seconds: _total), vsync: this);
    _animation = Tween<double>(begin: 1, end: 0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
  }

  void _startAnimation() {
    _animationController.forward(from: 1 - _progress);
  }

  void _run() {
    setState(() {
      _running = true;
    });
    _internalTimer = async.Timer.periodic(
      Duration(seconds: 1),
      (timer) {
        setState(() {
          _now = _now - 1;
          if (_now == 0) {
            restart();
            _notifyFinish();
          }
        });
      },
    );
    _startAnimation();
  }

  void _stop() {
    _running = false;
    _internalTimer?.cancel();
    _internalTimer = null;
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
  }

  @override
  void reset() {
    super.reset();
    _stop();
  }

  void restart() {
    setState(() {
      _stop();
      _now = _total;
    });
    if (!widget.config.requestTotalEveryTime) {
      reset();
    }
  }

  void vibrate() async {
    if (widget.config.vibrate && await Vibration.hasVibrator()) {
      await Vibration.vibrate(pattern: List.filled(30, 500));
    }
  }

  void cancelVibration() async {
    try {
      await Vibration.cancel();
    } catch (e) {
      debugPrint(e);
    }
  }

  void playAlarm() async {
    if (widget.config.sound) {
      await FlutterRingtonePlayer.playAlarm(looping: true);
    }
  }

  void cancelAlarm() async {
    await FlutterRingtonePlayer.stop();
  }

  void _notifyFinish() async {
    vibrate();
    playAlarm();
    final task = async.Timer(Duration(seconds: 10), () {
      cancelAlarm();
      cancelVibration();
    });
    await CustomAlertDialog.show(
        widget.scaffoldKey.currentContext,
        Container(
          padding: EdgeInsets.symmetric(vertical: 30),
          child: Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            children: [
              Text(
                'Time is up',
                style: TextStyle(color: Colors.white, fontSize: 30),
              )
            ],
          ),
        ),
        backgroundColor:
            Color.alphaBlend(Color.fromARGB(180, 0, 0, 0), Colors.white));
    if (task.isActive) {
      cancelAlarm();
      cancelVibration();
    }
  }

  @override
  Widget build(BuildContext context) {
    fetchData();

    final config = widget.config;

    final resetButton = IconButton(
      iconSize: config.showProgressBar ? 55 : 50,
      icon: Icon(
        _running ? Icons.clear : Icons.refresh,
        color: Color.fromARGB(60, 0, 0, 0),
      ),
      onPressed: () async {
        if (config.requestTotalEveryTime) {
          if (_running) {
            restart();
            return;
          }
          final result = await TimePickerAlertDialog.show(
              context, 'Time', Duration(seconds: _total));
          if (result == null) {
            return;
          }
          _total = result.inSeconds;
          restart();
          _animationController.duration = result;
        } else {
          restart();
          _animationController.duration = Duration(seconds: _total);
        }
      },
    );

    final startStopButton = IconButton(
      iconSize: config.showProgressBar ? 60 : 55,
      icon: Icon(
        _running ? Icons.pause_circle_filled : Icons.play_circle_filled,
        color: Colors.amber,
      ),
      onPressed: () {
        if (!_running) {
          if (_total == 0) {
            if (config.requestTotalEveryTime) {
              SnackBarUtil.show(context,
                  'Setup time by clicking reset button on the left side first.');
            }
            return;
          }
          _run();
        } else {
          setState(() {
            _stop();
          });
        }
      },
    );

    Widget body;

    if (config.showProgressBar) {
      body = Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        width: double.infinity,
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 10),
              resetButton,
              SizedBox(width: 25),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return CircularProgressIndicator(
                          value: _running ? _animation?.value : _progress,
                          backgroundColor: Color.alphaBlend(
                              Color.fromARGB(230, 255, 255, 255), Colors.amber),
                        );
                      },
                    ),
                    height: 150,
                    width: 150,
                  ),
                  Column(
                    children: [
                      Text(
                        DurationUtil.formatSeconds(_now),
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.black54,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Text(
                        DurationUtil.formatSeconds(_total),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(width: 20),
              startStopButton,
            ],
          ),
        ),
      );
    } else {
      body = Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            resetButton,
            Expanded(
              child: Column(
                children: [
                  Text(
                    DurationUtil.formatSeconds(_now),
                    style: TextStyle(
                      fontSize: 43,
                      color: Colors.black54,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    DurationUtil.formatSeconds(_total),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            startStopButton
          ],
        ),
      );
    }

    return wrapWithNameTag(body, config.name);
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _internalTimer?.cancel();
    _internalTimer = null;
    super.dispose();
  }
}
