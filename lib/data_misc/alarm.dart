import 'package:supaeromoon_ground_station/data_misc/eval/eval.dart';
import 'package:supaeromoon_ground_station/data_misc/virtual_signals.dart';
import 'package:supaeromoon_ground_station/data_source/database.dart';
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
  final List<String> inputs = [];
  final List<String> regSignals = [];

  Alarm._({
    required this.name,
    required this.active,
    required this.expr,
    required this.exec
  }){
    inputs.addAll(Evaluator.requiredSignals(exec));
  }

  bool get canTrigger => active & !triggered;

  void _regSignalsCalc(final List<VirtualSignal> virtualSignals){
    final List<String> signalInputs = [];
    final List<String> virtualInputs = [];

    for(final String sig in inputs){
      if(virtualSignals.any((v) => v.name == sig)){
        virtualInputs.add(sig);
      }
      else{
        signalInputs.add(sig);
      }
    }

    final Set<int> signalMessageReq = {};
    final Set<int> virtualDependency = {};
    final Set<String> requirement = {};
    final Set<String> dependency = {};

    for(final String signal in signalInputs){
      signalMessageReq.add(
        DBCDatabase.messages.entries.firstWhere((message) => 
          message.value.signals.containsKey(signal)).key
      );
    }

    for(final String signal in virtualInputs){
      requirement.add(signal);
      final List<String> thisInputs = virtualSignals.firstWhere((v) => v.name == signal).inputs;
      for(final String dep in thisInputs){
        if(virtualSignals.any((v) => v.name == dep)){
          dependency.add(dep);
        }
        else{
          virtualDependency.add(
            DBCDatabase.messages.entries.firstWhere((message) => 
              message.value.signals.containsKey(signal)).key
          );
        }
      }
    }

    final Set<String> req = signalMessageReq.difference(virtualDependency).map((e) => DBCDatabase.messages[e]!.signals.keys.last).toSet();
    final Set<String> virtualReq = requirement.difference(dependency);
    regSignals.clear();
    regSignals.addAll([...req, ...virtualReq]);
  }
  
  bool register(final List<VirtualSignal> virtualSignals){
    _regSignalsCalc(virtualSignals);

    for(final String signal in regSignals){
      if(DataStorage.storage.containsKey(signal)){
        DataStorage.storage[signal]!.everyUpdateNotifier.addListener(_check);
      }
      else{
        deregister();
        return false;
      }
    }
    return true;
  }

  void deregister(){
    for(final String signal in regSignals){
      if(DataStorage.storage.containsKey(signal)){
        DataStorage.storage[signal]!.everyUpdateNotifier.removeListener(_check);
      }
    }
  }

  void _check(){
    if(canTrigger && inputs.every((final String signal) => DataStorage.storage[signal]!.vt.isNotEmpty) && Evaluator.eval<bool>(exec)){
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
      alarm.register(VirtualSignalController.virtualSignalsView);
    }
  }

  static void add(final Alarm alarm){
    _alarms.add(alarm..register(VirtualSignalController.virtualSignalsView));
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