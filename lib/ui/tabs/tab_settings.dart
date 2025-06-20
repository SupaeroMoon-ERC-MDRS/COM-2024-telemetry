import 'package:flutter/material.dart';
import 'package:supaeromoon_ground_station/data_storage/session.dart';
import 'package:supaeromoon_ground_station/io/logger.dart';
import 'package:supaeromoon_ground_station/ui/input_widgets/multiline_textfield.dart';
import 'package:supaeromoon_ground_station/ui/input_widgets/textfield.dart';
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
            colsize: 4,
            size: Size(400 + 2 * ThemeManager.globalStyle.padding, 30 * 4 + 2 * ThemeManager.globalStyle.padding),
            widgets: _settingsPanelTopLeft
          ),
          Panel(
            colsize: 2,
            size: Size(400 + 2 * ThemeManager.globalStyle.padding, 30 * 2 + 2 * ThemeManager.globalStyle.padding),
            widgets: _settingsPanelLogReplay
          ),
        ],
      ),
      Panel(
        colsize: 1,
        widgets: const [DBCSelector()],
        size: Size(600 + 2 * ThemeManager.globalStyle.padding, 250 + 2 * ThemeManager.globalStyle.padding),
      ),
    ],
  )
];