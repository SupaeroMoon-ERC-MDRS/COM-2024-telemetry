import 'package:unittests/file_system.dart';
import 'package:unittests/logger.dart';

import 'test/unittests.dart';

void main(){
  FileSystem.setCurrentDirectory("");
  localLogger = Logger(mainLogPath, "Test Logger");
  localLogger.start();
  testUnitSystem();
}