import 'package:flutter/material.dart';
import 'package:supaeromoon_ground_station/ui/indicators/indicators.dart';
import 'package:supaeromoon_ground_station/ui/visuals/panel.dart';

class BooleanPanel extends StatelessWidget {
  const BooleanPanel({super.key, required this.subscribedSignals, required this.colSize});

  final List<String> subscribedSignals;
  final int colSize;

  @override
  Widget build(BuildContext context) {
    final int colNum = (subscribedSignals.length / colSize.toDouble()).ceil();
    return Panel(
      colsize: colSize,
      size: Size(colNum * 300, colSize * 50),
      widgets: List.generate(subscribedSignals.length, (final int i) => NumericIndicator(subscribedSignal: subscribedSignals[i])),
    );
  }
}