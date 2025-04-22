import 'dart:async';
import 'dart:typed_data';

import 'package:supaeromoon_ground_station/data_source/data_source.dart';
import 'package:supaeromoon_ground_station/data_source/database.dart';
import 'package:supaeromoon_ground_station/data_source/netcode_interop.dart';
import 'package:supaeromoon_ground_station/data_storage/data_storage.dart';
import 'package:supaeromoon_ground_station/data_storage/session.dart';
import 'package:supaeromoon_ground_station/io/logger.dart';

abstract class Net{
  static late NetCode _net;
  static late Timer _timer;

  static bool _setup(){
    _net = NetCode();
    final bool success = _net.init(DBCDatabase.dbcVersion, 12123, NodeType.gs);

    if(success){
      return true;
    }
    else{
      localLogger.warning("Could not initialize net data source");
      return false;
    }
  }

  static void start(){
    _setup();
    _timer = Timer.periodic(const Duration(milliseconds: 1), (timer) {
      if(_net.isInitialized() && !_net.needReset()){
        if(timer.tick & 0xFF == 0){
          if(!_net.hasPublishersType(NodeType.rover)){
            _net.sendConn(12121);
          }        
          if(!_net.hasPublishersType(NodeType.remote)){
            _net.sendConn(12122);
          }
        }

        _net.recv();
        final List<RecvPacket> packets = [];
        _net.getPackets(packets);

        final List<MapEntry<int, Map<String, num>>> rec = [];
        for(final RecvPacket pack in packets){
          rec.addAll(DBCDatabase.decode(pack.buf));
        }

        final int recTime = DataSource.now();

        for(final MapEntry<int, Map<String, num>> msg in rec){
          for(final String sig in msg.value.keys){
            DataStorage.update(sig, msg.value[sig]!, recTime);
          }
        }
        DataStorage.discardIfOlderThan(recTime - Session.bufferMs);
      }
      else{
        _net.reset(DBCDatabase.dbcVersion, 12123, NodeType.gs);
      }
    });
  }

  static void stop(){
    _timer.cancel();
    _net.destroy();
  }
}