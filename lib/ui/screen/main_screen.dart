import 'package:flutter/material.dart';
import 'package:supaeromoon_ground_station/ui/indicators/indicators.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 100,
            child: Container(
              color: Colors.red
            )
          ),
          Expanded(
            child: ListView(
              cacheExtent: 1000,
              children: const [
                BooleanIndicator(subscribedSignal: "l_top"),
                BooleanIndicator(subscribedSignal: "l_bottom"),
                NumericIndicator(subscribedSignal: "left_trigger"),
                NumericIndicator(subscribedSignal: "right_trigger"),
                NumericIndicator(subscribedSignal: "thumb_left_x"),
                NumericIndicator(subscribedSignal: "thumb_left_y"),
                NumericIndicator(subscribedSignal: "thumb_right_x"),
                NumericIndicator(subscribedSignal: "thumb_right_y"),
                Row(
                  children: [
                    ScaleIndicator(subscribedSignal: "thumb_right_x", minValue: 120, maxValue: 130),
                    ScaleIndicator(subscribedSignal: "thumb_right_y", minValue: 120, maxValue: 255),
                    ScaleIndicator(subscribedSignal: "left_trigger", minValue: 0, maxValue: 255),
                    ScaleIndicator(subscribedSignal: "right_trigger", minValue: 0, maxValue: 100),
                  ],
                )
              ],
            )
          ),
          SizedBox(
            height: 100,
            child: Container(
              color: Colors.red
            )
          ),
      
        ],
      ),
    );
  }
}