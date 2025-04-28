import 'package:supaeromoon_ground_station/data_storage/data_storage.dart';
import 'package:supaeromoon_ground_station/io/file_system.dart';
import 'package:supaeromoon_ground_station/io/serdes.dart';

class Alarm{
  final String signal;
  final bool inRange;
  final num min;
  final num max;
  late final bool Function(num) condition;
  final bool active;
  bool triggered = false;

  Alarm({
    required this.signal,
    required this.active,
    required this.inRange,
    required this.min,
    required this.max,
  }){
    condition = inRange ? 
      (final num value) {
        return min <= value && value <= max;
      }
      :
      (final num value) {
        return min >= value || value >= max;
      };
  }

  bool get canTrigger => active & !triggered;

  void register(){
    if(DataStorage.storage.containsKey(signal)){
      DataStorage.storage[signal]!.changeNotifier.addListener(_check);
    }
  }

  void deregister(){
    if(DataStorage.storage.containsKey(signal)){
      DataStorage.storage[signal]!.changeNotifier.removeListener(_check);
    }
  }

  void _check(){
    if(active && DataStorage.storage[signal]!.vt.isNotEmpty && condition(DataStorage.storage[signal]!.vt.lastOrNull!.value)){
      triggered = true;
      // TODO play sound
      // TODO do notif
    }
  }

  Map get asMap => {
    "signal": signal,
    "inRange": inRange,
    "min": min,
    "max": max,
    "active": active
  };

  factory Alarm.fromMap(final Map map){
    return Alarm(signal: map["signal"], active: map["active"], inRange: map["inRange"], min: map["min"], max: map["max"]);
  }
}

abstract class AlarmController{
  static final List<Alarm> _alarms = [];
  static final Map<String, List<int>> _nameIdMap = {};

  static List<Alarm> get alarms => _alarms;

  static void load(){
    final List<Map> ser = SerDes.jsonFromBytes(
      FileSystem.tryLoadBytesFromLocalSync(FileSystem.topDir, "ALARMS")
    ) as List<Map>;

    _alarms.addAll(ser.map((e) => Alarm.fromMap(e)));
    for(final Alarm alarm in _alarms){
      alarm.register();
    }
  }

  static void add(final Alarm alarm){
    if(!_nameIdMap.containsKey(alarm.signal)){
      _nameIdMap[alarm.signal] = [];
    }

    _nameIdMap[alarm.signal]!.add(_alarms.length);
    _alarms.add(alarm..register());
  }

  static void remove(final int index){
    _nameIdMap[_alarms[index].signal]!.remove(index);
    alarms.removeAt(index).deregister();

    for(final String sig in _nameIdMap.keys){
      for(int i = 0; i < _nameIdMap[sig]!.length; i++){
        if(_nameIdMap[sig]![i] > index){
          _nameIdMap[sig]![i]--;
        }
      }
    }
  }

  static void save(){
    FileSystem.trySaveBytesToLocalAsync(FileSystem.topDir, "ALARMS", 
      SerDes.jsonToBytes(_alarms.map((e) => e.asMap).toList())
    );
  }
}