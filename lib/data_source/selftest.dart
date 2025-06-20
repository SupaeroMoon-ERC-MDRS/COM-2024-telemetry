import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:supaeromoon_ground_station/data_misc/datalogger.dart';
import 'package:supaeromoon_ground_station/data_source/data_source.dart';
import 'package:supaeromoon_ground_station/data_source/database.dart';
import 'package:supaeromoon_ground_station/data_storage/data_storage.dart';
import 'package:supaeromoon_ground_station/data_storage/session.dart';

abstract class _GeneratorBase{
  final List<num> sequence = [];
  int p = 0;

  void setup([final num min, final num max, final bool int]);

  num next(){
    p = (p + 1) % sequence.length;
    return sequence[p];
  }
  void reset(){
    p = 0;
  }
}

class _SineGenerator extends _GeneratorBase{
  @override
  void setup([final num min = 0, final num max = 1, final bool int = false]) {
    final num center = (min + max) / 2;
    final num amp = (max - min) / 2;
    if(int){
      sequence.addAll(List.generate(500, (i) => (center + amp * sin(2 * pi * i / 500)).toInt()));
    }
    else{
      sequence.addAll(List.generate(500, (i) => center + amp * sin(2 * pi * i / 500)));
    }
  }
}

class _BooleanGenerator extends _GeneratorBase{
  @override
  void setup([final num min = 0, final num max = 1, final bool int = true]) {
    sequence.addAll([1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0]);
  }
}


abstract class Selftest{
  static late Timer _timer;
  static final Map<int, Map<String, _GeneratorBase>> _generators = { // TODO figure out automatically in setup()
    0x0F: {
      "l_top" : _BooleanGenerator()..setup(),
      "l_bottom" : _BooleanGenerator()..setup(),
      "l_right" : _BooleanGenerator()..setup(),
      "l_left" : _BooleanGenerator()..setup(),
      "r_top" : _BooleanGenerator()..setup(),
      "r_bottom" : _BooleanGenerator()..setup(),
      "r_right" : _BooleanGenerator()..setup(),
      "r_left" : _BooleanGenerator()..setup(),
      "l_shoulder" : _BooleanGenerator()..setup(),
      "r_shoulder" : _BooleanGenerator()..setup(),
      "e_stop" : _BooleanGenerator()..setup(),
      "left_trigger" : _SineGenerator()..setup(0, 255, true),
      "right_trigger" : _SineGenerator()..setup(0, 100, true),
      "thumb_left_x" : _SineGenerator()..setup(0, 200, true),
      "thumb_left_y" : _SineGenerator()..setup(0, 50, true),
      "thumb_right_x" : _SineGenerator()..setup(100, 150, true),
      "thumb_right_y" : _SineGenerator()..setup(100, 255, true),
    }
  };

  static void _setup(){

  }

  static void start(){
    _setup();
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      final List<MapEntry<int, Map<String, num>>> data = [];
      for(final int id in _generators.keys){
        final Map<String, num> msg = _generators[id]!.map((sig, gen) => MapEntry(sig, gen.next()));
        data.add(MapEntry(id, msg));
      }

      final Uint8List bytes = DBCDatabase.encode(data);

      final List<MapEntry<int, Map<String, dynamic>>> rec = DBCDatabase.decode(bytes);
      final int recTime = DataSource.now();
      Datalogger.maybeSaveData(bytes, recTime);

      for(final MapEntry<int, Map<String, dynamic>> msg in rec){
        for(final String sig in msg.value.keys){
          DataStorage.update(sig, msg.value[sig]!, recTime);
        }
      }
      DataStorage.discardIfOlderThan(recTime - Session.bufferMs);
    });
  }

  static void stop(){
    _timer.cancel();
  }
}