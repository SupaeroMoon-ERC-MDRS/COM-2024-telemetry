import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:supaeromoon_ground_station/data_misc/datalogger.dart';
import 'package:supaeromoon_ground_station/data_source/data_source.dart';
import 'package:supaeromoon_ground_station/data_storage/session.dart';
import 'package:supaeromoon_ground_station/io/localization.dart';
import 'package:supaeromoon_ground_station/lifecycle.dart';
import 'package:supaeromoon_ground_station/notifications/notification_widgets.dart';
import 'package:supaeromoon_ground_station/ui/input_widgets/dash_menu.dart';
import 'package:supaeromoon_ground_station/ui/input_widgets/sliding_switch.dart';
import 'package:supaeromoon_ground_station/ui/tabs/tab_base.dart';
import 'package:supaeromoon_ground_station/ui/theme.dart';

final TabTreeController _tabTreeController = TabTreeController(index: Session.tabIndex);
final DashController _dashController = DashController(
  icons: _tabTreeController.tree.map((e) => e.icon).toList(),
);

final SlidingSwitchController<int> _topMenuController = SlidingSwitchController(
  items: List.generate(_tabTreeController.tree.length, (index) => index),
  names: _tabTreeController.tree.map((e) => e.name).toList(),
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
          Expanded(
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Row(
                  children: [
                    DashMenuSlidingSwitch(controller: _topMenuController, dashController: _dashController,),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(child: TabTree(controller: _tabTreeController)),
                          /*SizedBox(
                            height: 100,
                            child: Container(
                              color: Colors.red
                            )
                          ),*/
                        ],
                      ),
                    ),
                  ],
                ),
                const NotificationOverlay()
              ],
            ),
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
    return Container(
      height: 30,
      color: ThemeManager.globalStyle.secondaryColor,
      child: Row(
        children: [
          IconButton(
            onPressed: (){
              _dashController.toggleOpen();
            },
            iconSize: ThemeManager.globalStyle.subTitleFontSize + 6,
            padding: EdgeInsets.zero,
            splashColor: Colors.grey,
            icon: const Icon(Icons.menu)
          ),
          
          Expanded(
            child: Container(
              color: ThemeManager.globalStyle.secondaryColor,
              child: MoveWindow(
                child: Row(
                  children: [
                    Text(Loc.get("ground_station_title"),
                      style: ThemeManager.subTitleStyle.copyWith(color: ThemeManager.globalStyle.primaryColor, fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
              ),
            )
          ),
          SizedBox(
            width: 300,
            child: SlidingSwitch(
              controller: SlidingSwitchController(
                items: ["Selftest", "Network", "Replay"],
                names: ["Selftest", "Network", "Replay"],
                onChanged:(final int sel) {
                  if(sel == 0){
                    DataSource.selftest();
                  }
                  else if(sel == 1){
                    DataSource.net();
                  }
                  else{
                    DataSource.replay();
                  }
                },
                active: ["Selftest", "Network", "Replay"][DataSource.isMode(DataSourceMode.selftest) ? 0 : DataSource.isMode(DataSourceMode.net) ? 1 : 2]
              )
            ),
          ),
          const DataloggerControl(),
          IconButton(
            onPressed: (){
              ThemeManager.changeStyle(ThemeManager.activeStyle == "DARK" ? "BRIGHT" : "DARK");
            },
            iconSize: ThemeManager.globalStyle.subTitleFontSize + 6,
            padding: EdgeInsets.zero,
            splashColor: Colors.grey,
            icon: Icon(ThemeManager.activeStyle == "DARK" ? Icons.dark_mode : Icons.light_mode)
          ),
          MinimizeWindowButton(colors: ThemeManager.windowButtonColors,),
          appWindow.isMaximized
            ? RestoreWindowButton(colors: ThemeManager.windowButtonColors,
                onPressed: appWindow.maximizeOrRestore,
              )
            : MaximizeWindowButton(colors: ThemeManager.windowButtonColors,
                onPressed: appWindow.maximizeOrRestore,
              ),
          CloseWindowButton(
            colors: ThemeManager.windowButtonColors..mouseOver = Colors.red,
            onPressed: () async {
              await LifeCycle.shutdown();
            },
          ),
        ],
      ),
    );
  }
}

class DataloggerControl extends StatefulWidget {
  const DataloggerControl({super.key});

  @override
  State<DataloggerControl> createState() => _DataloggerControlState();
}

class _DataloggerControlState extends State<DataloggerControl> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: (){
        Datalogger.isRunning ? Datalogger.stopLogger() : Datalogger.startLogger();
        setState(() {});
      },
      iconSize: ThemeManager.globalStyle.subTitleFontSize + 6,
      padding: EdgeInsets.zero,
      splashColor: Colors.grey,
      icon: Icon(Datalogger.isRunning ? Icons.close : Icons.receipt)
    );
  }
}