import 'package:flutter/material.dart';
import 'package:supaeromoon_ground_station/data_source/database.dart';
import 'package:supaeromoon_ground_station/data_source/selftest.dart';
import 'package:supaeromoon_ground_station/ui/common.dart';
import 'package:supaeromoon_ground_station/ui/screen/main_screen.dart';
import 'package:supaeromoon_ground_station/ui/theme.dart';
import 'package:window_manager/window_manager.dart';

void main() {
  DBCDatabase.parse("C:\\Users\\Lenovo\\Desktop\\COM-2024-DBC\\comms.dbc");
  Selftest.start();
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WindowListener {

  @override
  void initState() {
    ThemeManager.notifier.addListener(_update);
    // other post gui startup init code
    setState(() {});
    super.initState();
  }

  void _update() => setState(() {});

  @override
  Widget build(BuildContext context) {
    rebuildAllChildren(context);
    return MaterialApp(
      navigatorKey: mainWindowNavigatorKey,
      debugShowCheckedModeBanner: false,
      title: "Supaeromoon Ground Station",
      theme: ThemeManager.getThemeData(context),
      routes: {"/":(context) => const MainScreen()},
      initialRoute: "/",
    );
  }

  @override
  void onWindowClose() async {
    // shutdown code
  }
}
