import 'package:supaeromoon_ground_station/data_storage/signal_container.dart';
import 'package:supaeromoon_ground_station/io/logger.dart';

abstract class DataStorage{
  static Map<String, SignalContainer> storage = {};

  static void update(final String sig, final num v, final int t){
    if(!storage.containsKey(sig)){
      localLogger.warning("A signal update was received for $sig but corresponding buffer was not set up", doNoti: false);
      return;
    }
    num last = (storage[sig]!.vt.value as List).last;
    storage[sig]!.vt.pushback(v, t);
    storage[sig]!.everyUpdateNotifier.update();
    if(storage[sig]!.vt.isNotEmpty && (storage[sig]!.vt.value as List).last != last){
      storage[sig]!.changeNotifier.update();
    }
  }

  static void discardIfOlderThan(final num t){
    for(final String sig in storage.keys){
      if(storage[sig]!.vt.time.first >= t){
        continue;
      }
      
      int pos = storage[sig]!.vt.time.indexWhere((ts) => ts >= t);
      storage[sig]!.everyUpdateNotifier.update();
      if(pos == -1){
        storage[sig]!.vt.clear();
        storage[sig]!.changeNotifier.update();
      }
      else{
        storage[sig]!.vt.popfront(pos);
      }
    }
  }
}