import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supaeromoon_ground_station/data_source/database.dart';
import 'package:supaeromoon_ground_station/data_source/net.dart';
import 'package:supaeromoon_ground_station/data_storage/data_storage.dart';
import 'package:supaeromoon_ground_station/io/file_system.dart';
import 'package:supaeromoon_ground_station/io/logger.dart';
import 'package:supaeromoon_ground_station/notifications/notification_logic.dart' as noti;
import 'package:supaeromoon_ground_station/ui/common.dart';
import 'package:supaeromoon_ground_station/ui/theme.dart';

class ServoCalibStatus{
  int fl;
  int fr;
  int rl;
  int rr;

  ServoCalibStatus({required this.fl, required this.fr, required this.rl, required this.rr});
}

class ServoCalibView extends StatefulWidget {
  const ServoCalibView({super.key});

  @override
  State<ServoCalibView> createState() => _ServoCalibViewState();
}

class _ServoCalibViewState extends State<ServoCalibView> {
  final ServoCalibStatus editStatus = ServoCalibStatus(fl: 45, fr: 245, rl: 245, rr: 45);
  final ServoCalibStatus realStatus = ServoCalibStatus(fl: -1, fr: -1, rl: -1, rr: -1);

  @override
  void initState() {
    _load();
    if(DataStorage.storage["fl_calib"]!.vt.isEmpty){
      Future.delayed(Duration(milliseconds: 100), _downloadRequest);
    }
    else{
      realStatus.fl = DataStorage.storage["fl_calib"]!.vt.lastOrNull?.value.toInt() ?? -1;
      realStatus.fr = DataStorage.storage["fr_calib"]!.vt.lastOrNull?.value.toInt() ?? -1;
      realStatus.rl = DataStorage.storage["rl_calib"]!.vt.lastOrNull?.value.toInt() ?? -1;
      realStatus.rr = DataStorage.storage["rr_calib"]!.vt.lastOrNull?.value.toInt() ?? -1;
    }
    DataStorage.storage["rr_calib"]!.changeNotifier.addListener(_readCalibStatusFromBuffer);
    super.initState();
  }

  void _readCalibStatusFromBuffer(){
    realStatus.fl = DataStorage.storage["fl_calib"]!.vt.lastOrNull?.value.toInt() ?? -1;
    realStatus.fr = DataStorage.storage["fr_calib"]!.vt.lastOrNull?.value.toInt() ?? -1;
    realStatus.rl = DataStorage.storage["rl_calib"]!.vt.lastOrNull?.value.toInt() ?? -1;
    realStatus.rr = DataStorage.storage["rr_calib"]!.vt.lastOrNull?.value.toInt() ?? -1;
    setState(() {});
  }

  void _upload(){
    final Map<String, num> calibMessage = {
      "fl_calib": editStatus.fl,
      "fr_calib": editStatus.fr,
      "rl_calib": editStatus.rl,
      "rr_calib": editStatus.rr,
    };

    final Uint8List bytes = DBCDatabase.encode([MapEntry(16, calibMessage)]);
    Net.sendToRover(bytes);
  }

  void _downloadRequest(){
    final Map<String, num> calibMessage = {
      "fl_calib": 0,
      "fr_calib": 0,
      "rl_calib": 0,
      "rr_calib": 0,
    };

    final Uint8List bytes = DBCDatabase.encode([MapEntry(16, calibMessage)]);
    Net.sendToRover(bytes);
  }

  Future<void> _save() async {
    await FileSystem.trySaveMapToLocalAsync(FileSystem.servoCalibDir, "servo.calib", {
      "fl": editStatus.fl,
      "fr": editStatus.fr,
      "rl": editStatus.rl,
      "rr": editStatus.rr,
    });
  }

