import 'dart:typed_data';

import 'package:supaeromoon_ground_station/data_storage/signal_container.dart';
import 'package:supaeromoon_ground_station/io/logger.dart';

abstract class DataStorage{
  static Map<String, SignalContainer<TypedData>> storage = {  // TODO automatically figure out in setup(), have display name as external localization instead
    "l_top" : SignalContainer<Uint8List>.create("l_top", "l_top"),
    "l_bottom" : SignalContainer<Uint8List>.create("l_bottom", "l_bottom"),
    "l_right" : SignalContainer<Uint8List>.create("l_right", "l_right"),
    "l_left" : SignalContainer<Uint8List>.create("l_left", "l_left"),
    "r_top" : SignalContainer<Uint8List>.create("r_top", "r_top"),
    "r_bottom" : SignalContainer<Uint8List>.create("r_bottom", "r_bottom"),
    "r_right" : SignalContainer<Uint8List>.create("r_right", "r_right"),
    "r_left" : SignalContainer<Uint8List>.create("r_left", "r_left"),
    "l_shoulder" : SignalContainer<Uint8List>.create("l_shoulder", "l_shoulder"),
    "r_shoulder" : SignalContainer<Uint8List>.create("r_shoulder", "r_shoulder"),
    "e_stop" : SignalContainer<Uint8List>.create("e_stop", "e_stop"),
    "left_trigger" : SignalContainer<Uint8List>.create("left_trigger", "Left trigger"),
    "right_trigger" : SignalContainer<Uint8List>.create("right_trigger", "Right trigger"),
    "thumb_left_x" : SignalContainer<Uint8List>.create("thumb_left_x", "thumb_left_x"),
    "thumb_left_y" : SignalContainer<Uint8List>.create("thumb_left_y", "thumb_left_y"),
    "thumb_right_x" : SignalContainer<Uint8List>.create("thumb_right_x", "thumb_right_x"),
    "thumb_right_y" : SignalContainer<Uint8List>.create("thumb_right_y", "thumb_right_y"),
  };

  static Map<String, VectorSignalContainer<TypedData>> vectorStorage = {
    "dummy": VectorSignalContainer<Int32List>.create("dbcName", "displayName", Int32List(0))
  };

  static void setup(){
    
  }

  static void update(final String sig, final dynamic v, final int t){
    if(!storage.containsKey(sig)){
      localLogger.warning("A signal update was received for $sig but corresponding buffer was not set up", doNoti: false);
      return;
    }
    if(v is num){
      num? last = storage[sig]!.vt.lastOrNull?.value;
      storage[sig]!.vt.pushback(v, t);
      storage[sig]!.everyUpdateNotifier.update();
      if(storage[sig]!.vt.isNotEmpty && v != last){
        storage[sig]!.changeNotifier.update();
      }
    }
    else if(v is TypedData){
      vectorStorage[sig]!.value = v;
      vectorStorage[sig]!.time = t;
      vectorStorage[sig]!.everyUpdateNotifier.update();
      vectorStorage[sig]!.changeNotifier.update();
    }
  }

  static void discardIfOlderThan(final int t){
    for(final String sig in storage.keys){
      if((storage[sig]!.vt.firstOrNull?.time ?? double.infinity) >= t - 10000){
        continue;
      }
      
      int pos = storage[sig]!.vt.time.indexWhere((ts) => ts >= t);
      if(pos == -1){
        storage[sig]!.vt.clear();
        storage[sig]!.changeNotifier.update();
      }
      else{
        storage[sig]!.vt.popfront(pos);
      }
      storage[sig]!.everyUpdateNotifier.update();
    }
  }

  static int timeIndexOf(final String sig, final double t, final int latest, [final int after = 0]){
    if(storage[sig]!.vt.size > latest && storage[sig]!.vt.time[latest] == t){
      return latest;
    }

    if(storage[sig]!.vt.time.isEmpty || t < storage[sig]!.vt.time.first){
      return 0;
    }
    else if(t > storage[sig]!.vt.time[storage[sig]!.vt.size - 1]){
      return storage[sig]!.vt.size;
    }

    int partStart = after;
    int partEnd = storage[sig]!.vt.size - 1;
    double searchIndex = -1;
    while(partStart < partEnd){
      searchIndex = ((partStart + partEnd) / 2);
      if(storage[sig]!.vt.time[searchIndex.toInt()] < t){
        partStart = searchIndex.ceil();
      }
      else if(storage[sig]!.vt.time[searchIndex.toInt()] > t){
        partEnd = searchIndex.floor();
      }
      else{
        // direct hit
        return searchIndex.toInt();
      }
    }
    // nearest
    return searchIndex.toInt();
    }
}