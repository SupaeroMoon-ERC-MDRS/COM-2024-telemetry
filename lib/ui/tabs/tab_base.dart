import 'package:flutter/material.dart';
import 'package:supaeromoon_ground_station/data_misc/notifiers.dart';
import 'package:supaeromoon_ground_station/ui/tabs/tab_settings.dart';
import 'package:supaeromoon_ground_station/ui/tabs/tmp.dart';
import 'package:supaeromoon_ground_station/ui/theme.dart';

class TabEntry{
  final String name;
  final IconData icon;
  final List<Widget> tree;

  const TabEntry({required this.name, required this.icon, required this.tree});
}

class TabTreeController{
  final List<TabEntry> tree = [
    TabEntry(name: "Settings", icon: Icons.settings, tree: settingsTab),
    const TabEntry(name: "Dummy1", icon: Icons.tab, tree: dummyTab1),
    const TabEntry(name: "Dummy2", icon: Icons.tab, tree: dummyTab2),
    const TabEntry(name: "Dummy3", icon: Icons.tab, tree: dummyTab3),
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ThemeManager.globalStyle.padding),
      child: ListView(
        key: UniqueKey(),
        cacheExtent: 1000,
        children: widget.controller.tree[widget.controller.index].tree
      ),
    );
  }

  @override
  void dispose() {
    widget.controller.notifier.removeListener(_update);
    super.dispose();
  }
}