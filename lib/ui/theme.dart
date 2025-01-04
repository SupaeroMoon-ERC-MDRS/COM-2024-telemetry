import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supaeromoon_ground_station/data_misc/notifiers.dart';

class Style{
  final String name;
  final double titleFontSize;
  final double subTitleFontSize;
  final double fontSize;
  final Color bgColor;
  final Color primaryColor;
  final Color secondaryColor;
  final Color tertiaryColor;
  final Color textColor;
  final double padding;
  final double borderWidth;

  Style({
    required this.name,
    required this.titleFontSize,
    required this.subTitleFontSize,
    required this.fontSize,
    required this.bgColor,
    required this.primaryColor,
    required this.secondaryColor,
    required this.tertiaryColor,
    required this.textColor,
    required this.padding,
    required this.borderWidth,
  });
}

abstract class ThemeManager{
  static final Map<String, Style> _styles = {
    "DARK": Style(
      name: "DARK",
      titleFontSize: 26,
      subTitleFontSize: 18,
      fontSize: 13,
      bgColor: const Color.fromARGB(255, 20, 20, 35),
      primaryColor: const Color.fromARGB(255, 249, 192, 47),
      secondaryColor: const Color.fromARGB(255, 40, 40, 70),
      tertiaryColor: const Color.fromARGB(255, 60, 60, 105),
      textColor: Colors.white,
      padding: 8.0,
      borderWidth: 1,
    ),
    "BRIGHT": Style(
      name: "BRIGHT",
      titleFontSize: 26,
      subTitleFontSize: 18,
      fontSize: 13,
      bgColor: Colors.white,
      primaryColor: const Color.fromARGB(255, 249, 192, 47),
      secondaryColor: const Color.fromARGB(255, 210, 210, 210),
      tertiaryColor: const Color.fromARGB(255, 165, 165, 165),
      textColor: Colors.black,
      padding: 8.0,
      borderWidth: 1,
    ),
  };

  static Style globalStyle = _styles["DARK"]!;

  static BlankNotifier notifier = BlankNotifier(null);

  static void addStlye(Style style){
    if(!_styles.containsKey(style.name)){
      _styles[style.name] = style;
    }
  }

  static List<String> getStyleList() => _styles.keys.toList();

  static void changeStyle(final String name){
    if(_styles.containsKey(name) && activeStyle != name){
      globalStyle = _styles[name]!;
      notifier.update();
    }
  }
  
  static ThemeData? getThemeData(BuildContext context) => ThemeData.dark().copyWith(
    scaffoldBackgroundColor: globalStyle.bgColor,
    colorScheme: ColorScheme.fromSwatch(backgroundColor: globalStyle.bgColor),
    textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(bodyColor: globalStyle.textColor),  // TODO use fixed size font instead
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