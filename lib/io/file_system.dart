import 'dart:io';
import 'dart:typed_data';

import 'package:supaeromoon_ground_station/io/logger.dart';
import 'package:supaeromoon_ground_station/io/serdes.dart';



abstract class FileSystem{

  static String? _currentDirectory;

  static String get topDir => "/";
  static String get localeDir => "Locale/";

  static Future<String?> get getCurrentDirectory async {
    if(_currentDirectory != null){
      return _currentDirectory;
    }
    String dir = Platform.resolvedExecutable;
    if(Platform.isWindows){
      dir = dir.replaceAll(r'\', '/');
    }
    dir = dir.split('/').reversed.toList().sublist(1).reversed.toList().join('/');
    if(Platform.isWindows){
      dir = dir.replaceAll('/', r'\');
      dir = dir + r'\';
      _currentDirectory = dir;
      return dir;
    }
    else if(Platform.isLinux){
      dir = dir + r'/';
      _currentDirectory = dir;
      return dir;
    }
    else{
      localLogger.error("Unsupported operating system, FileSystem.getCurrentDirectory only supports Linux and Windows", doNoti: false);
      return null;
    }
  }

  static Future<void> trySaveMapToLocalAsync(final String path, final String filename, final Map jsonEncodeable, {final bool withIndent = false}) async {
    if(await getCurrentDirectory == null){
      localLogger.error("Cant determine current directory", doNoti: false);
      return;
    }
    final File file = await File("${_currentDirectory}Local/$path$filename").create(recursive: true);
    final RandomAccessFile access = await file.open(mode: FileMode.write);
    
    if(withIndent){
      await access.writeFrom(SerDes.prettyJsonToBytes(jsonEncodeable));
    }
    else{
      await access.writeFrom(SerDes.jsonToBytes(jsonEncodeable));
    }
    await access.close();
  }

  static void trySaveMapToLocalSync(final String path, final String filename, final Map jsonEncodeable, {final bool withIndent = false}){
    if(_currentDirectory == null){
      localLogger.error("Cant determine current directory", doNoti: false);
      return;
    }
    final File file = File("${_currentDirectory}Local/$path$filename")..createSync(recursive: true);
    final RandomAccessFile access = file.openSync(mode: FileMode.write);
    
    if(withIndent){
      access.writeFromSync(SerDes.prettyJsonToBytes(jsonEncodeable));
    }
    else{
      access.writeFromSync(SerDes.jsonToBytes(jsonEncodeable));
    }
    access.closeSync();
  }

  static Future<Map> tryLoadMapFromLocalAsync(final String path, final String filename, {final bool deleteWhenDone = false}) async {
    if(await getCurrentDirectory == null){
      localLogger.error("Cant determine current directory", doNoti: false);
      return {};
    }
    final File file = File("${_currentDirectory}Local/$path$filename");
    if(!(await file.exists())){
      return {};
    }
    final RandomAccessFile access = await file.open(mode: FileMode.read);
    List<int> buffer = List.filled(await file.length(), -1);
    await access.readInto(buffer);
    await access.close();
    if(deleteWhenDone){
      await file.delete();
    }
    try{
      return SerDes.jsonFromBytes(buffer) as Map;
    }catch(ex){
      localLogger.error("Cannot parse json at ${file.absolute.path}");
      return {};
    }
  }

  static Map tryLoadMapFromLocalSync(final String path, final String filename, {final bool deleteWhenDone = false}){
    if(_currentDirectory == null){
      localLogger.error("Cant determine current directory", doNoti: false);
      return {};
    }
    final File file = File("${_currentDirectory}Local/$path$filename");
    if(!file.existsSync()){
      return {};
    }
    List<int> buffer = file.readAsBytesSync();
    if(deleteWhenDone){
      file.deleteSync();
    }
    try{
      return SerDes.jsonFromBytes(buffer) as Map ;
    }catch(ex){
      localLogger.error("Cannot parse json at ${file.absolute.path}");
      return {};
    }
  }

  static Future<void> trySaveBytesToLocalAsync(final String path, final String filename, final Uint8List bytes) async {
    if(await getCurrentDirectory == null){
      localLogger.error("Cant determine current directory", doNoti: false);
      return;
    }
    final File file = await File("${_currentDirectory}Local/$path$filename").create(recursive: true);
    final RandomAccessFile access = await file.open(mode: FileMode.write);
    await access.writeFrom(bytes);
    await access.close();
  }

  static void trySaveBytesToLocalSync(final String path, final String filename, final Uint8List bytes){
    if(_currentDirectory == null){
      localLogger.error("Cant determine current directory", doNoti: false);
      return;
    }
    final File file = File("${_currentDirectory}Local/$path$filename")..createSync(recursive: true);
    final RandomAccessFile access = file.openSync(mode: FileMode.write);
    access.writeFromSync(bytes);
    access.closeSync();
  }

  static Future<Uint8List> tryLoadBytesFromLocalAsync(final String path, final String filename, {final bool deleteWhenDone = false}) async {
    if(await getCurrentDirectory == null){
      localLogger.error("Cant determine current directory", doNoti: false);
      return Uint8List(0);
    }
    final File file = File("${_currentDirectory}Local/$path$filename");
    if(!(await file.exists())){
      return Uint8List(0);
    }
    final RandomAccessFile access = await file.open(mode: FileMode.read);
    Uint8List buffer = Uint8List(await file.length());
    await access.readInto(buffer);
    await access.close();
    if(deleteWhenDone){
      await file.delete();
    }
    return buffer;
  }

  static Uint8List tryLoadBytesFromLocalSync(final String path, final String filename, {final bool deleteWhenDone = false}){
    if(_currentDirectory == null){
      localLogger.error("Cant determine current directory", doNoti: false);
      return Uint8List(0);
    }
    final File file = File("${_currentDirectory}Local/$path$filename");
    if(!file.existsSync()){
      return Uint8List(0);
    }
    Uint8List buffer = file.readAsBytesSync();
    if(deleteWhenDone){
      file.deleteSync();
    }
    return buffer;
  }

  static Future<void> tryDeleteFromLocalAsync(final String path, final String filename) async {
    if(await getCurrentDirectory == null){
      localLogger.error("Cant determine current directory", doNoti: false);
      return;
    }
    final File file = File("${_currentDirectory}Local/$path$filename");
    if(await file.exists()){
      await file.delete();
      localLogger.info("File ${file.absolute} was successfully removed", doNoti: false);
    }
    else{
      localLogger.warning("File ${file.absolute} cannot be removed as it doesnt exist");
    }
  }

  static void tryDeleteFromLocalSync(final String path, final String filename){
    if(_currentDirectory == null){
      localLogger.error("Cant determine current directory", doNoti: false);
      return;
    }
    final File file = File("${_currentDirectory}Local/$path$filename");
    if(file.existsSync()){
      file.deleteSync();
      localLogger.info("File ${file.absolute} was successfully removed", doNoti: false);
    }
    else{
      localLogger.warning("File ${file.absolute} cannot be removed as it doesnt exist");
    }
  }

  static Future<List<FileSystemEntity>> tryListElementsInLocalAsync(final String path) async {
    if(await getCurrentDirectory == null){
      localLogger.error("Cant determine current directory", doNoti: false);
      return [];
    }
    Directory("${_currentDirectory}Local/$path");
    final Directory dir = Directory("${_currentDirectory}Local/$path");
    if(await dir.exists()){
      return dir.list().toList();
    }
    else{
      return [];
    }
  }

  static List<FileSystemEntity> tryListElementsInLocalSync(final String path){
    if(_currentDirectory == null){
      localLogger.error("Cant determine current directory", doNoti: false);
      return [];
    }
    final Directory dir = Directory("${_currentDirectory}Local/$path");
    if(dir.existsSync()){
      return dir.listSync();
    }
    else{
      return [];
    }
  }
}