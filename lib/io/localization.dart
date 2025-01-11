import 'dart:io';

import 'package:supaeromoon_ground_station/io/file_system.dart';

abstract class Locale{
  static final Map<String, Map<String, String>> _localization = {};
  static String _lang = "NONE";

  static Iterable<String> get languages => _localization.keys;

  static bool setLanguage(final String language){
    if(_localization.containsKey(language)){
      _lang = language;
      return true;
    }
    return false;
  }

  static bool load(){
    final Iterable<FileSystemEntity> elements = FileSystem.tryListElementsInLocalSync(FileSystem.localeDir).where((element) => element.path.endsWith(".loc"));

    for(final FileSystemEntity elem in elements){
      _read(elem.absolute.path);
    }

    return _localization.isNotEmpty;
  }

  static void _read(final String fn){
    final String lang = fn.split('/').last.split('\\').last.split('.').first;
    final Map<String, String> data = FileSystem.tryLoadMapFromLocalSync(FileSystem.localeDir, "$lang.loc").cast<String, String>();
    if(data.isNotEmpty){
      _localization[lang] = data;
    }
  }

  static String get(final String label){
    return _localization[_lang]?[label] ?? label;
  }
}