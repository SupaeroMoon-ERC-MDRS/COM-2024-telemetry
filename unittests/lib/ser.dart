import 'dart:convert';
import 'dart:typed_data';

abstract class Ser {

  static Utf8Encoder utf8Decoder = const Utf8Encoder();

  static JsonEncoder jsonEncoder = const JsonEncoder();
  static JsonEncoder jsonEncoderWithIndent = const JsonEncoder.withIndent("    ");

  static Uint8List jsonToBytes(Map jsonEncodeable) => utf8Decoder.convert(jsonEncoder.convert(jsonEncodeable));
  static Uint8List prettyJsonToBytes(Map jsonEncodeable) => utf8Decoder.convert(jsonEncoderWithIndent.convert(jsonEncodeable));
  
}