import 'dart:typed_data';

import 'package:supaeromoon_ground_station/data_misc/datalogger.dart';
import 'package:supaeromoon_ground_station/data_source/database.dart';
import 'package:supaeromoon_ground_station/data_storage/data_storage.dart';
import 'package:supaeromoon_ground_station/data_storage/session.dart';

abstract class Replay{
  static int _pos = 0;
  static Uint8List? _bytes;
  static double speed = 1;
  static bool _stopReplay = false;
  static bool _active = false;

  static Future<void> _setup() async {
    _pos = 0;
    _bytes = await Datalogger.readBytes();
  }

  static void start() async {
    await _setup();

    if(_bytes == null || _bytes!.length <= 8) return;

    _process();
  }

  static void stop(){
    _stopReplay = true;
    _bytes?.clear();
  }

  static void pause() => _stopReplay = true;
  static void resume(){
    if(_active) _process();
  }

  static void _process() async{
    if(_stopReplay == true){
      _stopReplay = false;
      return;
    }

    final int len = _bytes!.buffer.asByteData().getUint32(_pos);
    _pos += 4;
    final int timestamp = _bytes!.buffer.asByteData().getUint32(_pos);
    _pos += 4;
    if(_bytes!.length <= _pos + len){
      _active = false;
      return;
    }
    Uint8List line = _bytes!.sublist(_pos, _pos + len);
    _pos += len;

    final List<MapEntry<int, Map<String, dynamic>>> rec = DBCDatabase.decode(line);

    for(final MapEntry<int, Map<String, dynamic>> msg in rec){
      for(final String sig in msg.value.keys){
        DataStorage.update(sig, msg.value[sig]!, timestamp);
      }
    }
    
    DataStorage.discardIfOlderThan(timestamp - Session.bufferMs);

    if(_bytes!.length <= _pos + 8){
      _active = false;
      return;
    }

    _active = true;    
    final int nexttimestamp = _bytes!.buffer.asByteData().getUint32(_pos + 4);
    Future.delayed(Duration(milliseconds: ((nexttimestamp - timestamp) * speed).toInt()), _process);
  }

  static void seek(int timestamp){
    if(_active == false) return;
    int initialpos = _pos;

    final int nexttimestamp = _bytes!.buffer.asByteData().getUint32(_pos + 4);
    if(timestamp > nexttimestamp){
      while(timestamp > nexttimestamp){
        if(_bytes!.length < _pos + 8){
          _pos = initialpos;
          return;
        }
        final int len = _bytes!.buffer.asByteData().getUint32(_pos);
        _pos += 4;
        final int nexttimestamp = _bytes!.buffer.asByteData().getUint32(_pos);
        _pos += 4 + len;

        if(timestamp < nexttimestamp){
          _pos -= len + 8;
          return;
        }
      }
    }
    else{
      _pos = 0;
      int nexttimestamp = _bytes!.buffer.asByteData().getUint32(_pos + 4);
      if(timestamp < nexttimestamp){
        _pos = initialpos;
        return;
      }
      while(timestamp > nexttimestamp){
        if(_bytes!.length < _pos + 8){
          _pos = initialpos;
          return;
        }
        final int len = _bytes!.buffer.asByteData().getUint32(_pos);
        _pos += 4;
        final int nexttimestamp = _bytes!.buffer.asByteData().getUint32(_pos);
        _pos += 4 + len;

        if(timestamp < nexttimestamp){
          _pos -= len + 8;
          return;
        }
      }
    }
  }
}

