import 'dart:convert';

import 'package:unittests/logger.dart';

class LoadContext{
  final dynamic storage;
  final List<LogEntry> context;
  final String filePath;

  LoadContext({
    required this.storage,
    required this.context,
    required this.filePath
  });
}

abstract class Des{

  static Utf8Decoder utf8Decoder = const Utf8Decoder();

  static JsonDecoder jsonDecoder = const JsonDecoder();

  static Map jsonFromBytes(List<int> bytes) => jsonDecoder.convert(safeUTF8Decode(bytes));

  static String safeUTF8Decode(List<int> bytes) {
    // when there is 176 there should be 194 before that
    final List<int> degreeCharIndexes = [];
    for(int i = 0; i < bytes.length; i++){
      if(bytes[i] == 176){
        degreeCharIndexes.add(i);
      }
    }

    bytes = bytes.toList(growable: true);

    for(final int ind in degreeCharIndexes.reversed){
      if(ind == 0 || bytes[ind - 1] != 194){
        bytes.insert(ind, 194); // degree char extension
      }
    }

    return utf8Decoder.convert(bytes);
  }
}