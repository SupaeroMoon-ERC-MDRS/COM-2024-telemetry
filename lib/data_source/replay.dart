import 'dart:typed_data';

import 'package:supaeromoon_ground_station/data_misc/datalogger.dart';
import 'package:supaeromoon_ground_station/data_source/database.dart';
import 'package:supaeromoon_ground_station/data_storage/data_storage.dart';
import 'package:supaeromoon_ground_station/data_storage/session.dart';



abstract class Replay{
  static int pos = 0;
  static Uint8List? bytes;
  static double speed = 1;
  static bool stop = false;
  static bool active = false;
  static void _setup(){
    pos = 0;

    //First time setup, run once
  }

  static void start() async{
    _setup();

  
  bytes = await Datalogger.readBytes();
  if(bytes == null || bytes!.length <= 8) return;

  process();
    

  }

  static void stopReplay(){
    // cleanup
  }

  static void process() async{
    if(stop == true){
      stop = false;
      return;
    }

    final int len = bytes!.buffer.asByteData().getUint32(pos);
    pos += 4;
    final int timestamp = bytes!.buffer.asByteData().getUint32(pos);
    pos += 4;
    if(bytes!.length <= pos + len){
      active = false;
      return;
    }
    Uint8List line = bytes!.sublist(pos, pos + len);
    pos += len;

    final List<MapEntry<int, Map<String, dynamic>>> rec = DBCDatabase.decode(line);

    for(final MapEntry<int, Map<String, dynamic>> msg in rec){
      for(final String sig in msg.value.keys){
        DataStorage.update(sig, msg.value[sig]!, timestamp);
      }
    }
    
    DataStorage.discardIfOlderThan(timestamp - Session.bufferMs);

    if(bytes!.length <= pos + 8){
      active = false;
      return;
    }

    active = true;    

    final int nexttimestamp = bytes!.buffer.asByteData().getUint32(pos + 4);
    
    Future.delayed(Duration(milliseconds: ((nexttimestamp-timestamp) * speed).toInt()), process);
    
  }

  static void seek(int timestamp){
    if(active == false) return;
    int initialpos = pos;

    final int nexttimestamp = bytes!.buffer.asByteData().getUint32(pos + 4);
    if(timestamp > nexttimestamp){
      while(timestamp > nexttimestamp){
        if(bytes!.length < pos + 8){
          pos = initialpos;
          return;
        }
        final int len = bytes!.buffer.asByteData().getUint32(pos);
        pos += 4;
        final int nexttimestamp = bytes!.buffer.asByteData().getUint32(pos);
        pos += 4 + len;

        if(timestamp < nexttimestamp){
          pos -= len + 8;
          return;
        }
      }
    }else{
      pos = 0;
      int nexttimestamp = bytes!.buffer.asByteData().getUint32(pos + 4);
      if(timestamp < nexttimestamp){
        pos = initialpos;
        return;
      }
      while(timestamp > nexttimestamp){
        if(bytes!.length < pos + 8){
          pos = initialpos;
          return;
        }
        final int len = bytes!.buffer.asByteData().getUint32(pos);
        pos += 4;
        final int nexttimestamp = bytes!.buffer.asByteData().getUint32(pos);
        pos += 4 + len;

        if(timestamp < nexttimestamp){
          pos -= len + 8;
          return;
        }
      }

    }

  }



}

