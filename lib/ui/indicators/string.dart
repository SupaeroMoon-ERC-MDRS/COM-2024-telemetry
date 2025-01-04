import 'package:flutter/material.dart';
import 'package:supaeromoon_ground_station/data_storage/data_storage.dart';
import 'package:supaeromoon_ground_station/io/logger.dart';
import 'package:supaeromoon_ground_station/ui/common.dart';
import 'package:supaeromoon_ground_station/ui/theme.dart';

typedef Mapper = String Function(num?);

abstract class StringMapping{
  static String testMapping(final num? v){
    if(v is! int){
      localLogger.warning("Non-int value was passed as a string mapping", doNoti: false);
      return "";
    }

    const List<String> mapping = ["STATE_0", "STATE_1", "STATE_2"];

    if(mapping.length > v){
      return mapping[v];
    }
    else{
      return "UNDEF";
    }
  }
}

class StringIndicator extends StatefulWidget {
  const StringIndicator({super.key, required this.subscribedSignal, required this.mapper});

  final String subscribedSignal;
  final Mapper mapper;

  @override
  State<StringIndicator> createState() => _NumericIndicatorState();
}

class _NumericIndicatorState extends State<StringIndicator> {
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
            width: 150,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(width: 1.0, color: ThemeManager.globalStyle.primaryColor),
              )
            ),
            child: Text(
              widget.mapper(DataStorage.storage[widget.subscribedSignal]?.vt.lastOrNull?.value),
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