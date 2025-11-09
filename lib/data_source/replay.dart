import 'dart:typed_data';

import 'package:supaeromoon_ground_station/data_misc/datalogger.dart';
import 'package:supaeromoon_ground_station/data_source/database.dart';
import 'package:supaeromoon_ground_station/data_storage/data_storage.dart';
import 'package:supaeromoon_ground_station/data_storage/session.dart';

abstract class Replay{
  static int _pos = 0;
  static Uint8List? _bytes;
  static double speed = 1;
  static bool _stopReplay = false;
  static bool _active = false;
  static bool _wasStopped = false;
  static int? replayTime;
  static int? startTime;
  static int? endTime;
  static int _sessionId = 0; // Unique ID for each replay session to invalidate old callbacks

  static Future<void> _setup() async {
    _pos = 0;
    _bytes = await Datalogger.readBytes();
    // Compute start and end timestamps (minimally) for UI slider bounds
    if (_bytes != null && _bytes!.length > 8) {
      try {
        final byteData = _bytes!.buffer.asByteData();
        startTime = byteData.getUint32(4, Endian.little);

        int p = 0;
        int? lastTs;
        while (_bytes!.length > p + 8) {
          final int len = byteData.getUint32(p, Endian.little);
          p += 4;
          final int ts = byteData.getUint32(p, Endian.little);
          p += 4 + len;
          lastTs = ts;
          // Guard against malformed length
          if (len < 0 || p < 0) break;
        }
        endTime = lastTs ?? startTime;
      } catch (_) {
        // Fallback silently if parsing fails
        startTime = null;
        endTime = null;
      }
    } else {
      startTime = null;
      endTime = null;
    }
  }

  static void start() async {
    await _setup();

    if(_bytes == null || _bytes!.length <= 8) return;

    _stopReplay = false;
    _sessionId++; // New session
    _process(_sessionId);
  }

  // Restart without re-reading file if already loaded; preserves current speed.
  static void restart() async {
    if(_bytes == null){
      start();
      return;
    }
    
    DataStorage.clear();
    _stopReplay = false;
    _wasStopped = false;
    _active = true;
    _pos = 0;
    replayTime = null;
    _sessionId++; // Invalidate any pending callbacks from old session
    _process(_sessionId);
  }

  static void stop() => _stopReplay = true;

  static void pause() {
    _stopReplay = true;
    _wasStopped = true;
  }
  static void resume(){
    _wasStopped = false;
    if(_active) _process(_sessionId);
  }

  static bool get isActive => _active;
  
  static bool get isStopped => _stopReplay;

  static bool get wasStopped => _wasStopped;

  static void _process(int sessionId) async{
    // Immediately exit if this callback belongs to an old session
    if(sessionId != _sessionId) return;
    
    if(_stopReplay == true){
      _stopReplay = false;
      return;
    }

    // Safety guard: ensure there is at least a full header available before reading.
    if (_bytes == null || _bytes!.length < _pos + 8) {
      _active = false;
      return;
    }

    final int len = _bytes!.buffer.asByteData().getUint32(_pos, Endian.little);
    _pos += 4;
    final int timestamp = _bytes!.buffer.asByteData().getUint32(_pos, Endian.little);
    _pos += 4;
    if(_bytes!.length <= _pos + len){
      _active = false;
      return;
    }
    Uint8List line = _bytes!.sublist(_pos, _pos + len);
    _pos += len;

    final List<MapEntry<int, Map<String, dynamic>>> rec = DBCDatabase.decode(line);

    for(final MapEntry<int, Map<String, dynamic>> msg in rec){
      for(final String sig in msg.value.keys){
        DataStorage.update(sig, msg.value[sig]!, timestamp);
      }
    }

    replayTime = timestamp;
    
    DataStorage.discardIfOlderThan(timestamp - Session.bufferMs);

    // If there is not a full next record header, mark inactive and stop.
    if(_bytes!.length < _pos + 8){
      _active = false;
      return;
    }

    _active = true;
    final int nexttimestamp = _bytes!.buffer.asByteData().getUint32(_pos + 4, Endian.little);
    // Guard against non-increasing timestamps which could produce zero/negative delay.
    final int dt = (nexttimestamp - timestamp);
    final int delayMs = (dt <= 0 ? 0 : (dt / Replay.speed).toInt()).clamp(0, 1 << 31);
    Future.delayed(Duration(milliseconds: delayMs), () => _process(sessionId));
  }

  // Find the byte position of the record such that the next record's timestamp is >= target
  // Returns a position pointing to the start of a record (at its length field)
  static int _findPosForTimestamp(final int targetTs){
    if (_bytes == null) return 0;
    final byteData = _bytes!.buffer.asByteData();
    int p = 0;
    if (_bytes!.length < p + 8) return 0;
    int nextTs = byteData.getUint32(p + 4, Endian.little);
    if (targetTs < nextTs) {
      return p; // before first record, stay at 0
    }
    while (_bytes!.length >= p + 8) {
      final int len = byteData.getUint32(p, Endian.little);
      p += 4;
      nextTs = byteData.getUint32(p, Endian.little);
      p += 4 + len;
      if (_bytes!.length < p + 8) {
        // End reached; position to last known record start
        return p - (len + 8);
      }
      if (targetTs < nextTs) {
        // Step back to the start of this record
        return p - (len + 8);
      }
    }
    return 0;
  }

  // Decode records from [fromPos, toPos) without affecting replay flow, to rebuild history buffers.
  static void _decodeRange(final int fromPos, final int toPos){
    if (_bytes == null) return;
    final byteData = _bytes!.buffer.asByteData();
    int p = fromPos;
    while (p < toPos && _bytes!.length >= p + 8) {
      final int len = byteData.getUint32(p, Endian.little);
      final int ts = byteData.getUint32(p + 4, Endian.little);
      if (_bytes!.length < p + 8 + len) break;
      final Uint8List line = _bytes!.sublist(p + 8, p + 8 + len);
      final List<MapEntry<int, Map<String, dynamic>>> rec = DBCDatabase.decode(line);
      for(final MapEntry<int, Map<String, dynamic>> msg in rec){
        for(final String sig in msg.value.keys){
          DataStorage.update(sig, msg.value[sig]!, ts);
        }
      }
      p += 8 + len;
    }
  }

  static void seek(int timestamp){
    // Allow seeking even after replay finished; ensure bytes are loaded and (if ended) reactivate only then.
    if (_bytes == null || _bytes!.length <= 8) return;
    
    // Increment session to cancel any pending callbacks
    _sessionId++;
    
    if(_active == false){
      _stopReplay = false;
      _active = true;
    }

    // Reflect new target time and rebuild only the recent history window
    replayTime = timestamp;
    try { DataStorage.clear(); } catch (_) {}

    // Determine target position for this timestamp
    final int posWanted = _findPosForTimestamp(timestamp);

    // Determine history window start (bounded by log start)
    int winStartTs = timestamp - Session.bufferMs;
    if (startTime != null && winStartTs < startTime!) winStartTs = startTime!;
    final int fromPos = _findPosForTimestamp(winStartTs);

    // Decode history into DataStorage without advancing replay
    _decodeRange(fromPos, posWanted);
    DataStorage.discardIfOlderThan(timestamp - Session.bufferMs);

    // Set replay pointer to desired position
    _pos = posWanted;

    // Kick processing if we were previously inactive or had paused at end.
    // Resume processing only if we are not in a paused state
    if(!_wasStopped){
      _process(_sessionId);
    }
  }
}

