import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supaeromoon_ground_station/data_misc/alarm.dart';
import 'package:supaeromoon_ground_station/data_misc/virtual_signals.dart';
import 'package:supaeromoon_ground_station/data_source/database.dart';
import 'package:supaeromoon_ground_station/data_storage/data_storage.dart';
import 'package:supaeromoon_ground_station/data_storage/session.dart';
import 'package:supaeromoon_ground_station/io/logger.dart';
import 'package:supaeromoon_ground_station/ui/common.dart';
import 'package:supaeromoon_ground_station/ui/theme.dart';

class DBCSelector extends StatefulWidget {
  const DBCSelector({super.key});


  @override
  State<DBCSelector> createState() => _DBCSelectorState();
}

class _DBCSelectorState extends State<DBCSelector> {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      width: 600,
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: AdvancedTooltip(
              tooltipText: "A list of all DBC files to use",
              child: Text("DBC selector", style: ThemeManager.subTitleStyle,)
            ),
          ),
          Expanded(
            child: Container(
              color: ThemeManager.globalStyle.bgColor,
              padding: EdgeInsets.all(ThemeManager.globalStyle.padding),
              child: ListView.builder(
                itemCount: Session.dbcPaths.length,
                itemExtent: 50,
                itemBuilder:(context, index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 500,
                        child: Text(Session.dbcPaths[index], style: ThemeManager.textStyle,)
                      ),
                      IconButton(
                        onPressed: (){
                          Session.dbcPaths.removeAt(index);
                          DBCDatabase.messages.clear();
                          for(final String f in Session.dbcPaths){
                            DBCDatabase.parse(f);
                          }
                          setState(() {});
                        },
                        padding: const EdgeInsets.all(0),
                        splashRadius: 20,
                        icon: Icon(Icons.delete, color: ThemeManager.globalStyle.primaryColor,)
                      )
                    ],
                  );
                },
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: TextButton(
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  allowedExtensions: [".dbc"],
                  allowMultiple: false
                );
                if(result == null || result.files.length != 1){
                  localLogger.warning("File picker aborted", doNoti: false);
                  return;
                }

                final String fn = result.files.single.path!;
                if(Session.dbcPaths.contains(fn)){
                  localLogger.warning("This file is already added as dbc");
                  return;
                }

                if(!DBCDatabase.parse(fn)){
                  localLogger.error("DBC parsing failed, check logs");
                  DBCDatabase.messages.clear();
                  for(final String f in Session.dbcPaths){
                    DBCDatabase.parse(f);
                  }
                }
                else{
                  localLogger.info("DBC added");
                  Session.dbcPaths.add(fn);
                  DataStorage.setup();
                  VirtualSignalController.load();
                  AlarmController.load();
                  setState(() {});
                }

              },
              child: Text("Add new", style: ThemeManager.subTitleStyle,)
            ),
          )
        ],
      ),
    );
  }
}