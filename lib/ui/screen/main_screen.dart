import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:supaeromoon_ground_station/data_misc/datalogger.dart';
import 'package:supaeromoon_ground_station/data_source/data_source.dart';
import 'package:supaeromoon_ground_station/data_source/replay.dart';
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
                          const ReplayControls(),
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

class ReplayControls extends StatefulWidget {
  const ReplayControls({super.key});

  @override
  State<ReplayControls> createState() => _ReplayControlsState();
}

class _ReplayControlsState extends State<ReplayControls> with SingleTickerProviderStateMixin {
  late final AnimationController _playPauseController;
  void _update() => setState(() {});

  @override
  void initState() {
    super.initState();
    _playPauseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: (Replay.wasStopped == true) ? 0.0 : 1.0, // 0.0 => play icon, 1.0 => pause icon
    );
  }

  @override
  void didChangeDependencies() {
    // Keep icon in sync if external logic changed the state before rebuild
    _playPauseController.value = (Replay.wasStopped == true) ? 0.0 : 1.0;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _playPauseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            final bool isPaused = (Replay.wasStopped == true);
            if (isPaused) {
              // Resume without altering the current speed
              Replay.resume();
              _playPauseController.forward(); // morph to pause
            } else {
              // Pause
              Replay.pause();
              _playPauseController.reverse(); // morph to play
            }
            _update();
          },
          iconSize: ThemeManager.globalStyle.subTitleFontSize + 6,
          padding: EdgeInsets.zero,
          splashColor: Colors.grey,
          icon: AnimatedIcon(
            icon: AnimatedIcons.play_pause,
            progress: _playPauseController,
          ),
          tooltip: (Replay.wasStopped == true) ? "Play" : "Pause",
        ),
        IconButton(
          onPressed: () {
            Replay.speed = (Replay.speed / 2).clamp(0.25, 16.0);
            _update();
          },
          iconSize: ThemeManager.globalStyle.subTitleFontSize + 6,
          padding: EdgeInsets.zero,
          splashColor: Colors.grey,
          icon: const Icon(Icons.slow_motion_video),
          tooltip: "Slow down",
        ),
        IconButton(
          onPressed: () {
            Replay.speed = (Replay.speed * 2).clamp(0.25, 16.0);
            _update();
          },
          iconSize: ThemeManager.globalStyle.subTitleFontSize + 6,
          padding: EdgeInsets.zero,
          splashColor: Colors.grey,
          icon: const Icon(Icons.fast_forward),
        ),
                // Dynamic speed label showing current replay speed.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Replay.speed == 1.0
                ? ThemeManager.globalStyle.secondaryColor
                : (Replay.speed > 1.0
                    ? Colors.green
                    : Colors.orange),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Replay.speed == 1.0
                  ? ThemeManager.globalStyle.primaryColor
                  : (Replay.speed > 1.0 ? Colors.green : Colors.orange),
              width: 1,
            ),
          ),
          child: Text(
            _formatSpeed(Replay.speed),
            style: ThemeManager.subTitleStyle.copyWith(
              fontSize: ThemeManager.globalStyle.subTitleFontSize - 2,
              color: Replay.speed == 1.0
                  ? ThemeManager.globalStyle.primaryColor
                  : (Replay.speed > 1.0 ? Colors.green.shade800 : Colors.orange.shade800),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

String _formatSpeed(double speed) {
  // Display nicer formatting: 1x, 1.50x, 0.25x etc. Strip trailing zeros except keep one decimal if needed.
  if (speed == 1.0) return "1x";
  String s = speed.toStringAsFixed(2);
  // Remove trailing zeros at end and any dangling decimal point
  s = s.replaceAll(RegExp(r"0+$"), "").replaceAll(RegExp(r"\.$"), "");
  return "${s}x";
}