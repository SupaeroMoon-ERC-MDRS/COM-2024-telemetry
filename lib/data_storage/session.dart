import 'package:supaeromoon_ground_station/io/file_system.dart';

abstract class Session{
  static int bufferMs = 1000 * 10;
  static int telemetryPort = 12121;
  static int remotePort = 12122;

  static void save(){
    FileSystem.trySaveMapToLocalSync(FileSystem.topDir, "SESSION", {
      "bufferMs": bufferMs,
      "telemetryPort": telemetryPort,
      "remotePort": remotePort,
    });
  }
  
  static void load(){
    Map data = FileSystem.tryLoadMapFromLocalSync(FileSystem.topDir, "SESSION");

    if(data.containsKey("bufferMs") && data["bufferMs"] is int){
      bufferMs = data["bufferMs"];
    }

    if(data.containsKey("telemetryPort") && data["telemetryPort"] is int){
      telemetryPort = data["telemetryPort"];
    }

    if(data.containsKey("remotePort") && data["remotePort"] is int){
      remotePort = data["remotePort"];
    }
  }
}