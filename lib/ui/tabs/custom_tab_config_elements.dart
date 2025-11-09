import 'package:flutter/material.dart';
import 'package:supaeromoon_ground_station/data_storage/data_storage.dart';
import 'package:supaeromoon_ground_station/ui/input_widgets/search_selector.dart';
import 'package:supaeromoon_ground_station/ui/theme.dart';
import 'package:supaeromoon_ground_station/ui/visuals/panel.dart';

abstract class ConfigurableStatefulWidget extends StatefulWidget{
  const ConfigurableStatefulWidget({super.key, this.config});

  final dynamic config;
}

class _AddNewFooter extends StatelessWidget {
  const _AddNewFooter({required this.size, required this.onPressed});

  final Size size;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: size,
      child: Center(
        child: TextButton(
          onPressed: onPressed,
          child: Text("Add new", style: ThemeManager.textStyle,)
        ),
      ),
    );
  }
}

class _EditColsizeHeader extends StatelessWidget {
  const _EditColsizeHeader({required this.size, required this.colSize, required this.onDone});

  final Size size;
  final int colSize;
  final void Function(int) onDone;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: size,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ThemeManager.globalStyle.padding),
            decoration: BoxDecoration(border: Border(left: BorderSide(width: 1.0, color: ThemeManager.globalStyle.primaryColor),)),
            child: Text("Column size: ")
          ),
          const Spacer(),
          SizedBox(
            width: 100,
            child: TextFormField(
              decoration: InputDecoration(hintText: colSize.toString(),),
              onFieldSubmitted: (final String str){
                final int? maybe = int.tryParse(str);
                if(maybe == null){
                  // TODO notif
                  return;
                }
                onDone(maybe);
              },
            ),
          )
        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////

class NumericPanelConfig{
  final List<String?> subscribedSignals = [null];
  int colSize = 1;
}

class NumericPanelConfigurable extends ConfigurableStatefulWidget {
  const NumericPanelConfigurable({super.key, required this.config, required this.onChange});

  final NumericPanelConfig config;
  final VoidCallback onChange;

  @override
  State<NumericPanelConfigurable> createState() => _NumericPanelConfigurableState();
}

class _NumericPanelConfigurableState extends State<NumericPanelConfigurable> {
  @override
  Widget build(BuildContext context) {
    final int colNum = (widget.config.subscribedSignals.length / widget.config.colSize).ceil();
    return PanelWithHeaderFooter(
      colsize: widget.config.colSize,
      size: Size(colNum * 300, widget.config.colSize * 50 + 100), // + header footer height
      header: _EditColsizeHeader(
        size: Size(300.0 * colNum, 50),
        colSize: widget.config.colSize,
        onDone: (final int newValue){
          widget.config.colSize = newValue;
          widget.onChange();
        }
      ),
      footer: _AddNewFooter(
        size: Size(300.0 * colNum, 50),
        onPressed: () {
          widget.config.subscribedSignals.add(null);
          widget.onChange();
        }, 
      ),
      widgets: List.generate(widget.config.subscribedSignals.length, (final int i) => Row(
        children: [
          SearchSelector(
            selected: widget.config.subscribedSignals[i],
            hintText: "Select signal",
            options: DataStorage.storage.keys.toList(),
            onSelected: (final String? selected){
              if(selected != null){
                widget.config.subscribedSignals[i] = selected;
                widget.onChange();
              }
            }
          ),
          const Spacer(),
          IconButton(
            onPressed: (){
              widget.config.subscribedSignals.removeAt(i);
              widget.onChange();
            },
            icon: Icon(Icons.delete)
          )
        ],
      )),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////