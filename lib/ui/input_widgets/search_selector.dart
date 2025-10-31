import 'dart:math';

import 'package:flutter/material.dart';
import 'package:supaeromoon_ground_station/extensions.dart';
import 'package:supaeromoon_ground_station/io/logger.dart';
import 'package:supaeromoon_ground_station/ui/dialogs/dialog_base.dart';
import 'package:supaeromoon_ground_station/ui/theme.dart';

enum SortLogic{
  // ignore: constant_identifier_names
  STARTSWITH,
  // ignore: constant_identifier_names
  CONTAINS
}

class SearchSelector extends StatelessWidget {
  const SearchSelector({
    super.key,
    required this.selected,
    required this.hintText,
    required this.options,
    required this.onSelected,
  });

  final String? selected;
  final String hintText;
  final List<String> options;
  final Function(String?) onSelected;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (){
        showDialog<Widget>(
          context: context,
          builder: (BuildContext context){
            return DialogBase(
              title: hintText,
              minWidth: 500,
              maxHeight: 500,
              dialog: SearchSelectorDialog(hintText: hintText, options: options, onSelected: onSelected,),
            );
          }
        );
      },
      child: Text(selected ?? hintText, style: ThemeManager.textStyle,),
    );
  }
}

class SearchSelectorDialog extends StatefulWidget {
  const SearchSelectorDialog({
    super.key,
    required this.hintText,
    required this.options,
    required this.onSelected,
  });

  final String hintText;
  final List<String> options;
  final Function(String?) onSelected;

  @override
  State<SearchSelectorDialog> createState() => _SearchSelectorDialogState();
}

class _SearchSelectorDialogState extends State<SearchSelectorDialog> {
  TextEditingController controller = TextEditingController();
  SortLogic logic = SortLogic.STARTSWITH;

  @override
  Widget build(BuildContext context) {
    List<String> validSelection;
    if(logic == SortLogic.STARTSWITH){
      validSelection = widget.options.sorted((a, b) => a.compareTo(b))
        .where((key) => key.startsWith(controller.text)).toList();
    }
    else{
      validSelection = widget.options.sorted((a, b) => a.compareTo(b))
        .where((key) => key.contains(controller.text)).toList();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: ThemeManager.globalStyle.primaryColor, width: 1))
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(ThemeManager.globalStyle.padding),
                    width: constraints.maxWidth - 2 * ThemeManager.globalStyle.padding - 100,
                    child: TextFormField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: widget.hintText
                      ),
                      onChanged:(value) {
                        setState(() {});
                      },
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: TextButton(
                      onPressed: () {
                        if(logic == SortLogic.STARTSWITH){
                          logic = SortLogic.CONTAINS;
                        }
                        else{
                          logic = SortLogic.STARTSWITH;
                        }
                        setState(() {});
                      },
                      child: Text(logic == SortLogic.STARTSWITH ? "Starts with" : "Contains", style: ThemeManager.textStyle,),
                    )
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(ThemeManager.globalStyle.padding),
              width: constraints.maxWidth - 2 * ThemeManager.globalStyle.padding,
              height: min(500, MediaQuery.of(context).size.height) - 120 - 4 * ThemeManager.globalStyle.padding,
              child: ListView.builder(
                itemCount: validSelection.length,
                itemExtent: 30,
                cacheExtent: 400,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      controller.text = validSelection[index];
                    },
                    leading: Text(validSelection[index], style: ThemeManager.textStyle,),
                  );
                },
              ),
            ),
            Container(
              height: 50,
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: ThemeManager.globalStyle.primaryColor, width: 1))
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.keyboard_arrow_left, color: ThemeManager.globalStyle.primaryColor),
                    onPressed: (){
                        Navigator.of(context).pop();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.check, color: ThemeManager.globalStyle.primaryColor),
                    onPressed: () {
                      if(widget.options.contains(controller.text)){
                        widget.onSelected(controller.text);
                        Navigator.of(context).pop();
                      }
                      else{
                        localLogger.warning("${controller.text} is not an option");
                      }
                    },
                  ),
                ],
              ),
            )
          ],
        );
      }
    );
  }
}