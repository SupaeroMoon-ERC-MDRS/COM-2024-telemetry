import 'dart:typed_data';
import 'dart:io';

Future<int> writeBytes(final Uint8List bytes) async{

  var file = File('record.bin');
  var content;
  try{
    content = file.writeAsBytes(bytes);
    return 0;
  }catch(e,s){
    throw 'Error $e : $s';
  }
}

Future<Uint8List> readBytes() async{

  final file = File('record.bin');
  file.open(mode: FileMode.read);

  try{
    Future<Uint8List> read = file.readAsBytes();
    return read;
  }catch(e,s){
    throw 'Error $e : $s';
  }
