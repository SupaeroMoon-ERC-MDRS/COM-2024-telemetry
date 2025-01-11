import 'package:flutter/material.dart';
import 'package:supaeromoon_ground_station/data_storage/session.dart';
import 'package:supaeromoon_ground_station/ui/input_widgets/sliding_switch.dart';
import 'package:supaeromoon_ground_station/ui/tabs/tab_base.dart';

final TabTreeController _tabTreeController = TabTreeController(index: Session.tabIndex);

final SlidingSwitchController<int> _topMenuController = SlidingSwitchController(
  items: List.generate(_tabTreeController.tree.length, (index) => index),
  names: _tabTreeController.tree.map((e) => e.key).toList(),
  onChanged: (final int sel){
    _tabTreeController.index = sel;
    Session.tabIndex = sel;
    _tabTreeController.notifier.update();
  },
  active: _tabTreeController.index
);

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const TopMenu(),
          TabTree(controller: _tabTreeController),
          SizedBox(
            height: 100,
            child: Container(
              color: Colors.red
            )
          ),
        ],
      ),
    );
  }
}

class TopMenu extends StatelessWidget {
  const TopMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: Row()
          ),
          SlidingSwitch(controller: _topMenuController)
        ],
      ),
    );
  }
}