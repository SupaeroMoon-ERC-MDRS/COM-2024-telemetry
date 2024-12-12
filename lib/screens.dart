import 'package:flutter/material.dart';
import 'package:guitest/appbar.dart';
import 'package:guitest/theme.dart';

class ScreenBase extends StatelessWidget {
  const ScreenBase({super.key, required this.screen});

  final Widget screen;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(),
          screen
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text("This is the home screen", style: ThemeManager.textStyle),
          Row(
            children: [
              Container(width: 100, height: 100, color: Colors.red,),
              Expanded(child: Container(height: 100, color: Colors.blue,)),
              Container(width: 300, height: 100, color: Colors.yellow,)
            ],
          ),
          Container(
            color: Colors.green.withOpacity(0.2),
            height: 300,
            child: ListView.builder(
              itemCount: 10,
              itemExtent: 80,
              itemBuilder: (context, index) {
                return Center(child: Text("$index", style: ThemeManager.subTitleStyle,));
              },
            ),
          )
        ],
      ),
    );
  }
}

class OtherScreen extends StatefulWidget {
  const OtherScreen({super.key});

  @override
  State<OtherScreen> createState() => _OtherScreenState();
}

class _OtherScreenState extends State<OtherScreen> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text("This is the other screen", style: ThemeManager.textStyle)
        ],
      ),
    );
  }
}