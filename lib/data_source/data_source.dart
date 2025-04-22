import 'package:supaeromoon_ground_station/data_source/net.dart';
import 'package:supaeromoon_ground_station/data_source/replay.dart';
import 'package:supaeromoon_ground_station/data_source/selftest.dart';

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
      return 0;  // replay time
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
    _mode = DataSourceMode.none;
  }

  static bool get isActive => _mode != DataSourceMode.none;

  static bool isMode(final DataSourceMode mode) => mode == _mode;
}