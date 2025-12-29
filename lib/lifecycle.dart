import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:supaeromoon_ground_station/data_misc/alarm.dart';
import 'package:supaeromoon_ground_station/data_misc/virtual_signals.dart';
import 'package:supaeromoon_ground_station/data_source/data_source.dart';
import 'package:supaeromoon_ground_station/data_source/database.dart';
import 'package:supaeromoon_ground_station/data_source/netcode_interop.dart';
import 'package:supaeromoon_ground_station/data_storage/data_storage.dart';
import 'package:supaeromoon_ground_station/data_storage/session.dart';
import 'package:supaeromoon_ground_station/data_storage/unit_system.dart';
import 'package:supaeromoon_ground_station/io/file_system.dart';
import 'package:supaeromoon_ground_station/io/localization.dart';
import 'package:supaeromoon_ground_station/io/logger.dart';
import 'package:window_manager/window_manager.dart';

abstract class LifeCycle {
  static Future<void> preInit() async {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();
    FileSystem.getCurrentDirectory;
    localLogger = Logger(mainLogPath, "Master");
    localLogger.start();
    Session.load();
    Loc.load();
    Loc.setLanguage("en-EN");
    await UnitSystem.loadFromDisk();
    for (final String path in Session.dbcPaths) {
      if (DBCDatabase.parse(path)) {
        localLogger.info("Successfully loaded dbc at $path");
      } else {
        localLogger.warning("Error when loading dbc at $path");
      }
    }
    DataStorage.setup();
    await SoundLibrary.init();
    VirtualSignalController.load();
    AlarmController.load();
  }

  static void postInit(WindowListener root) {
    appWindow.maximizeOrRestore();
    windowManager.addListener(root);
    windowManager.setPreventClose(true);
    if (NetCode.loadDLL()) {
      DataSource.selftest();
    } else {
      DataSource.selftest();
      localLogger.critical(
          "Netcode loading failed, Network mode is unavailable",
          doNoti: true);
    }
  }

  static Future<void> shutdown() async {
    Session.save();
    try {
      DataSource.stop();
      VirtualSignalController.save();
      AlarmController.save();

      // ignore: empty_catches
    } catch (ex) {}

    await localLogger.stop();
    exit(0);
  }
}
