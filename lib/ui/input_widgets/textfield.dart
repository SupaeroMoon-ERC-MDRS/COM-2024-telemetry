import 'package:flutter/material.dart';
import 'package:supaeromoon_ground_station/ui/common.dart';
import 'package:supaeromoon_ground_station/ui/theme.dart';

class InTextField extends StatefulWidget {
  const InTextField({super.key, required this.label, required this.tooltip, required this.getInitialValue, required this.onEditingComplete});

  final String label;
  final String tooltip;
  final String Function() getInitialValue;
  final String Function(String) onEditingComplete;

  @override
  State<InTextField> createState() => _InTextFieldState();
}

class _InTextFieldState extends State<InTextField> {
  bool editMode = false;
  final TextEditingController controller = TextEditingController();
  
  @override
  void initState() {
    controller.text = widget.getInitialValue();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      width: 400,
      child: Row(
        children: [
          AdvancedTooltip(
            tooltipText: widget.tooltip,
            child: SizedBox(
              width: 200,
              child: Text(widget.label, style: ThemeManager.textStyle,),
            ),
          ),
          SizedBox(
            width: 200,
            child: editMode ?
              TextFormField(
                decoration: InputDecoration(hintText: controller.text,),
                controller: controller,
                onEditingComplete: () {
                  controller.text = widget.onEditingComplete(controller.text);
                  editMode = false;
                  setState(() {});
                },
              )
              :
              TextButton(
                onPressed: (){
                  editMode = true;
                  setState(() {});
                },
                child: Text(controller.text)
              )
          )
        ],
      )
    );
  }
}