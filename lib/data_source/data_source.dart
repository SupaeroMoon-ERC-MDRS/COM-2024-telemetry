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
  }

  static bool get isActive => _mode != DataSourceMode.none;

  static bool isMode(final DataSourceMode mode) => mode == _mode;
}