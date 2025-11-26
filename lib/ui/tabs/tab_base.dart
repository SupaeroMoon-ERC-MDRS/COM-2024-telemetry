import 'package:flutter/material.dart';
import 'package:supaeromoon_ground_station/data_misc/notifiers.dart';
import 'package:supaeromoon_ground_station/ui/tabs/custom_tab.dart';
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
    const TabEntry(name: "Remote Control", icon: Icons.control_camera, tree: remoteControlTab),
    const TabEntry(name: "Electrical", icon: Icons.electric_bolt, tree: electricalTab),
    TabEntry(name: "Custom", icon: Icons.dashboard_customize, tree: [CustomTabContainer(controller: CustomTabController(),)]),
  ];
  final BlankNotifier notifier = BlankNotifier(null);
  int index;
  //late final int fixedLastIndex;

  TabTreeController({required this.index}){
    //fixedLastIndex = tree.length - 1;
  }

  /*void addTab(final TabEntry entry){
    // TODO https://api.flutter.dev/flutter/material/Icons-class.html code from here
    // static const IconData ten_k = IconData(0xe000, fontFamily: 'MaterialIcons');
    tree.add(entry);
    ThemeManager.notifier.update();
  }

  void removeTab(final int tabIndex){
    if(tabIndex > fixedLastIndex){
      tree.removeAt(tabIndex);
      ThemeManager.notifier.update();
    }
  }*/
}

class TabTree extends StatefulWidget {
  const TabTree({super.key, required this.controller});

  final TabTreeController controller;
  static late BuildContext context;

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
    TabTree.context = context;
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