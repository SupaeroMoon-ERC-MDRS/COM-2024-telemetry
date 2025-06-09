import 'package:supaeromoon_ground_station/data_misc/eval/eval.dart';
import 'package:supaeromoon_ground_station/data_storage/data_storage.dart';
import 'package:supaeromoon_ground_station/io/file_system.dart';
import 'package:supaeromoon_ground_station/io/logger.dart';
import 'package:supaeromoon_ground_station/io/serdes.dart';

class Alarm{
  final String name;
  final String expr;
  final bool active;
  final ExecTree exec;
  bool triggered = false;
  final List<String> requiredSignals = [];

  Alarm._({
    required this.name,
    required this.active,
    required this.expr,
    required this.exec
  }){
    requiredSignals.addAll(Evaluator.requiredSignals(exec));
  }

  bool get canTrigger => active & !triggered;

  bool register(){
    for(final String signal in requiredSignals){
      if(DataStorage.storage.containsKey(signal)){
        DataStorage.storage[signal]!.changeNotifier.addListener(_check);
      }
      else{
        deregister();
        return false;
      }
    }
    return true;
  }

  void deregister(){
    for(final String signal in requiredSignals){
      if(DataStorage.storage.containsKey(signal)){
        DataStorage.storage[signal]!.changeNotifier.removeListener(_check);
      }
    }
  }

  void _check(){
    if(canTrigger && requiredSignals.every((final String signal) => DataStorage.storage[signal]!.vt.isNotEmpty) && Evaluator.eval<bool>(exec)){
      triggered = true;
      // TODO play sound
      // TODO do notif
    }
  }

  Map get asMap => {
    "name": name,
    "expr": expr,
    "active": active
  };

  factory Alarm.fromMap(final Map map){
    return Alarm._(name: map["name"], active: map["active"], expr: map["expr"], exec: Evaluator.compile<bool>(map["expr"]));
  }
}

abstract class AlarmController{
  static final List<Alarm> _alarms = [];

  static List<Alarm> get alarms => _alarms;

  static void load(){
    final List<Map> ser;
    try{
      ser = SerDes.jsonFromBytes(
        FileSystem.tryLoadBytesFromLocalSync(FileSystem.topDir, "ALARMS")
      ) as List<Map>;
    }catch(ex){
      localLogger.error("Failed to load alarms: ${ex.toString()}");
      return;
    }

    _alarms.addAll(ser.map((e){
      try{
        return Alarm.fromMap(e);
      }catch(ex){
        localLogger.error("Failed to parse alarm: ${ex.toString()}");
        return Alarm._(name: "NOSIG", expr: "", active: false, exec: ExecTree.empty());
      }
    }));
    _alarms.removeWhere((alarm) => alarm.name == "NOSIG");

    for(final Alarm alarm in _alarms){
      alarm.register();
    }
  }

  static void add(final Alarm alarm){
    _alarms.add(alarm..register());
  }

  static void remove(final int index){
    _alarms.removeAt(index).deregister();
  }

  static void save(){
    FileSystem.trySaveBytesToLocalAsync(FileSystem.topDir, "ALARMS", 
      SerDes.jsonToBytes(_alarms.map((e) => e.asMap).toList())
    );
  }
}