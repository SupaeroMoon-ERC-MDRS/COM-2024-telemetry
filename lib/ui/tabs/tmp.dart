import 'package:flutter/material.dart';

import '../indicators/indicators.dart';

const List<Widget> remoteControlTab = [
  Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      Column(
        children: [
          BooleanIndicator(subscribedSignal: "l_top"),
          BooleanIndicator(subscribedSignal: "l_bottom"),
        ],
      ),
      Column(
        children: [
          BooleanIndicator(subscribedSignal: "l_left"),
          BooleanIndicator(subscribedSignal: "l_right"),
        ],
      ),
      Column(
        children: [
          BooleanIndicator(subscribedSignal: "r_top"),
          BooleanIndicator(subscribedSignal: "r_bottom"),
        ],
      ),
      Column(
        children: [
          BooleanIndicator(subscribedSignal: "l_left"),
          BooleanIndicator(subscribedSignal: "l_right"),
        ],
      ),
      Column(
        children: [
          StringIndicator(subscribedSignal: "e_stop", mapper: StringMapping.eStopMapping),
        ],
      )
    ],
  ),
  TimeSeriesChart(
    subscribedSignals: ["left_trigger", "right_trigger"],
    title: "Triggers",
    min: 0,
    max: 255
  ),
  TimeSeriesChart(
    subscribedSignals: ["thumb_left_x", "thumb_right_x", "thumb_left_y", "thumb_right_y"],
    title: "Thumbs",
    min: 0,
    max: 255
  ),
];

const List<Widget> electricalTab = [
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
          subscribedSignals: ["rpi_ina_voltage", "rpi_ina_current"],
          title: "INA",
          min: 0,
          max: 20
        ),
      ),
      Flexible(
        child: TimeSeriesChart(
          subscribedSignals: ["rpi_rssi"],
          title: "RSSI",
          min: -100,
          max: 20
        ),
      ),
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