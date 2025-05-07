
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:supaeromoon_ground_station/data_misc/notifiers.dart';
import 'package:supaeromoon_ground_station/data_storage/unit_system.dart';

class ValueTimePair{
  final num value;
  final int time;

  ValueTimePair(this.value, this.time);
}

class ValueTime<T extends TypedData>{
  
  static final Map<Type, TypedData Function(int, int, TypedData)> _realloc = {
    Uint8List: (p0, p1, p2) => Uint8List(p0)..setRange(0, p1, (p2 as Uint8List)),
    Uint16List: (p0, p1, p2) => Uint16List(p0)..setRange(0, p1, (p2 as Uint16List)),
    Uint32List: (p0, p1, p2) => Uint32List(p0)..setRange(0, p1, (p2 as Uint32List)),
    Uint64List: (p0, p1, p2) => Uint64List(p0)..setRange(0, p1, (p2 as Uint64List)),
    Int8List: (p0, p1, p2) => Int8List(p0)..setRange(0, p1, (p2 as Int8List)),
    Int16List: (p0, p1, p2) => Int16List(p0)..setRange(0, p1, (p2 as Int16List)),
    Int32List: (p0, p1, p2) => Int32List(p0)..setRange(0, p1, (p2 as Int32List)),
    Int64List: (p0, p1, p2) => Int64List(p0)..setRange(0, p1, (p2 as Int64List)),
    Float32List: (p0, p1, p2) => Float32List(p0)..setRange(0, p1, (p2 as Float32List)),
    Float64List: (p0, p1, p2) => Float64List(p0)..setRange(0, p1, (p2 as Float64List))
  };

  static final Map<Type, TypedData Function(int)> _ctors = {
    Uint8List: (p0) => Uint8List(p0),
    Uint16List: (p0) => Uint16List(p0),
    Uint32List: (p0) => Uint32List(p0),
    Uint64List: (p0) => Uint64List(p0),
    Int8List: (p0) => Int8List(p0),
    Int16List: (p0) => Int16List(p0),
    Int32List: (p0) => Int32List(p0),
    Int64List: (p0) => Int64List(p0),
    Float32List: (p0) => Float32List(p0),
    Float64List: (p0) => Float64List(p0),
  };

  T value;
  Uint64List time;
  late int _capacity;
  late int _size;

  int get size => _size;
  int get capacity => _capacity;
  
  ValueTimePair? get lastOrNull => size != 0 ? ValueTimePair((value as List)[size - 1], time[size - 1]) : null;
  ValueTimePair? get firstOrNull => size != 0 ? ValueTimePair((value as List)[0], time[0]) : null;

  bool get isEmpty => size == 0;
  bool get isNotEmpty => size != 0;

  ValueTime._empty({required this.value, required this.time}){
    _capacity = time.length;
    _size = 0;
  }

  factory ValueTime(final int bufsize){
    return ValueTime._empty(
      value: _ctors[T]!(bufsize) as T,
      time: Uint64List(bufsize)
    );
  }

  void reserve(int newCapacity){
    value = _realloc[T]!(newCapacity, _size, value) as T;
    time = Uint64List(newCapacity)..setRange(0, _size, time);
    _capacity = newCapacity;
  }

  void clear(){
    _size = 0;
    reserve(0);
  }

  void pushback(final num v, final int t){
    if(_capacity <= _size){
      reserve(_capacity + min(10000, max(1000, _size ~/ 2)));
    }
    (value as List)[_size] = v;
    time[_size] = t;
    _size++;
  }

  void popfront(final int skip){
    (value as List).setRange(0, _size - skip, (value as List), skip);
    time.setRange(0, _size - skip, time, skip);
    _size -= skip;
  }
  
}

class SignalContainer<T extends TypedData>{
  final UniqueKey key = UniqueKey();
  final ValueTime<T> vt;
  final String dbcName;
  String displayName;
  CompoundUnit unit;
  BlankNotifier everyUpdateNotifier;
  BlankNotifier changeNotifier;

  SignalContainer._({
    required this.vt,
    required this.dbcName,
    required this.displayName,
    required this.unit,
    required this.everyUpdateNotifier,
    required this.changeNotifier
  });

  factory SignalContainer.create(final String dbcName, final String displayName){
    return SignalContainer._(
      vt: ValueTime<T>(0),
      dbcName:dbcName,
      displayName: displayName,
      unit: CompoundUnit.scalar(), // TODO figure out from dbc
      everyUpdateNotifier: BlankNotifier(null),
      changeNotifier: BlankNotifier(null)
    );
  }
}

class VectorSignalContainer<T extends TypedData>{
  final UniqueKey key = UniqueKey();
  T value;
  int time;
  final String dbcName;
  String displayName;
  CompoundUnit unit;
  BlankNotifier everyUpdateNotifier;
  BlankNotifier changeNotifier;

  VectorSignalContainer._({
    required this.value,
    required this.time,
    required this.dbcName,
    required this.displayName,
    required this.unit,
    required this.everyUpdateNotifier,
    required this.changeNotifier
  });

  factory VectorSignalContainer.create(final String dbcName, final String displayName, final T value){
    return VectorSignalContainer._(
      value: value,
      time: 0,
      dbcName:dbcName,
      displayName: displayName,
      unit: CompoundUnit.scalar(), // TODO figure out from dbc
      everyUpdateNotifier: BlankNotifier(null),
      changeNotifier: BlankNotifier(null)
    );
  }
}