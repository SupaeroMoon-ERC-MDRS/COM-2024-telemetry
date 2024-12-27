import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:supaeromoon_ground_station/data_storage/data_storage.dart';
import 'package:supaeromoon_ground_station/ui/common.dart';
import 'package:supaeromoon_ground_station/ui/theme.dart';

class BooleanIndicator extends StatefulWidget{
  const BooleanIndicator({
  Key? key,
  required this.subscribedSignal, this.isInverted
  }) : super(key: key);

  final String subscribedSignal;
  final bool? isInverted; // null -> false, !null -> true

  @override
  State<StatefulWidget> createState() {
    return BooleanIndicatorState();
  }

}

class BooleanIndicatorState extends State<BooleanIndicator>{
  late final String label;

  @override
  void initState() {
    DataStorage.storage[widget.subscribedSignal]?.changeNotifier.addListener(_update);
    label = DataStorage.storage[widget.subscribedSignal]?.displayName ?? widget.subscribedSignal;
    super.initState();
  }

  void _update() => setState(() {});

  Color _getColor(final num? value){
    if(value == null){
      return ThemeManager.globalStyle.textColor;
    }

    if(widget.isInverted == null){
      return value == 0 ? const Color.fromARGB(255, 0, 255, 0) : const Color.fromARGB(255, 255, 0, 0);
    }
    else{
      return value == 1 ? const Color.fromARGB(255, 0, 255, 0) : const Color.fromARGB(255, 255, 0, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding( 
      padding: EdgeInsets.all(ThemeManager.globalStyle.padding),
      child: AdvancedTooltip(
        tooltipText: "Listening to ${widget.subscribedSignal} ${widget.isInverted == null ? "0 -> green" : "1 -> green"}",
        child: Text(
          "$label - ${representNumber(DataStorage.storage[widget.subscribedSignal]?.vt.lastOrNull?.value)}",
          textAlign: TextAlign.left,
          maxLines: 1,
          style: TextStyle(
            fontSize: ThemeManager.globalStyle.fontSize,
            color: _getColor(DataStorage.storage[widget.subscribedSignal]?.vt.lastOrNull?.value),
            fontFamily: "Poppins",
            fontWeight: FontWeight.w400,
            fontFeatures: const [FontFeature.tabularFigures()]
          ),
        ),
      )
    );
  }

  @override
  void dispose() {
    DataStorage.storage[widget.subscribedSignal]?.changeNotifier.removeListener(_update);
    super.dispose();
  }
}