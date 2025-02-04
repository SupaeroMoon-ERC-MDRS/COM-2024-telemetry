import 'dart:typed_data';
import 'dart:io';

import 'package:supaeromoon_ground_station/io/logger.dart';

abstract class Datalogger{
  static String? _recordPath;

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

  Future<bool> writeBytes(final Uint8List bytes) async {
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

  Future<Uint8List?> readBytes() async {
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
}