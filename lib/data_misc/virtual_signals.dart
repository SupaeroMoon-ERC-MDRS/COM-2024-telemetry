import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:supaeromoon_ground_station/data_misc/eval/eval.dart';
import 'package:supaeromoon_ground_station/data_source/data_source.dart';
import 'package:supaeromoon_ground_station/data_storage/data_storage.dart';
import 'package:supaeromoon_ground_station/data_storage/signal_container.dart';
import 'package:supaeromoon_ground_station/io/file_system.dart';
import 'package:supaeromoon_ground_station/io/logger.dart';
import 'package:supaeromoon_ground_station/io/serdes.dart';
import 'package:supaeromoon_ground_station/ui/theme.dart';

class VirtualSignal{
  final String name;
  final String expr;
  final ExecTree exec;
  final List<String> inputs = [];

  VirtualSignal._({
    required this.name,
    required this.expr,
    required this.exec
  }){
    inputs.addAll(Evaluator.requiredSignals(exec));
  }

  bool register(){
    for(final String signal in inputs){
      if(DataStorage.storage.containsKey(signal)){
        DataStorage.storage[signal]!.changeNotifier.addListener(_tick);
      }
      else{
        deregister();
        return false;
      }
    }
    return true;
  }

  void deregister(){
    for(final String signal in inputs){
      if(DataStorage.storage.containsKey(signal)){
        DataStorage.storage[signal]!.changeNotifier.removeListener(_tick);
      }
    }
  }

  void _tick(){
    try{
      final num value = Evaluator.eval<num>(exec);
      DataStorage.update(name, value, DataSource.now());
    }catch(ex){
      return;
    }
  }

  Map get asMap => {
    "name": name,
    "expr": expr,
  };

  factory VirtualSignal.fromMap(final Map map){
    return VirtualSignal._(name: map["name"], expr: map["expr"], exec: Evaluator.compile<num>(map["expr"]));
  }
}

abstract class VirtualSignalController{
  static final List<VirtualSignal> _virtualSignals = [];

  static int getLen() => _virtualSignals.length;

  static void load(){
    final List<Map> ser;
    try{
      ser = SerDes.jsonFromBytes(
        FileSystem.tryLoadBytesFromLocalSync(FileSystem.topDir, "VIRTUALSIGNALS")
      ) as List<Map>;
    }catch(ex){
      localLogger.error("Failed to load virtual signals: ${ex.toString()}");
      return;
    }

    _virtualSignals.addAll(ser.map((e){
      try{
        return VirtualSignal.fromMap(e);
      }catch(ex){
        localLogger.error("Failed to parse alarm: ${ex.toString()}");
        return VirtualSignal._(name: "NOSIG", expr: "", exec: ExecTree.empty());
      }
    }));
    _virtualSignals.removeWhere((alarm) => alarm.name == "NOSIG");

    for(final VirtualSignal sig in _virtualSignals){
      DataStorage.storage[sig.name] = SignalContainer<Float32List>.create(sig.name, sig.name, ""); // TODO unit calculation
      if(!sig.register()){
        localLogger.warning("Could not register virtual signal ${sig.name}");
      }
    }
  }

  static void add(final VirtualSignal alarm){
    _virtualSignals.add(alarm..register());
  }

  static Widget getWidget(final int index) => 
    Text("${_virtualSignals[index].name} : ${_virtualSignals[index].expr}", style: ThemeManager.textStyle, maxLines: 1, overflow: TextOverflow.clip,);

  static void remove(final int index){
    _virtualSignals.removeAt(index).deregister();
  }

  static void save(){
    FileSystem.trySaveBytesToLocalAsync(FileSystem.topDir, "VIRTUALSIGNALS", 
      SerDes.jsonToBytes(_virtualSignals.map((e) => e.asMap).toList())
    );
  }
}