import 'package:supaeromoon_ground_station/data_source/net.dart';
import 'package:supaeromoon_ground_station/data_source/replay.dart';
import 'package:supaeromoon_ground_station/data_source/selftest.dart';

enum _Mode{
  none,
  net,
  replay,
  selftest
}

abstract class DataSource{
  static _Mode _mode = _Mode.none;

  static int now(){
    if(_mode == _Mode.replay){
      return 0;  // replay time
    }
    return DateTime.now().millisecondsSinceEpoch;
  }

  static void net(){
    if(_mode == _Mode.net){
      return;
    }
    else if(_mode == _Mode.replay){
      Replay.stop();
    }
    else if(_mode == _Mode.selftest){
      Selftest.stop();
    }

    Net.start();
    _mode = _Mode.net;
  }

  static void replay(){
    if(_mode == _Mode.replay){
      return;
    }
    else if(_mode == _Mode.net){
      Net.stop();
    }
    else if(_mode == _Mode.selftest){
      Selftest.stop();
    }

    Replay.start();
    _mode = _Mode.replay;
  }

  static void selftest(){
    if(_mode == _Mode.selftest){
      return;
    }
    else if(_mode == _Mode.net){
      Net.stop();
    }
    else if(_mode == _Mode.replay){
      Replay.stop();
    }

    Selftest.start();
    _mode = _Mode.selftest;
  }

  static void stop(){
    if(_mode == _Mode.replay){
      Replay.stop();
    }
    else if(_mode == _Mode.selftest){
      Selftest.stop();
    }
    else if(_mode == _Mode.selftest){
      Selftest.stop();
    }
    _mode = _Mode.none;
  }

  static bool get isActive => _mode != _Mode.none;
}