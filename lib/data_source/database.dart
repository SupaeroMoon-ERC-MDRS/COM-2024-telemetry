import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:supaeromoon_ground_station/io/logger.dart';

class CharBuf{
  final String str;
  int g = 0;

  CharBuf({required this.str});

  int tellg() => g;
  void seekg(int pos){g = pos;}
  String peek() => str[g];
}

abstract class Reader{
  static bool isValidString(final String char){
    int c = char.codeUnits.first;
    return ["_", "+", "-"].contains(char) || (c >= 97 && c <= 122 || c >= 65 && c <= 90);
  }

  static bool isDigit(final String char){
    int c = char.codeUnits.first;
    return c >= 48 && c <= 57;
  }

  static String? readNextString(final CharBuf buf, final int eof){
    int start = buf.tellg();
    int pos = start;

    bool beg = false;
    bool end = false;

    while(pos < eof){
        buf.seekg(pos);
        if(!beg && isValidString(buf.peek())){
            beg = true;
            start = pos;
        }
        else if(beg && !isValidString(buf.peek()) && !end){
            end = true;
            break;
        }
        pos++;
    }

    if(!beg && !end){
      return null;
    }
    return buf.str.substring(start, pos);
  }

  static int? readNextNumeric(final CharBuf buf, final int eof){
    int start = buf.tellg();
    int pos = start;

    bool beg = false;
    bool end = false;

    while(pos < eof){
        buf.seekg(pos);
        if(!beg && isDigit(buf.peek())){
            beg = true;
            start = pos;
        }
        else if(beg && !isDigit(buf.peek()) && !end){
            end = true;
            break;
        }
        pos++;
    }

    if(!beg && !end){
      return null;
    }
    if(start != 0 && ["-", "+"].contains(buf.str[start - 1])){
      start--;
    }
    return int.tryParse(buf.str.substring(start, pos));
  }

  static num? readNextFloating(final CharBuf buf, final int eof){
    int start = buf.tellg();
    int pos = start;

    bool beg = false;
    bool end = false;

    while(pos < eof){
        buf.seekg(pos);
        if((isDigit(buf.peek()) || buf.peek() == '.') && !beg){
            beg = true;
            start = pos;
        }
        else if(beg && !isDigit(buf.peek()) && buf.peek() != '.' && !end){
            end = true;
            break;
        }
        pos++;
    }

    if(!beg && !end){
      return null;
    }
    if(start != 0 && ["-", "+"].contains(buf.str[start - 1])){
      start--;
    }
    return int.tryParse(buf.str.substring(start, pos)) ?? double.tryParse(buf.str.substring(start, pos));
  }

  static void seekUntil(final CharBuf buf, final int eof, final String pattern){
    int start = buf.tellg();
    int pos = start;

    bool match = false;
    while(pos + pattern.length < eof){
        match = true;
        for(int i = 0; i < pattern.length; i++){
            buf.seekg(pos + i);
            match = buf.peek() == pattern[i];
            if(!match) break;
        }
        if(match){
            buf.seekg(pos);
            break;
        }
        pos++;
    }

    if(pos + pattern.length >= eof){
      const String msg = "Unexpected eof when seeking";
      localLogger.warning(msg, doNoti: false);
      throw Exception(msg);
    }
  }
}

class Bitarray{
  final List<int> buf;

  Bitarray._({required this.buf});

  factory Bitarray.from(final Uint8List bytes){
    return Bitarray._(buf: bytes);
  }

  factory Bitarray.rangeSet(final int start, final int length, final int messageLen){
    final List<int> rep = List.filled(messageLen, 0);

    for(int pos = start; pos < start + length; pos++){
        int b = pos ~/ 8;
        int ib = pos % 8;

        rep[b] |= pow(2, ib).toInt();
    }

    return Bitarray._(buf: rep);
  }

  Bitarray operator &(final Bitarray other){
    return Bitarray._(buf: buf.indexed.map((e) => e.$2 & other.buf[e.$1]).toList());
  }

  Bitarray operator |(final Bitarray other){
    return Bitarray._(buf: buf.indexed.map((e) => e.$2 | other.buf[e.$1]).toList());
  }

  Bitarray operator >>(final int rhs){
    int full = rhs ~/ 8;
    int part = rhs % 8;

    Bitarray res = Bitarray._(buf: List.filled(buf.length, 0));

    for(int pos = full; pos < buf.length; pos++){
      res.buf[pos - full] = buf[pos];
    }

    for(int i = 0; i < buf.length; i++){
      res.buf[i] >>= part;
      if(i + 1 < buf.length){
        res.buf[i] |= (res.buf[i + 1] & (pow(2, part).toInt() - 1)) << (8 - part);
      }
    }

    return res;
  }

