import 'package:supaeromoon_ground_station/io/file_system.dart';

abstract class Session{
  static int bufferMs = 1000 * 60;
  static List<String> dbcPaths = [];
  static int chartRefreshMs = 16;
  static int tabIndex = 0;
  static String subnet = "192.168.43.";
  static String raspiIp = "192.168.43.156";
  static String logSavePath = "log.bin";
  static String logReadPath = "log.bin";

  static void save(){
    FileSystem.trySaveMapToLocalSync(FileSystem.topDir, "SESSION", {
      "bufferMs": bufferMs,
      "dbcPaths": dbcPaths,
      "chartRefreshMs": chartRefreshMs,
      "tabIndex": tabIndex,
      "subnet": subnet,
      "raspiIp": raspiIp,
      "logSavePath": logSavePath,
      "logReadPath": logReadPath,
    });
  }
  
  static void load(){
    Map data = FileSystem.tryLoadMapFromLocalSync(FileSystem.topDir, "SESSION");

    if(data.containsKey("bufferMs") && data["bufferMs"] is int){
      bufferMs = data["bufferMs"];
    }

    if(data.containsKey("dbcPaths") && data["dbcPaths"] is List){
      dbcPaths = data["dbcPaths"].cast<String>();
    }

    if(data.containsKey("chartRefreshMs") && data["chartRefreshMs"] is int){
      chartRefreshMs = data["chartRefreshMs"];
    }

    if(data.containsKey("tabIndex") && data["tabIndex"] is int){
      tabIndex = data["tabIndex"];
    }

    if(data.containsKey("subnet") && data["subnet"] is String){
      subnet = data["subnet"];
    }

    if(data.containsKey("raspiIp") && data["raspiIp"] is String){
      raspiIp = data["raspiIp"];
    }

    if(data.containsKey("logSavePath") && data["logSavePath"] is String){
      logSavePath = data["logSavePath"];
    }
    
    if(data.containsKey("logReadPath") && data["logReadPath"] is String){
      logReadPath = data["logReadPath"];
    }
  }
}