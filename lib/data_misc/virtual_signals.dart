import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:supaeromoon_ground_station/data_misc/eval/eval.dart';
import 'package:supaeromoon_ground_station/data_source/data_source.dart';
import 'package:supaeromoon_ground_station/data_source/database.dart';
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
  final List<String> regSignals = [];

  VirtualSignal._({
    required this.name,
    required this.expr,
    required this.exec
  }){
    inputs.addAll(Evaluator.requiredSignals(exec));
  }

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
        DataStorage.storage[signal]!.everyUpdateNotifier.addListener(_tick);
      }
      else{
        deregister();
        return false;
      }
    }
    return true;
  }

  // TODO whoever else has this as regSignal, needs to be deregistered (and whoever had that as regSignal but that will be done recursively anyways)
  void deregister(){
    for(final String signal in regSignals){
      if(DataStorage.storage.containsKey(signal)){
        DataStorage.storage[signal]!.everyUpdateNotifier.removeListener(_tick);
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

    for(final Map m in ser){
      DataStorage.storage[m["name"]] = SignalContainer<Float32List>.create(m["name"], m["name"], ""); // TODO unit calculation
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
      if(!sig.register(_virtualSignals)){
        localLogger.warning("Could not register virtual signal ${sig.name}");
      }
    }
  }

  static void add(final VirtualSignal alarm){
    _virtualSignals.add(alarm..register(_virtualSignals));
  }

  static List<VirtualSignal> get virtualSignalsView => List.of(_virtualSignals);

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