  Bitarray operator <<(final int rhs){
    int full = rhs ~/ 8;
    int part = rhs % 8;

    Bitarray res = Bitarray._(buf: List.filled(buf.length, 0));

    for(int pos = buf.length - 1; pos >= full; pos--){
      res.buf[pos] = buf[pos - full];
    }

    for(int i = buf.length - 1; i >= 0; i--){
      res.buf[i] = (res.buf[i] << part) & 0xFF;
      if(i - 1 > 0){
        res.buf[i] |= (res.buf[i - 1] & (255 - pow(2, part).toInt() - 1)) >> (8 - part);
      }
    }

    return res;
  }

  int toInt(final int bitlen, final bool isUnsigned){
    int full = bitlen ~/ 8;

    int sum = 0;
    for(int i = 0; i < full; i++){
      sum += buf[i] * pow(256, i).toInt();
    }

    for(int i = full * 8; i < bitlen; i++){
      sum += pow(2, i).toInt() * ((buf[full] & pow(2, i % 8).toInt()) >> i);
    }
    return isUnsigned ? sum : sum.toSigned(bitlen);
  }

  factory Bitarray.fromInt(final int v, final int length, final int messageLen){
    final int intrep = v.toUnsigned(length);
    final Uint8List arr = Uint8List(messageLen);
    for(int bi = 0; bi < min((length / 8).ceil(), messageLen); bi++){
      arr[bi] = (intrep >> bi * 8) & 0xFF;
    }
    return Bitarray._(buf: arr);
  }
}

class DBCSignal{
  final String name;
  final Bitarray mask;
  final int shift;
  final int length;
  final num scale;
  final num offset;
  final bool isUnsigned;
  final Endian endian;

  const DBCSignal._({
    required this.name,
    required this.mask,
    required this.shift,
    required this.length,
    required this.scale,
    required this.offset,
    required this.isUnsigned,
    required this.endian,
  });

  factory DBCSignal.parse(final CharBuf buf, final int messageLen, final int eof){
    buf.seekg(buf.tellg() + 3);

    String? name = Reader.readNextString(buf, eof);
    int? shift = Reader.readNextNumeric(buf, eof);
    int? length = Reader.readNextNumeric(buf, eof);
    int? endian = Reader.readNextNumeric(buf, eof);
    String? sign = Reader.readNextString(buf, eof);
    num? scale = Reader.readNextFloating(buf, eof);
    num? offset = Reader.readNextFloating(buf, eof);

    if(name != null && shift != null && length != null && endian != null && sign != null && scale != null && offset != null){
      if(shift > messageLen * 8 || shift + length > messageLen * 8){
        final String msg = "Signal position out of bounds in signal at ${buf.tellg()}";
        localLogger.warning(msg, doNoti: false);
        throw Exception(msg);
      }

      return DBCSignal._(
        name: name,
        mask: Bitarray.rangeSet(shift, length, messageLen),
        shift: shift,
        length: length,
        scale: scale,
        offset: offset,
        isUnsigned: sign == "+",
        endian: endian == 1 ? Endian.little : Endian.big
      );
    }
    final String msg = "Cannot parse signal at ${buf.tellg()}";
    localLogger.warning(msg, doNoti: false);
    throw Exception(msg);
  }

  num decode(final Bitarray messagePayloadBits){
    Bitarray part = (messagePayloadBits & mask) >> shift;
    int intrep = part.toInt(length, isUnsigned);
    return intrep * scale + offset;
  }

  Bitarray encode(final num value){
    final int v = ((value - offset) / scale).round();
    final Bitarray arr = Bitarray.fromInt(v, length, mask.buf.length);
    return arr << shift;
  }
}

class DBCMessage{
  final Map<String, DBCSignal> signals;
  final int id;
  final int messageLen;

  DBCMessage._({required this.signals, required this.id, required this.messageLen});

