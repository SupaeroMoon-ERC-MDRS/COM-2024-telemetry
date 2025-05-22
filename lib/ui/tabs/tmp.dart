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
          title: "Thumbs",
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
      ScaleIndicator(subscribedSignal: "raspi_mem", minValue: 0, maxValue: 100),
      ScaleIndicator(subscribedSignal: "raspi_cpu", minValue: 0, maxValue: 100),
    ],
  ),
  Row(
    children: [
      Flexible(
        child: TimeSeriesChart(
          subscribedSignals: ["rpi_3v7_wl_sw_a", "rpi_3v3_sys_a", "rpi_1v8_sys_a"],
          title: "Currents1",
          min: 0,
          max: 10
        ),
      ),
      Flexible(
        child: TimeSeriesChart(
          subscribedSignals: ["rpi_0v8_sw_a", "vdd_core_a", "rpi_1v1_sys_a"],
          title: "Currents2",
          min: 0,
          max: 10
        ),
      ),
    ],
  ),
  Row(
    children: [
      Flexible(
        child: TimeSeriesChart(
          subscribedSignals: ["rpi_3v7_wl_sw_v", "rpi_3v3_sys_v", "rpi_1v8_sys_v", "rpi_1v1_sys_v"],
          title: "Voltages1",
          min: 0,
          max: 5
        ),
      ),
      Flexible(
        child: TimeSeriesChart(
          subscribedSignals: ["rpi_0v8_sw_v", "vdd_core_v", "rpi_ext5v_v"],
          title: "Voltages2",
          min: 0,
          max: 5
        ),
      ),
    ],
  ),
];