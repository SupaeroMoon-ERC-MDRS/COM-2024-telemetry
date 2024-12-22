import 'dart:convert';
import 'dart:typed_data';

abstract class SerDes {
  static Utf8Encoder utf8Encoder = const Utf8Encoder();
  static JsonEncoder jsonEncoder = const JsonEncoder();
  static JsonEncoder jsonEncoderWithIndent = const JsonEncoder.withIndent("    ");

  static Utf8Decoder utf8Decoder = const Utf8Decoder();
  static JsonDecoder jsonDecoder = const JsonDecoder();

  static Uint8List jsonToBytes(Map jsonEncodeable) => utf8Encoder.convert(jsonEncoder.convert(jsonEncodeable));
  static Uint8List prettyJsonToBytes(Map jsonEncodeable) => utf8Encoder.convert(jsonEncoderWithIndent.convert(jsonEncodeable));

  static Map jsonFromBytes(List<int> bytes) => jsonDecoder.convert(safeUTF8Decode(bytes));
  
    static String safeUTF8Decode(List<int> bytes) {
    // when there is 176 before there should be 194
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