import 'package:flutter/material.dart';
import 'package:supaeromoon_ground_station/data_misc/notifiers.dart';
import 'package:supaeromoon_ground_station/ui/tabs/tmp.dart';

class TabTreeController{
  final List<MapEntry<String, List<Widget>>> tree = const [
    MapEntry("Dummy1", dummyTab1),
    MapEntry("Dummy2", dummyTab2),
    MapEntry("Dummy3", dummyTab3),
  ];
  final BlankNotifier notifier = BlankNotifier(null);
  int index;

  TabTreeController({required this.index});
}

class TabTree extends StatefulWidget {
  const TabTree({super.key, required this.controller});

  final TabTreeController controller;

  @override
  State<TabTree> createState() => _TabTreeState();
}

class _TabTreeState extends State<TabTree> {
  @override
  void initState() {
    widget.controller.notifier.addListener(_update);
    super.initState();
  }

  void _update() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        key: UniqueKey(),
        cacheExtent: 1000,
        children: widget.controller.tree[widget.controller.index].value
      )
    );
  }

  @override
  void dispose() {
    widget.controller.notifier.removeListener(_update);
    super.dispose();
  }
}