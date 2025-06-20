import 'dart:typed_data';

import 'package:supaeromoon_ground_station/data_source/database.dart';
import 'package:supaeromoon_ground_station/data_storage/signal_container.dart';
import 'package:supaeromoon_ground_station/io/localization.dart';
import 'package:supaeromoon_ground_station/io/logger.dart';

abstract class DataStorage{
  static Map<String, SignalContainer<TypedData>> storage = {};
  static Map<String, VectorSignalContainer<TypedData>> vectorStorage = {};

  static void setup(){
    for(final DBCMessage message in DBCDatabase.messages.values){
      for(final DBCSignal signal in message.signals.values){
        final ENumType type = signal.getType();
        switch (type) {
          case ENumType.NU8:
            storage[signal.name] = SignalContainer<Uint8List>.create(signal.name, Loc.get(signal.name), signal.unit);
            continue;
          case ENumType.NU16:
            storage[signal.name] = SignalContainer<Uint16List>.create(signal.name, Loc.get(signal.name), signal.unit);
            continue;
          case ENumType.NU32:
            storage[signal.name] = SignalContainer<Uint32List>.create(signal.name, Loc.get(signal.name), signal.unit);
            continue;
          case ENumType.NU64:
            storage[signal.name] = SignalContainer<Uint64List>.create(signal.name, Loc.get(signal.name), signal.unit);
            continue;
          case ENumType.NI8:
            storage[signal.name] = SignalContainer<Int8List>.create(signal.name, Loc.get(signal.name), signal.unit);
            continue;
          case ENumType.NI16:
            storage[signal.name] = SignalContainer<Int16List>.create(signal.name, Loc.get(signal.name), signal.unit);
            continue;
          case ENumType.NI32:
            storage[signal.name] = SignalContainer<Int32List>.create(signal.name, Loc.get(signal.name), signal.unit);
            continue;
          case ENumType.NI64:
            storage[signal.name] = SignalContainer<Int64List>.create(signal.name, Loc.get(signal.name), signal.unit);
            continue;
          case ENumType.NF32:
            storage[signal.name] = SignalContainer<Float32List>.create(signal.name, Loc.get(signal.name), signal.unit);
            continue;
        }
      }

      for(final DBCVectorSignal signal in message.vectorSignals){
        switch (signal.type) {
          case ENumType.NU8:
            vectorStorage[signal.name] = VectorSignalContainer<Uint8List>.create(signal.name, Loc.get(signal.name), Uint8List(0), signal.unit);
            continue;
          case ENumType.NU16:
            vectorStorage[signal.name] = VectorSignalContainer<Uint16List>.create(signal.name, Loc.get(signal.name), Uint16List(0), signal.unit);
            continue;
          case ENumType.NU32:
            vectorStorage[signal.name] = VectorSignalContainer<Uint32List>.create(signal.name, Loc.get(signal.name), Uint32List(0), signal.unit);
            continue;
          case ENumType.NU64:
            vectorStorage[signal.name] = VectorSignalContainer<Uint64List>.create(signal.name, Loc.get(signal.name), Uint64List(0), signal.unit);
            continue;
          case ENumType.NI8:
            vectorStorage[signal.name] = VectorSignalContainer<Int8List>.create(signal.name, Loc.get(signal.name), Int8List(0), signal.unit);
            continue;
          case ENumType.NI16:
            vectorStorage[signal.name] = VectorSignalContainer<Int16List>.create(signal.name, Loc.get(signal.name), Int16List(0), signal.unit);
            continue;
          case ENumType.NI32:
            vectorStorage[signal.name] = VectorSignalContainer<Int32List>.create(signal.name, Loc.get(signal.name), Int32List(0), signal.unit);
            continue;
          case ENumType.NI64:
            vectorStorage[signal.name] = VectorSignalContainer<Int64List>.create(signal.name, Loc.get(signal.name), Int64List(0), signal.unit);
            continue;
          case ENumType.NF32:
            vectorStorage[signal.name] = VectorSignalContainer<Float32List>.create(signal.name, Loc.get(signal.name), Float32List(0), signal.unit);
            continue;
        }
      }
    }
  }

  static void clear(){
    for(final DBCMessage message in DBCDatabase.messages.values){
      for(final DBCSignal signal in message.signals.values){
        storage[signal.name]!.vt.clear();
      }

      for(final DBCVectorSignal signal in message.vectorSignals){
        vectorStorage[signal.name]!.time = 0;
        switch (signal.type) {
          case ENumType.NU8:
            vectorStorage[signal.name]!.value = Uint8List(0);
            continue;
          case ENumType.NU16:
            vectorStorage[signal.name]!.value = Uint16List(0);
            continue;
          case ENumType.NU32:
            vectorStorage[signal.name]!.value = Uint32List(0);
            continue;
          case ENumType.NU64:
            vectorStorage[signal.name]!.value = Uint64List(0);
            continue;
          case ENumType.NI8:
            vectorStorage[signal.name]!.value = Int8List(0);
            continue;
          case ENumType.NI16:
            vectorStorage[signal.name]!.value = Int16List(0);
            continue;
          case ENumType.NI32:
            vectorStorage[signal.name]!.value = Int32List(0);
            continue;
          case ENumType.NI64:
            vectorStorage[signal.name]!.value = Int64List(0);
            continue;
          case ENumType.NF32:
            vectorStorage[signal.name]!.value = Float32List(0);
            continue;
        }
      }
    }
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
    if(searchIndex == -1){
      return 0;
    }
    return searchIndex.toInt();
    }
}