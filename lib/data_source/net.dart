import 'dart:async';
import 'dart:io';

import 'package:supaeromoon_ground_station/data_source/data_source.dart';
import 'package:supaeromoon_ground_station/data_source/database.dart';
import 'package:supaeromoon_ground_station/data_source/netcode_interop.dart';
import 'package:supaeromoon_ground_station/data_storage/data_storage.dart';
import 'package:supaeromoon_ground_station/data_storage/session.dart';
import 'package:supaeromoon_ground_station/io/logger.dart';

const String _subnet = "10.70.";
late final String _wlanIp;

abstract class Net{
  static late NetCode _net;
  static late Timer _timer;
  static int _lastConnectionAttempt = 0;
  static bool _hasRover = false;
  static bool _hasRemote = false;

  static Map<String, bool> getStatus(){
    return {
      "rover": _hasRover,
      "remote": _hasRemote,
    };
  }

  static Future<void> getWlanIp() async{
    if(Platform.isWindows){
      _wlanIp = "";
    }
    else if(Platform.isLinux){
      ProcessResult res = await Process.run("ip", ["a"]);
      final List<String> lines = (res.stdout as String).split('\n')
        .map((final String e) => e.trim())
        .where((final String e) => e.startsWith('inet '))
        .map((final String e) => e.split(' ')[1].split('/')[0])
        .toList();
      
      _wlanIp = lines.firstWhere((final String e) => e.startsWith(_subnet), orElse: () => "",);
    }
    else{
      _wlanIp = "";
    }
  }

  static Future<bool> _setup() async {
    _net = NetCode();
    final bool success = _net.init(DBCDatabase.dbcVersion, 12123, _wlanIp, NodeType.gs);

    if(success){
      return true;
    }
    else{
      localLogger.warning("Could not initialize net data source");
      return false;
    }
  }

  static void start() async {
    await _setup();
    _timer = Timer.periodic(const Duration(milliseconds: 1), (timer) async {
      if(_net.isInitialized() && !_net.needReset()){
        if(timer.tick - _lastConnectionAttempt > 1000){ // every 1 sec TODO session
          _lastConnectionAttempt = timer.tick;

          if(!_net.hasPublishersType(NodeType.rover)){
            _net.sendConn(12121);
            _hasRover = false;
          }
          else{
            _hasRover = true;
          }

          if(!_net.hasPublishersType(NodeType.remote)){
            _net.sendConn(12122);
            _hasRemote = false;
          }
          else{
            _hasRemote = true;
          }
        }

        _net.recv();
        final List<RecvPacket> packets = [];
        _net.getPackets(packets);

        final List<MapEntry<int, Map<String, dynamic>>> rec = [];
        for(final RecvPacket pack in packets){
          rec.addAll(DBCDatabase.decode(pack.buf));
        }

        final int recTime = DataSource.now();

        for(final MapEntry<int, Map<String, dynamic>> msg in rec){
          for(final String sig in msg.value.keys){
            DataStorage.update(sig, msg.value[sig]!, recTime);
          }
        }
        DataStorage.discardIfOlderThan(recTime - Session.bufferMs);
      }
      else{
        _net.reset(DBCDatabase.dbcVersion, 12123, _wlanIp, NodeType.gs);
      }
    });
  }

  static void stop(){
    _timer.cancel();
    _net.shutdown();
    _hasRover = false;
    _hasRemote = false;
    _net.destroy();
  }
}