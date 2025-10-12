import 'dart:io';

import 'package:supaeromoon_ground_station/io/file_system.dart';

abstract class Session{
  static int bufferMs = 1000 * 60;
  static List<String> dbcPaths = [];
  static int chartRefreshMs = 16;
  static int tabIndex = 0;
  static int reconnectTimerMs = 1000;
  static String subnet = "192.168.43.";
  static String raspiIp = "192.168.43.43";
  static String logSavePath = "log.bin";
  static String logReadPath = "log.bin";
  static String netCodePath = Platform.isWindows ? "udpcan-net-exports.dll" : Platform.isLinux ? "libudpcan-net-exports.so" : throw Exception("Unsupported platform");
  static String remotePath = "";

  static void save(){
    FileSystem.trySaveMapToLocalSync(FileSystem.topDir, "SESSION", {
      "bufferMs": bufferMs,
      "dbcPaths": dbcPaths,
      "chartRefreshMs": chartRefreshMs,
      "tabIndex": tabIndex,
      "reconnectTimerMs": reconnectTimerMs,
      "subnet": subnet,
      "raspiIp": raspiIp,
      "logSavePath": logSavePath,
      "logReadPath": logReadPath,
      "netCodePath": netCodePath,
      "remotePath": remotePath,
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

    if(data.containsKey("reconnectTimerMs") && data["reconnectTimerMs"] is int){
      reconnectTimerMs = data["reconnectTimerMs"];
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
    
    if(data.containsKey("netCodePath") && data["netCodePath"] is String){
      netCodePath = data["netCodePath"];
    }
    
    if(data.containsKey("remotePath") && data["remotePath"] is String){
      remotePath = data["remotePath"];
    }
  }
}