  void _load() {
    final Map servoCalibData = FileSystem.tryLoadMapFromLocalSync(FileSystem.servoCalibDir, "servo.calib");
    if(servoCalibData.isEmpty){
      noti.NotificationController.add(noti.Notification.decaying(LogEntry.warning("Did not find previously saved servo calibration file"), 5000));
      return;
    }

    if({"fl", "fr", "rl", "rr"}.difference(servoCalibData.keys.toSet()).isNotEmpty){
      noti.NotificationController.add(noti.Notification.decaying(LogEntry.warning("Could not load previously saved servo calibration file"), 5000));
      return;
    }

    editStatus.fl = servoCalibData["fl"];
    editStatus.fr = servoCalibData["fr"];
    editStatus.rl = servoCalibData["rl"];
    editStatus.rr = servoCalibData["rr"];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: 600,
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: AdvancedTooltip(
              tooltipText: "The was to calibrate servos on the fly",
              child: Text("Servo calibration", style: ThemeManager.subTitleStyle,)
            ),
          ),
          SingleServoCalib(
            name: "FL",
            editValue: editStatus.fl, 
            realValue: realStatus.fl, 
            onIncrement: () {editStatus.fl++; setState(() {});}, 
            onDecrement: () {editStatus.fl--; setState(() {});}, 
          ),
          SingleServoCalib(
            name: "FR",
            editValue: editStatus.fr,
            realValue: realStatus.fr, 
            onIncrement: () {editStatus.fr++; setState(() {});}, 
            onDecrement: () {editStatus.fr--; setState(() {});}, 
          ),
          SingleServoCalib(
            name: "RL",
            editValue: editStatus.rl, 
            realValue: realStatus.rl,
            onIncrement: () {editStatus.rl++; setState(() {});}, 
            onDecrement: () {editStatus.rl--; setState(() {});}, 
          ),
          SingleServoCalib(
            name: "RR",
            editValue: editStatus.rr, 
            realValue: realStatus.rr,
            onIncrement: () {editStatus.rr++; setState(() {});}, 
            onDecrement: () {editStatus.rr--; setState(() {});}, 
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: _upload,
                padding: const EdgeInsets.all(0),
                splashRadius: 20,
                icon: Icon(Icons.upload, color: ThemeManager.globalStyle.primaryColor,)
              ),
              IconButton(
                onPressed: _downloadRequest,
                padding: const EdgeInsets.all(0),
                splashRadius: 20,
                icon: Icon(Icons.download, color: ThemeManager.globalStyle.primaryColor,)
              ),
              IconButton(
                onPressed: _save,
                padding: const EdgeInsets.all(0),
                splashRadius: 20,
                icon: Icon(Icons.save, color: ThemeManager.globalStyle.primaryColor,)
              ),
              IconButton(
                onPressed: (){
                  _load();
                  setState(() {});
                },
                padding: const EdgeInsets.all(0),
                splashRadius: 20,
                icon: Icon(Icons.file_open, color: ThemeManager.globalStyle.primaryColor,)
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    DataStorage.storage["rr_calib"]!.changeNotifier.removeListener(_readCalibStatusFromBuffer);
    super.dispose();
  }
}

class SingleServoCalib extends StatelessWidget {
  const SingleServoCalib({super.key, required this.name, required this.editValue, required this.realValue, required this.onIncrement, required this.onDecrement});

  final String name;
  final int editValue;
  final int realValue;
  final void Function() onIncrement;
  final void Function() onDecrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 50,
          padding: EdgeInsets.all(ThemeManager.globalStyle.padding),
          child: Text(name, style: ThemeManager.subTitleStyle,),
        ),
        TextButton(
          onPressed: onDecrement,
          child: Text("-", style: ThemeManager.titleStyle,),
        ),
        Container(
          width: 50,
          padding: EdgeInsets.all(ThemeManager.globalStyle.padding),
          child: Text(editValue.toString(), style: ThemeManager.subTitleStyle,),
        ),
        TextButton(
          onPressed: onIncrement,
          child: Text("+", style: ThemeManager.titleStyle,),
        ),
        const Spacer(),
        Padding(
          padding: EdgeInsets.all(ThemeManager.globalStyle.padding),
          child: Text("Currently: ${realValue.toString()}", style: ThemeManager.textStyle,),
        ),
      ],
    );
  }
}