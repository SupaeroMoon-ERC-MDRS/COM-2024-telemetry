import 'package:flutter/material.dart';
import 'package:supaeromoon_ground_station/data_misc/alarm.dart';
import 'package:supaeromoon_ground_station/data_storage/data_storage.dart';
import 'package:supaeromoon_ground_station/io/logger.dart';
import 'package:supaeromoon_ground_station/ui/dialogs/exec_tree_painter.dart';
import 'package:supaeromoon_ground_station/ui/theme.dart';

class AlarmAddDialog extends StatefulWidget {
  const AlarmAddDialog({super.key});

  @override
  State<AlarmAddDialog> createState() => _AlarmAddDialogState();
}

class _AlarmAddDialogState extends State<AlarmAddDialog> {
  final TextEditingController _expr = TextEditingController();
  final TextEditingController _name = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: constraints.maxHeight - 60,
                width: constraints.maxWidth,
                child: CustomPaint(
                  painter: ExecTreePainter(expr: _expr.text)
                ),
              ),
              SizedBox(
                height: 50,
                width: constraints.maxWidth,
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: ThemeManager.globalStyle.padding),
                      width: 400,
                      child: TextFormField(
                        decoration: const InputDecoration(hintText: "Name"),
                        controller: _name,
                        onEditingComplete: () {
                          setState(() {});
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: ThemeManager.globalStyle.padding),
                      width: 400,
                      child: TextFormField(
                        decoration: const InputDecoration(hintText: "Expression"),
                        controller: _expr,
                        onEditingComplete: () {
                          setState(() {});
                        },
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: (){
                        if(_expr.text.isEmpty || _name.text.isEmpty){
                          localLogger.warning("Name and expression both have to be given");
                          return;
                        }
                        if(DataStorage.storage.containsKey(_name.text)){
                          localLogger.warning("This signal already exists");
                          return;
                        }

                        AlarmController.add(
                          Alarm.fromMap({
                            "name": _name.text,
                            "expr": _expr.text
                          })
                        );
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.check,
                        color: ThemeManager.globalStyle.primaryColor,
                      )
                    )
                  ],
                ),
              )
            ],
          );
        }
      ),
    );
  }
}