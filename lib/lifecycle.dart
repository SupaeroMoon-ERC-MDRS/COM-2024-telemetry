import 'dart:io';

import 'package:supaeromoon_ground_station/data_source/data_source.dart';
import 'package:supaeromoon_ground_station/data_source/database.dart';
import 'package:supaeromoon_ground_station/data_storage/data_storage.dart';
import 'package:supaeromoon_ground_station/data_storage/session.dart';
import 'package:supaeromoon_ground_station/io/file_system.dart';
import 'package:supaeromoon_ground_station/io/logger.dart';
import 'package:window_manager/window_manager.dart';

abstract class LifeCycle{
  static Future<void> preInit() async {
    await FileSystem.getCurrentDirectory;
    localLogger = Logger(mainLogPath, "Master");
    localLogger.start();
    Session.load();
    for(final String path in Session.dbcPaths){
      if(DBCDatabase.parse(path)){
        localLogger.info("Successfully loaded dbc at $path");
      }
      else{
        localLogger.warning("Error when loading dbc at $path");
      }
    }
    DataStorage.setup();
  }

  static void postInit(WindowListener root){
    windowManager.maximize();
    windowManager.addListener(root);
    windowManager.setPreventClose(true);
    DataSource.net();
  }

  static Future<void> shutdown() async {
    DataSource.stop();
    Session.save();
    await localLogger.stop();
    exit(0);
  }
}