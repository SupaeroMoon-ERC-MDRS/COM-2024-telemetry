import 'package:flutter/foundation.dart';
import 'package:supaeromoon_ground_station/data_source/net.dart';
import 'package:supaeromoon_ground_station/data_source/replay.dart';
import 'package:supaeromoon_ground_station/data_source/selftest.dart';
import 'package:supaeromoon_ground_station/data_storage/data_storage.dart';

enum DataSourceMode{
  none,
  net,
  replay,
  selftest
}

abstract class DataSource{
  static DataSourceMode _mode = DataSourceMode.none;
  // Notifier to allow UI widgets to rebuild reactively when the mode changes.
  static final ValueNotifier<DataSourceMode> modeNotifier = ValueNotifier<DataSourceMode>(_mode);

  static int now(){
    if(_mode == DataSourceMode.replay){
      return Replay.replayTime ?? 0;
    }
    return DateTime.now().millisecondsSinceEpoch;
  }

  static void net(){
    if(_mode == DataSourceMode.net){
      return;
    }
    else if(_mode == DataSourceMode.replay){
      Replay.stop();
    }
    else if(_mode == DataSourceMode.selftest){
      Selftest.stop();
    }

    DataStorage.clear();

    Net.start();
    _mode = DataSourceMode.net;
    modeNotifier.value = _mode;
  }

  static void replay(){
    if(_mode == DataSourceMode.replay){
      return;
    }
    else if(_mode == DataSourceMode.net){
      Net.stop();
    }
    else if(_mode == DataSourceMode.selftest){
      Selftest.stop();
    }

    DataStorage.clear();

    Replay.start();
    _mode = DataSourceMode.replay;
    modeNotifier.value = _mode;
  }

  static void selftest(){
    if(_mode == DataSourceMode.selftest){
      return;
    }
    else if(_mode == DataSourceMode.net){
      Net.stop();
    }
    else if(_mode == DataSourceMode.replay){
      Replay.stop();
    }

    DataStorage.clear();

    Selftest.start();
    _mode = DataSourceMode.selftest;
    modeNotifier.value = _mode;
  }

  static void stop(){
    if(_mode == DataSourceMode.replay){
      Replay.stop();
    }
    else if(_mode == DataSourceMode.selftest){
      Selftest.stop();
    }
    else if(_mode == DataSourceMode.selftest){
      Selftest.stop();
    }

    DataStorage.clear();

    _mode = DataSourceMode.none;
    modeNotifier.value = _mode;
  }

  static bool get isActive => _mode != DataSourceMode.none;

  static bool isMode(final DataSourceMode mode) => mode == _mode;
  static DataSourceMode get mode => _mode;
}