import 'package:flutter/material.dart';
import 'package:supaeromoon_ground_station/data_misc/alarm.dart';
import 'package:supaeromoon_ground_station/data_misc/virtual_signals.dart';
import 'package:supaeromoon_ground_station/data_source/netcode_interop.dart';
import 'package:supaeromoon_ground_station/data_storage/session.dart';
import 'package:supaeromoon_ground_station/io/logger.dart';
import 'package:supaeromoon_ground_station/ui/dialogs/alarm_add.dart';
import 'package:supaeromoon_ground_station/ui/dialogs/dialog_base.dart';
import 'package:supaeromoon_ground_station/ui/dialogs/virtual_signal_add.dart';
import 'package:supaeromoon_ground_station/ui/input_widgets/expr_menu.dart';
import 'package:supaeromoon_ground_station/ui/input_widgets/multiline_textfield.dart';
import 'package:supaeromoon_ground_station/ui/input_widgets/servo_calib_view.dart';
import 'package:supaeromoon_ground_station/ui/input_widgets/textfield.dart';
import 'package:supaeromoon_ground_station/ui/tabs/tab_base.dart';
import 'package:supaeromoon_ground_station/ui/theme.dart';
import 'package:supaeromoon_ground_station/ui/visuals/panel.dart';

List<Widget> _settingsPanelTopLeft = [
  InTextField(
    label: "Buffer in ms",
    tooltip: "",
    getInitialValue: () => Session.bufferMs.toString(),
    onEditingComplete: (final String newValue){
      int? maybeInt = int.tryParse(newValue);
      if(maybeInt == null){
        localLogger.warning("Must be an int");
      }
      else{
        Session.bufferMs = maybeInt;
      }
      return Session.bufferMs.toString();
    }
  ),
  InTextField(
    label: "Chart refresh rate",
    tooltip: "Chart refresh interval in ms",
    getInitialValue: () => Session.chartRefreshMs.toString(),
    onEditingComplete: (final String newValue){
      int? maybeInt = int.tryParse(newValue);
      if(maybeInt == null){
        localLogger.warning("Must be an int");
      }
      else{
        Session.chartRefreshMs = maybeInt;
      }
      return Session.chartRefreshMs.toString();
    }
  ),
  InTextField(
    label: "IPv4 subnet",
    tooltip: "",
    getInitialValue: () => Session.subnet,
    onEditingComplete: (final String newValue){
      if(newValue.split('.').length != 4){
        localLogger.warning("Must be an IPv4 /24 subnet");
      }
      else{
        Session.subnet = newValue;
      }
      return Session.subnet;
    }
  ),
  InTextField(
    label: "Raspi IPv4 address",
    tooltip: "",
    getInitialValue: () => Session.raspiIp,
    onEditingComplete: (final String newValue){
      if(newValue.split('.').length != 4){
        localLogger.warning("Must be an IPv4 address");
      }
      else{
        Session.raspiIp = newValue;
      }
      return Session.raspiIp;
    }
  ),
  InTextField(
    label: "Remote path",
    tooltip: "",
    getInitialValue: () => Session.remotePath,
    onEditingComplete: (final String newValue){
      Session.remotePath = newValue;
      return Session.remotePath;
    }
  ),
  InTextField(
    label: "Netcode path",
    tooltip: "",
    getInitialValue: () => Session.netCodePath,
    onEditingComplete: (final String newValue){
      final String oldValue = Session.netCodePath;
      Session.netCodePath = newValue;
      if(!NetCode.loadDLL()){
        Session.netCodePath = oldValue;
        localLogger.critical("Netcode loading failed, Network mode is unavailable", doNoti: true);
      }
      else{
        localLogger.info("Netcode loading successful, Network mode is available", doNoti: true);
      }
      return Session.netCodePath;
    }
  ),
];

List<Widget> _settingsPanelLogReplay = [
  InTextField(
    label: "Log save path",
    tooltip: "",
    getInitialValue: () => Session.logSavePath,
    onEditingComplete: (final String newValue){
      Session.logSavePath = newValue;
      return Session.logSavePath;
    }
  ),
  InTextField(
    label: "Log replay path",
    tooltip: "",
    getInitialValue: () => Session.logReadPath,
    onEditingComplete: (final String newValue){
      Session.logReadPath = newValue;
      return Session.logReadPath;
    }
  ),
];

List<Widget> settingsTab = [
  Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Column(
        children: [
          Panel(
            colsize: 6,
            size: Size(400 + 2 * ThemeManager.globalStyle.padding, 30 * 6 + 2 * ThemeManager.globalStyle.padding),
            widgets: _settingsPanelTopLeft
          ),
          Panel(
            colsize: 2,
            size: Size(400 + 2 * ThemeManager.globalStyle.padding, 30 * 2 + 2 * ThemeManager.globalStyle.padding),
            widgets: _settingsPanelLogReplay
          ),
          Panel(
            colsize: 1,
            widgets: [
              ExpressionMenu(
                title: "Virtual signals",
                titleTooltip: "Signals that are computed as a function of other signals",
                getLen: VirtualSignalController.getLen,
                removeAt: VirtualSignalController.remove,
                getElemWidget: VirtualSignalController.getWidget,
                addNew: () async {
                  await showDialog(
                    context: TabTree.context,
                    builder:(context) {
                      return const DialogBase(
                        title: "Virtual signal creator",
                        minWidth: 1000,
                        dialog: VirtualSignalAddDialog(),
                      );
                    },
                  );
                }
              )
            ],
            size: Size(400 + 2 * ThemeManager.globalStyle.padding, 250 + 2 * ThemeManager.globalStyle.padding),
          ),
          Panel(
            colsize: 1,
            widgets: [
              ExpressionMenu(
                title: "Alarms",
                titleTooltip: "Alarms that trigger on a condition",
                getLen: AlarmController.getLen,
                removeAt: AlarmController.remove,
                getElemWidget: AlarmController.getWidget,
                addNew: () async {
                  await showDialog(
                    context: TabTree.context,
                    builder:(context) {
                      return const DialogBase(
                        title: "Alarm creator",
                        minWidth: 1000,
                        dialog: AlarmAddDialog(),
                      );
                    },
                  );
                }
              )
            ],
            size: Size(400 + 2 * ThemeManager.globalStyle.padding, 250 + 2 * ThemeManager.globalStyle.padding),
          ),
        ],
      ),
      Column(
        children: [
          Panel(
            colsize: 1,
            widgets: const [DBCSelector()],
            size: Size(600 + 2 * ThemeManager.globalStyle.padding, 250 + 2 * ThemeManager.globalStyle.padding),
          ),
          Panel(
            colsize: 1,
            widgets: const [ServoCalibView()],
            size: Size(600 + 2 * ThemeManager.globalStyle.padding, 300 + 2 * ThemeManager.globalStyle.padding),
          ),
        ],
      ),
    ],
  )
];