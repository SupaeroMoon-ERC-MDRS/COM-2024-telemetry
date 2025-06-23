import 'dart:typed_data';
import 'dart:io';

import 'package:supaeromoon_ground_station/data_storage/session.dart';
import 'package:supaeromoon_ground_station/io/logger.dart';


abstract class Datalogger{
  static int _logStartTime = 0;
  static bool _hookEnabled = false;

  static bool get isRunning => _hookEnabled;

  static bool setRecordPath(final String recordPath, [final bool autoDiscard = false]){
    final File file = File(recordPath);

    if(file.existsSync()){
      if(autoDiscard){
        file.deleteSync();
        file.createSync();
      }
      else{
        return false;
      }
    }
    else{
      file.createSync();
    }

    Session.logSavePath = recordPath;
    return true;
  }

  static Future<bool> _writeBytes(final Uint8List bytes) async {
    final File file = File(Session.logSavePath);

    if(await file.exists()){
      await file.writeAsBytes(bytes, mode: FileMode.append);
      return true;
    }
    else{
      localLogger.warning("Datalogger file does not exist at ${Session.logSavePath}");
      return false;
    }
  }

  static Future<Uint8List?> readBytes() async {
    final File file = File(Session.logReadPath);

    if(await file.exists()){
      return await file.readAsBytes();
    }
    else{
      localLogger.warning("Datalogger file does not exist at ${Session.logReadPath}");
      return null;
    }
  }

  static Uint8List _createBuffer(int timestamp, Uint8List buffer){
    Uint8List header = Uint8List(4 + 4);
    header.buffer.asByteData().setUint32(0, buffer.length);
    header.buffer.asByteData().setUint32(4, timestamp);

    return Uint8List.fromList([...header, ...buffer]);
  }

  static void maybeSaveData(final Uint8List bytes, int timestamp){    
    if(_hookEnabled){
      int ts = timestamp - _logStartTime;
      _writeBytes(_createBuffer(ts, bytes));
    }
  }

  static void startLogger(){
    _logStartTime = DateTime.now().millisecondsSinceEpoch;

    if(!setRecordPath(Session.logSavePath)){
      localLogger.warning("Log file already exists");
      return;
    }

    _hookEnabled = true;
  }

  static void stopLogger() => _hookEnabled = false;
}