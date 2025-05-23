import 'package:flutter/material.dart';
import 'package:supaeromoon_ground_station/ui/theme.dart';

class Panel extends StatelessWidget {
  const Panel({super.key, required this.colsize, required this.widgets, required this.size});

  final int colsize;
  final List<Widget> widgets;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final int colcount = (widgets.length / colsize).ceil();
    return Container(
      width: size.width,
      height: size.height,
      padding: EdgeInsets.all(ThemeManager.globalStyle.padding),
      margin: EdgeInsets.all(ThemeManager.globalStyle.padding),
      decoration: BoxDecoration(
        color: ThemeManager.globalStyle.secondaryColor,
        borderRadius: BorderRadius.circular(ThemeManager.globalStyle.padding)
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for(int i = 0; i < colcount; i++)
            Flexible(
              child: Column(
                children: [
                  for(int j = 0; j < colsize && (i * colsize + j) < widgets.length; j++)
                    widgets[i * colsize + j]
                ]
              ),
            )
            
        ],
      ),
    );
  }
}