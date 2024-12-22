import 'dart:async';
import 'dart:io';

const String mainLogPath = "./Logs/3D.log";
Logger localLogger = Logger(mainLogPath, "Initial Logger");

enum LogLevel{
  // ignore: constant_identifier_names
  INFO,
  // ignore: constant_identifier_names
  WARNING,
  // ignore: constant_identifier_names
  ERROR,
  // ignore: constant_identifier_names
  CRITICAL
}

class LogEntry{
  final String message;
  final LogLevel level;
  final DateTime timeStamp;

  const LogEntry(this.message, this.level, this.timeStamp);

  static LogEntry info(final String message){
    return LogEntry(message, LogLevel.INFO, DateTime.now());
  }

  static LogEntry warning(final String message){
    return LogEntry(message, LogLevel.WARNING, DateTime.now());
  }

  static LogEntry error(final String message){
    return LogEntry(message, LogLevel.ERROR, DateTime.now());
  }

  static LogEntry critical(final String message){
    return LogEntry(message, LogLevel.CRITICAL, DateTime.now());
  }

  String asString(final String loggerName) => "[$timeStamp] [$loggerName - ${level.name.toUpperCase()}] $message";
}

class Logger{
  List<LogEntry> _buffer = [];
  bool _isActive = false;
  Timer? timer;
  int loggerFlushIntervalMS = 1000;
  final String logPath;
  final String loggerName;

  Logger(this.logPath, this.loggerName);

  void start(){
    if(_isActive){
      return;
    }

    final File logFile = File(logPath);
    if(logFile.existsSync()){
      logFile.deleteSync();
    }

    _isActive = true;
    timer = Timer.periodic(Duration(milliseconds: loggerFlushIntervalMS), ((timer) async {
      await __flush();
    }));
  }

  Future<void> stop() async {
    if(!_isActive){
      return;
    }
    _isActive = false;
    timer?.cancel();
    await __flush();
  }

  void __sleep(){
    timer?.cancel();
  }

  void __wake(){
    if(timer?.isActive ?? false){
      return;
    }
    timer = Timer.periodic(Duration(milliseconds: loggerFlushIntervalMS), ((timer) async {
      await __flush();
    }));
  }

  void info(final String message, {final bool doNoti = true}){
    if(!_isActive){
      return;
    }
    add(LogEntry(message, LogLevel.INFO, DateTime.now()), doNoti: doNoti);
  }

  void warning(final String message, {final bool doNoti = true}){
    if(!_isActive){
      return;
    }
    add(LogEntry(message, LogLevel.WARNING, DateTime.now()), doNoti: doNoti);
  }

  void error(final String message, {final bool doNoti = true}){
    if(!_isActive){
      return;
    }
    add(LogEntry(message, LogLevel.ERROR, DateTime.now()), doNoti: doNoti);
  }

  void critical(final String message, {final bool doNoti = true}){
    if(!_isActive){
      return;
    }
    add(LogEntry(message, LogLevel.CRITICAL, DateTime.now()), doNoti: doNoti);
  }

  void addAll(final List<LogEntry> entries){
    _buffer.addAll(entries);
    if(entries.isNotEmpty){
      __wake();
    }
  }

  void add(final LogEntry entry, {final bool doNoti = false}){
    _buffer.add(entry);
    __wake();
    if(doNoti){
      //NotificationController.add(Notification(entry: entry, durationMs: 10000, isDecaying: entry.level.index <= 1));
    }
  }

  Future<void> __flush() async {
    if(_buffer.isEmpty){
      __sleep();
      return;
    }

    final File logFile = File(logPath);
    if(!await logFile.exists()){
      await logFile.create(recursive: true);
    }
    final RandomAccessFile access = await logFile.open(mode: FileMode.append);
    final List<LogEntry> copy = _buffer;
    await access.writeString(__contentsToString(copy));
    _buffer = _buffer.skip(copy.length).toList();
    await access.close();
  }

  String __contentsToString(final List<LogEntry> data){
    String str = "";
    for(LogEntry line in data){
      str = "$str[${line.timeStamp}] [$loggerName - ${line.level.name.toUpperCase()}] ${line.message}\n";
    }
    return str;
  }
}