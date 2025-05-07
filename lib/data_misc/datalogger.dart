import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';

import 'package:supaeromoon_ground_station/io/logger.dart';

import '../data_storage/signal_container.dart';

abstract class Datalogger{
  static String? _recordPath;
  static int logStartTime = 0;
  static bool hookEnabled = false;

  static bool get isSetup => _recordPath != null;

  static String? get getRecordPath => _recordPath;
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
    _recordPath = recordPath;
    return true;
  }

  static Future<bool> writeBytes(final Uint8List bytes) async {
    if(_recordPath == null){
      return false;
    }

    final File file = File(_recordPath!);

    if(await file.exists()){
      await file.writeAsBytes(bytes, mode: FileMode.append);
      return true;
    }
    else{
      localLogger.warning("Datalogger file does not exist at $_recordPath", doNoti: false);
      return false;
    }
  }

  static Future<Uint8List?> readBytes() async {
    if(_recordPath == null){
      return null;
    }

    final file = File(_recordPath!);
    file.open(mode: FileMode.read);

    if(await file.exists()){
      return await file.readAsBytes();
    }
    else{
      localLogger.warning("Datalogger file does not exist at $_recordPath", doNoti: false);
      return null;
    }
  }

  static Uint8List createBuffer(int timestamp, Uint8List buffer){
    Uint8List header = Uint8List(4 + 4);
    header.buffer.asByteData().setUint32(0, buffer.length);
    header.buffer.asByteData().setUint32(4, timestamp);

    return Uint8List.fromList([...header, ...buffer]);
  }

  static void maybeSaveData(final Uint8List bytes, int logStartTime){
    // if hook enabled
    // then createBuffer and save into file
    
    if(hookEnabled){
      int timestamp = DateTime.now().millisecondsSinceEpoch - logStartTime;
      (createBuffer(timestamp, bytes));
    }
  }

  static void startLogger(){
    // open file
    //final file = File('log.bin');
    _recordPath = 'log.bin';
    logStartTime = DateTime.now().millisecondsSinceEpoch;
    // enable hook in network code
    if(!hookEnabled){
      hookEnabled = true;
    }
  }

  static void stopLogger(){
    // disable hook
    if(hookEnabled){
      hookEnabled = false;
    }
  }
}