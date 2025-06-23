import 'package:flutter/material.dart';
import 'package:supaeromoon_ground_station/ui/common.dart';
import 'package:supaeromoon_ground_station/ui/theme.dart';

class ExpressionMenu extends StatefulWidget {
  const ExpressionMenu({
    super.key,
    required this.title,
    required this.titleTooltip,
    required this.getLen,
    required this.removeAt,
    required this.getElemWidget,
    required this.addNew
  });

  final String title;
  final String titleTooltip;
  final int Function() getLen;
  final void Function(int) removeAt;
  final Widget Function(int) getElemWidget;
  final Future<void> Function() addNew;

  @override
  State<ExpressionMenu> createState() => _ExpressionMenuState();
}

class _ExpressionMenuState extends State<ExpressionMenu> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      width: 400,
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: AdvancedTooltip(
              tooltipText: widget.titleTooltip,
              child: Text(widget.title, style: ThemeManager.subTitleStyle,)
            ),
          ),
          Expanded(
            child: Container(
              color: ThemeManager.globalStyle.bgColor,
              padding: EdgeInsets.all(ThemeManager.globalStyle.padding),
              child: ListView.builder(
                itemCount: widget.getLen(),
                itemExtent: 50,
                itemBuilder:(context, index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 400 - 7 * ThemeManager.globalStyle.padding,
                        child: widget.getElemWidget(index)
                      ),
                      IconButton(
                        onPressed: (){
                          widget.removeAt(index);
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
                await widget.addNew();
                setState(() {});
              },
              child: Text("Add new", style: ThemeManager.subTitleStyle,)
            ),
          )
        ],
      ),
    );
  }
}