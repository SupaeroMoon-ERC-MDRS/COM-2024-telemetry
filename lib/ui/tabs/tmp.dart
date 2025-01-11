import 'package:flutter/material.dart';

import '../indicators/indicators.dart';

const List<Widget> dummyTab1 = [
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
  ),
  StringIndicator(subscribedSignal: "l_top", mapper: StringMapping.testMapping),
  StringIndicator(subscribedSignal: "left_trigger", mapper: StringMapping.testMapping),
  Row(
    children: [
      Flexible(
        child: TimeSeriesChart(
          subscribedSignals: ["left_trigger", "right_trigger"],
          title: "asd",
          min: 0,
          max: 255
        ),
      ),
      Flexible(
        child: TimeSeriesChart(
          subscribedSignals: ["thumb_left_x", "thumb_right_x", "thumb_left_y", "thumb_right_y"],
          title: "asd",
          min: 0,
          max: 255
        ),
      ),
    ],
  ),
  Row(
    children: [
      RotaryIndicator(subscribedSignal: "left_trigger", minValue: 0, maxValue: 255, stepValue: 50),
      RotaryIndicator(subscribedSignal: "right_trigger", minValue: 0, maxValue: 100, stepValue: 10)
    ],
  ),
];

const List<Widget> dummyTab2 = [
  Row(
    children: [
      Flexible(
        child: TimeSeriesChart(
          subscribedSignals: ["left_trigger", "right_trigger"],
          title: "asd",
          min: 0,
          max: 255
        ),
      ),
      Flexible(
        child: TimeSeriesChart(
          subscribedSignals: ["thumb_left_x", "thumb_right_x", "thumb_left_y", "thumb_right_y"],
          title: "asd",
          min: 0,
          max: 255
        ),
      ),
    ],
  ),
  Row(
    children: [
      ScaleIndicator(subscribedSignal: "thumb_right_x", minValue: 120, maxValue: 130),
      ScaleIndicator(subscribedSignal: "thumb_right_y", minValue: 120, maxValue: 255),
      ScaleIndicator(subscribedSignal: "left_trigger", minValue: 0, maxValue: 255),
      ScaleIndicator(subscribedSignal: "right_trigger", minValue: 0, maxValue: 100),
    ],
  ),
  BooleanIndicator(subscribedSignal: "l_top"),
  BooleanIndicator(subscribedSignal: "l_bottom"),
  NumericIndicator(subscribedSignal: "left_trigger"),
  NumericIndicator(subscribedSignal: "right_trigger"),
  NumericIndicator(subscribedSignal: "thumb_left_x"),
  NumericIndicator(subscribedSignal: "thumb_left_y"),
  NumericIndicator(subscribedSignal: "thumb_right_x"),
  NumericIndicator(subscribedSignal: "thumb_right_y"),
  StringIndicator(subscribedSignal: "l_top", mapper: StringMapping.testMapping),
  StringIndicator(subscribedSignal: "left_trigger", mapper: StringMapping.testMapping),
  Row(
    children: [
      RotaryIndicator(subscribedSignal: "left_trigger", minValue: 0, maxValue: 255, stepValue: 50),
      RotaryIndicator(subscribedSignal: "right_trigger", minValue: 0, maxValue: 100, stepValue: 10)
    ],
  ),
];

const List<Widget> dummyTab3 = [
  Row(
    children: [
      ScaleIndicator(subscribedSignal: "thumb_right_x", minValue: 120, maxValue: 130),
      ScaleIndicator(subscribedSignal: "thumb_right_y", minValue: 120, maxValue: 255),
      ScaleIndicator(subscribedSignal: "left_trigger", minValue: 0, maxValue: 255),
      ScaleIndicator(subscribedSignal: "right_trigger", minValue: 0, maxValue: 100),
    ],
  ),
  BooleanIndicator(subscribedSignal: "l_top"),
  BooleanIndicator(subscribedSignal: "l_bottom"),
  Row(
    children: [
      Flexible(
        child: TimeSeriesChart(
          subscribedSignals: ["left_trigger", "right_trigger"],
          title: "asd",
          min: 0,
          max: 255
        ),
      ),
      Flexible(
        child: TimeSeriesChart(
          subscribedSignals: ["thumb_left_x", "thumb_right_x", "thumb_left_y", "thumb_right_y"],
          title: "asd",
          min: 0,
          max: 255
        ),
      ),
    ],
  ),
  NumericIndicator(subscribedSignal: "left_trigger"),
  NumericIndicator(subscribedSignal: "right_trigger"),
  NumericIndicator(subscribedSignal: "thumb_left_x"),
  NumericIndicator(subscribedSignal: "thumb_left_y"),
  NumericIndicator(subscribedSignal: "thumb_right_x"),
  NumericIndicator(subscribedSignal: "thumb_right_y"),
  StringIndicator(subscribedSignal: "l_top", mapper: StringMapping.testMapping),
  StringIndicator(subscribedSignal: "left_trigger", mapper: StringMapping.testMapping),
  Row(
    children: [
      RotaryIndicator(subscribedSignal: "left_trigger", minValue: 0, maxValue: 255, stepValue: 50),
      RotaryIndicator(subscribedSignal: "right_trigger", minValue: 0, maxValue: 100, stepValue: 10)
    ],
  ),
];