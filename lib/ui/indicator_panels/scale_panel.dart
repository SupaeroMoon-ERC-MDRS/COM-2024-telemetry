import 'package:flutter/material.dart';
import 'package:supaeromoon_ground_station/ui/indicators/indicators.dart';
import 'package:supaeromoon_ground_station/ui/visuals/panel.dart';

class BooleanPanel extends StatelessWidget {
  const BooleanPanel({super.key, required this.subscribedSignals, required this.minValue, required this.maxValue});

  final List<String> subscribedSignals;
  final List<num> minValue;
  final List<num> maxValue;

  @override
  Widget build(BuildContext context) {
    final int colNum = subscribedSignals.length;
    return Panel(
      colsize: 1,
      size: Size(colNum * 80, 200),
      widgets: List.generate(subscribedSignals.length, (final int i) => ScaleIndicator(subscribedSignal: subscribedSignals[i], minValue: minValue[i], maxValue: maxValue[i],)),
    );
  }
}