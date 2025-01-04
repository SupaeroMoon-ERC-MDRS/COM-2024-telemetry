import 'package:flutter/material.dart';
import 'package:supaeromoon_ground_station/data_storage/data_storage.dart';
import 'package:supaeromoon_ground_station/ui/common.dart';
import 'package:supaeromoon_ground_station/ui/theme.dart';

class NumericIndicator extends StatefulWidget {
  const NumericIndicator({super.key, required this.subscribedSignal});

  final String subscribedSignal;

  @override
  State<NumericIndicator> createState() => _NumericIndicatorState();
}

class _NumericIndicatorState extends State<NumericIndicator> {
  late final String label;

  @override
  void initState() {
    DataStorage.storage[widget.subscribedSignal]?.changeNotifier.addListener(_update);
    label = DataStorage.storage[widget.subscribedSignal]?.displayName ?? widget.subscribedSignal;
    super.initState();
  }

  void _update() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(ThemeManager.globalStyle.padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(right: ThemeManager.globalStyle.padding),
            child: AdvancedTooltip(
              tooltipText: "Listening to ${widget.subscribedSignal}",
              child: Text(label, textAlign: TextAlign.left, maxLines: 1, style: ThemeManager.textStyle,)
            )
          ),
          Container(
            width: 100,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(width: 1.0, color: ThemeManager.globalStyle.primaryColor),
              )
            ),
            child: Text(
              representNumber(DataStorage.storage[widget.subscribedSignal]?.vt.lastOrNull?.value),
              textAlign: TextAlign.center, maxLines: 1, style: ThemeManager.textStyle
            ),
          ),
        ],
      )
    );
  }

  @override
  void dispose() {
    DataStorage.storage[widget.subscribedSignal]?.changeNotifier.removeListener(_update);
    super.dispose();
  }
}