  factory DBCMessage.parse(final CharBuf buf){
    final int? id = Reader.readNextNumeric(buf, buf.str.length);
    final String? name = Reader.readNextString(buf, buf.str.length);
    final int? messageLen = Reader.readNextNumeric(buf, buf.str.length);

    if(messageLen == null || id == null){
      final String msg = "Cannot parse message at pos ${buf.tellg()}";
      localLogger.warning(msg, doNoti: false);
      throw Exception(msg);
    }

    int pos = buf.tellg();
    int msgEof = buf.str.length;
    try{
      Reader.seekUntil(buf, buf.str.length, "BO_");
      msgEof = buf.tellg();
    }
    // ignore: empty_catches
    catch(ex){}
    buf.seekg(pos);

    final Map<String, DBCSignal> signals = {};
    while(true){
      try{
      Reader.seekUntil(buf, msgEof, "SG_");
      }
      catch(exc){
        if(signals.isEmpty){
          rethrow;
        }
        return DBCMessage._(signals: signals, id: id, messageLen: messageLen);
      }

      try{
      DBCSignal sig = DBCSignal.parse(buf, messageLen, msgEof);
      signals[sig.name] = sig;
      }
      catch(exc){
        localLogger.warning("Could not parse signal in message $name");
      }
    }
  }

  Map<String, num> decode(final Bitarray messagePayloadBits){
    return signals.map((name, sig) => MapEntry(name, sig.decode(messagePayloadBits)));
  }

  Uint8List encode(final Map<String, num> values, final int version){
    Bitarray msg = Bitarray.from(Uint8List(messageLen));
    for(final MapEntry<String, num> value in values.entries){
      msg |= signals[value.key]!.encode(value.value);
    }
    return Uint8List.fromList([version & 0x00FF, version & 0xFF00 >> 8, id, ...msg.buf]);
  }
}

abstract class DBCDatabase{
  static final Map<int, DBCMessage> messages = {};
  static int dbcVersion = 0;

  static bool parse(final String fn){
    File f = File(fn);
    if(!f.existsSync()){
      return false;
    }

    final CharBuf buf = CharBuf(str: f.readAsStringSync());
    final String firstLine = buf.str.split('\n').first;
    buf.seekg(firstLine.length + 1);

    if(firstLine.startsWith("VERSION")){
      CharBuf view = CharBuf(str: firstLine.substring(7));
      dbcVersion = Reader.readNextNumeric(view, view.str.length) ?? -1;
      if(dbcVersion == -1){
        return false;
      }
    }
    else{
      return false;
    }

    while(true){
      try{
        Reader.seekUntil(buf, buf.str.length, "BO_");
      }
      catch(exc){
        if(messages.isEmpty){
          rethrow;
        }
        return true;
      }

      DBCMessage msg = DBCMessage.parse(buf);
      messages[msg.id] = msg;
    }
  }

  static List<MapEntry<int, Map<String, num>>> decode(final Uint8List bytes){
    final List<MapEntry<int, Map<String, num>>> ret = [];
    int pos = 0;

    while(pos + 4 < bytes.length){ // 2 dbc version 1 msg id +1 min msg size = 4u
      int msgVersion = bytes[pos] + 256 * bytes[pos + 1];
      if(msgVersion != dbcVersion){
          localLogger.warning("Message with wrong version was received: $msgVersion", doNoti: false);
          return [];
      }
      pos += 2;
      
      int id = bytes[pos];
      if(!messages.containsKey(id)){
          localLogger.warning("Unknown message was received with $id", doNoti: false);
          return [];
      }
      pos += 1;

      int msgSize = messages[id]!.messageLen;
      if(pos + msgSize < bytes.length){
          localLogger.warning("Partial message received for id $id", doNoti: false);
          return [];
      }

      Bitarray msgPayload = Bitarray.from(bytes.sublist(pos, pos + msgSize));
      ret.add(MapEntry(id, messages[id]!.decode(msgPayload)));
      pos += msgSize;
    }
    return ret;
  }

  static Uint8List encode(final List<MapEntry<int, Map<String, num>>> data){
    List<int> buf = [];
    for(final MapEntry<int, Map<String, num>> msg in data){
      if(!messages.containsKey(msg.key)){
        localLogger.warning("Message with unknown id ${msg.key} cannot be sent", doNoti: false);
        continue;
      }

      if(msg.value.keys.toSet().difference(messages[msg.key]!.signals.keys.toSet()).isNotEmpty){
        localLogger.warning("Signal name mismatch, cannot send ${msg.value.keys.toList()}, and ${messages[msg.key]!.signals.keys.toList()}");
        continue;
      }

      buf.addAll(messages[msg.key]!.encode(msg.value, dbcVersion));
    }
    return Uint8List.fromList(buf);
  }
}