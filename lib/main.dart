import 'package:flutter/material.dart';
import 'package:supaeromoon_ground_station/lifecycle.dart';
import 'package:supaeromoon_ground_station/ui/common.dart';
import 'package:supaeromoon_ground_station/ui/screen/main_screen.dart';
import 'package:supaeromoon_ground_station/ui/theme.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  await LifeCycle.preInit();
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
    LifeCycle.postInit(this);
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
      routes: {
        "/":(context) => const MainScreen(),
        //"/settings" : ,
      },
      initialRoute: "/",
    );
  }

  @override
  void onWindowClose() async {
    await LifeCycle.shutdown();
  }
}
