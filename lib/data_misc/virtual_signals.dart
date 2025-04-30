// Input: string of c++ like code
//      operators for now: +-*/ with &|^ and ()brackets
//      in future functions like abs() etc
//      allow numeric constants

// Parsing: tokenize -> create op tree based on op precedence and brackets
//      then create gettable input list (not map)

// Exec: give input list to exec that runs bottom up on op tree
//      return value/failresult

import 'dart:typed_data';

import 'package:supaeromoon_ground_station/data_source/data_source.dart';
import 'package:supaeromoon_ground_station/data_storage/data_storage.dart';
import 'package:supaeromoon_ground_station/data_storage/signal_container.dart';
import 'package:supaeromoon_ground_station/io/logger.dart';

class _VirtualSignal{
  final num Function(List<num>) rule;
  final String name;
  final List<String> inputs;

  const _VirtualSignal({required this.name, required this.inputs, required this.rule});

  void _tick(){
    try{
      final num value = rule(inputs.map((signal) => DataStorage.storage[signal]!.vt.lastOrNull!.value).toList());
      DataStorage.update(name, value, DataSource.now());
    }catch(ex){
      return;
    }
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
}

abstract class VirtualSignalController{ // TODO temp
  static final List<_VirtualSignal> _signals = [
    _VirtualSignal(name: "test", inputs: ["left_trigger", "right_trigger"], rule: (final List<num> v){
      return v[0] + v[1];
    }),
  ];

  static void init(){
    for(final _VirtualSignal sig in _signals){
      DataStorage.storage[sig.name] = SignalContainer<Float32List>.create(sig.name, sig.name);
      if(!sig.register()){
        localLogger.warning("Could not register virtual signal ${sig.name}");
      }
    }
  }

  static void stop(){    
    for(final _VirtualSignal sig in _signals){
      sig.deregister();
    }
  }
}