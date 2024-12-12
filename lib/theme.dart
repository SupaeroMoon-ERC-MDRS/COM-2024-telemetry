import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guitest/notifiers.dart';

class Style{
  final Color bgColor;
  final double fontSize;
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final double subTitleFontSize;
  final Color textColor;
  final double titleFontSize;
  final double padding;

  Style({
    required this.name,
    required this.textColor,
    required this.bgColor,
    required this.primaryColor,
    required this.secondaryColor,
    required this.fontSize,
    required this.subTitleFontSize,
    required this.titleFontSize,
    required this.padding,
  });
}

abstract class ThemeManager{
  static final Map<String, Style> _styles = {
    "DARK": Style(
      name: "DARK",
      textColor: Colors.white,
      bgColor: const Color.fromARGB(255, 23, 24, 34),
      primaryColor: const Color.fromARGB(255, 22, 108, 189),
      secondaryColor: const Color.fromARGB(255, 42, 45, 62),
      fontSize: 13,
      subTitleFontSize: 18,
      titleFontSize: 26,
      padding: 8.0
    ),
    "BRIGHT": Style(
      name: "BRIGHT",
      textColor: Colors.black,
      bgColor: Colors.white,
      primaryColor: const Color.fromARGB(255, 88, 88, 88),
      secondaryColor: const Color.fromARGB(255, 219, 219, 219),
      fontSize: 13,
      subTitleFontSize: 18,
      titleFontSize: 26,
      padding: 8.0
    ),
  };

  static Style globalStyle = _styles["DARK"]!;

  static String? title;

  static UpdateableValueNotifier<void> notifier = UpdateableValueNotifier<void>(null);

  static void addStlye(Style style){
    if(!_styles.containsKey(style.name)){
      _styles[style.name] = style;
    }
  }

  static List<String> getStyleList() => _styles.keys.toList();

  static void changeStyle(final String name){
    if(_styles.containsKey(name) && activeStyle != name){
      globalStyle = _styles[name]!;
      notifier.update((value) { });
    }
  }
  
  static ThemeData? getThemeData(BuildContext context) => ThemeData.dark().copyWith(
    scaffoldBackgroundColor: globalStyle.bgColor,
    //backgroundColor: globalStyle.bgColor,
    colorScheme: ColorScheme.fromSwatch(backgroundColor: globalStyle.bgColor),
    textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(bodyColor: globalStyle.textColor),
    canvasColor: globalStyle.bgColor,
    primaryColor: globalStyle.primaryColor,
    iconTheme: Theme.of(context).iconTheme.copyWith(color: globalStyle.primaryColor),
    inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: globalStyle.primaryColor)),
      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
      hintStyle: const TextStyle(color: Colors.grey),
    ),
    appBarTheme: Theme.of(context).appBarTheme.copyWith(elevation: 0, backgroundColor: globalStyle.secondaryColor)
  );

  static TextStyle get textStyle => TextStyle(color: globalStyle.textColor, fontSize: globalStyle.fontSize);
  static TextStyle get subTitleStyle => TextStyle(color: globalStyle.textColor, fontSize: globalStyle.subTitleFontSize);
  static TextStyle get titleStyle => TextStyle(color: globalStyle.textColor, fontSize: globalStyle.titleFontSize);

  static String get activeStyle => globalStyle.name;
}
