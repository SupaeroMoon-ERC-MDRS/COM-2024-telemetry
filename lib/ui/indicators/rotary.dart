import 'dart:math';

import 'package:flutter/material.dart';
import 'package:supaeromoon_ground_station/data_storage/data_storage.dart';
import 'package:supaeromoon_ground_station/ui/common.dart';
import 'package:supaeromoon_ground_station/ui/theme.dart';

const Offset _centerPosRatio = Offset(0.5, 0.60);
const double _startAngle = pi * 5 / 4;
const double _sweep = 2 * pi - (2 * (pi * 3 / 2 - _startAngle));

class RotaryIndicator extends StatefulWidget {
  const RotaryIndicator({super.key, required this.subscribedSignal, required this.minValue, required this.maxValue, required this.stepValue});

  final String subscribedSignal;
  final num minValue;
  final num stepValue;
  final num maxValue;

  @override
  State<RotaryIndicator> createState() => _RotaryIndicatorState();
}

class _RotaryIndicatorState extends State<RotaryIndicator> {
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
    return SizedBox(
      height: 200,
      width: 200,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _RotaryIndicatorStaticPainter(
              label: label,
              minValue: widget.minValue,
              stepValue: widget.stepValue,
              maxValue: widget.maxValue,
            ),
          ),
          CustomPaint(
            painter: _RotaryIndicatorDynamicPainter(
              minValue: widget.minValue,
              stepValue: widget.stepValue,
              maxValue: widget.maxValue,
              value: DataStorage.storage[widget.subscribedSignal]?.vt.lastOrNull?.value,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    DataStorage.storage[widget.subscribedSignal]?.changeNotifier.removeListener(_update);
    super.dispose();
  }
}

class _RotaryIndicatorStaticPainter extends CustomPainter {
  final String label;
  final num minValue;
  final num stepValue;
  final num maxValue;

  _RotaryIndicatorStaticPainter({required this.label, required this.minValue, required this.stepValue, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    final double diameter = size.width * 0.85;
    final double tickDiameter = size.width * 0.65;
    final Offset centerPos = Offset(size.width * _centerPosRatio.dx, size.height * _centerPosRatio.dy);
    final Paint paintBase = Paint()..style = PaintingStyle.stroke;

    // empty track
    final Path track = Path();
    track.addArc(Rect.fromCenter(center: centerPos, width: diameter, height: diameter), 2 * pi - _startAngle, _sweep);
    canvas.drawPath(track, paintBase..color = ThemeManager.globalStyle.secondaryColor..strokeWidth = 5);

    // label
    final TextPainter labeltp = TextPainter(
      text: TextSpan(text: label, style: ThemeManager.textStyle),
      textDirection: TextDirection.ltr
    );
    labeltp.layout();
    final Offset labels = Offset(labeltp.size.width, labeltp.size.height);
    labeltp.paint(canvas, Offset(size.width / 2, 10) - labels / 2);
    
    // tick values
    num value = minValue;
    while(value <= maxValue){
      final TextPainter ticktp = TextPainter(
        text: TextSpan(text: representNumber(value, targetChar: 5), style: ThemeManager.textStyle),
        textDirection: TextDirection.ltr
      );
      ticktp.layout();
      final Offset ticks = Offset(ticktp.size.width, ticktp.size.height);
      final Offset tickpos = centerPos + Offset.fromDirection(2 * pi - _startAngle + _sweep * normalizeInbetween(value, minValue, maxValue, 0, 1), tickDiameter / 2);
      ticktp.paint(canvas, tickpos - ticks / 2);

      value += stepValue;
    }
  }

  @override
  bool shouldRepaint(_RotaryIndicatorStaticPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(_RotaryIndicatorStaticPainter oldDelegate) => false;
}

class _RotaryIndicatorDynamicPainter extends CustomPainter {
  final num minValue;
  final num stepValue;
  final num maxValue;
  final num? value;

  _RotaryIndicatorDynamicPainter({required this.minValue, required this.stepValue, required this.maxValue, required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    if(value == null){
      return;
    }
    final double diameter = size.width * 0.85;
    final Offset centerPos = Offset(size.width * _centerPosRatio.dx, size.height * _centerPosRatio.dy);
    final Paint paintBase = Paint()..style = PaintingStyle.stroke;

    // fill track
    final Path track = Path();
    track.addArc(Rect.fromCenter(center: centerPos, width: diameter, height: diameter), 2 * pi - _startAngle, _sweep * normalizeInbetween(value!, minValue, maxValue, 0, 1));
    canvas.drawPath(track, paintBase..color = ThemeManager.globalStyle.primaryColor..strokeWidth = 10);

    // value
    final TextPainter valuetp = TextPainter(
      text: TextSpan(text: representNumber(value), style: ThemeManager.textStyle),
      textDirection: TextDirection.ltr
    );
    valuetp.layout();
    final Offset values = Offset(valuetp.size.width, valuetp.size.height);
    valuetp.paint(canvas, centerPos - values / 2);
  }

  @override
  bool shouldRepaint(_RotaryIndicatorDynamicPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(_RotaryIndicatorDynamicPainter oldDelegate) => true;
}