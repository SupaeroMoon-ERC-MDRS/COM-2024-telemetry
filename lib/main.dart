import 'package:flutter/material.dart';
import 'package:guitest/common.dart';
import 'package:guitest/screens.dart';
import 'package:guitest/theme.dart';
import 'package:window_manager/window_manager.dart';

final Map<String, Widget Function(BuildContext)> routes = {
  "/": (context) => const ScreenBase(screen: HomeScreen(),),
  "/other": (context) => const ScreenBase(screen: OtherScreen(),),
};

final Map<String, String> routeNames = {
  "/": "Home",
  "/other": "Other",
};

void main() {
  // code to run before gui starts initializing

  // until here sequential code
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener{
  @override
  void initState() {
    ThemeManager.notifier.addListener(_update);
    
    // code to run just as gui is initializing

    setState(() {});
    super.initState();
  }

  void _update() => setState(() {});

  @override
  Widget build(BuildContext context) {
    rebuildAllChildren(context);
    return MaterialApp(
      navigatorKey: navKey,
      debugShowCheckedModeBanner: false,
      title: "Flutter gui example",
      theme: ThemeManager.getThemeData(context),
      initialRoute: "/",
      routes: routes
    );
  }

  @override
  void onWindowClose() async {
    // code to run just before shutting down
  }
}

