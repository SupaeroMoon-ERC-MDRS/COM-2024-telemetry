import 'package:flutter/material.dart';
import 'package:latext/latext.dart';
import 'package:supaeromoon_ground_station/data_storage/data_storage.dart';
import 'package:supaeromoon_ground_station/data_storage/unit_system.dart';
import 'package:supaeromoon_ground_station/ui/common.dart';
import 'package:supaeromoon_ground_station/ui/theme.dart';

class ScaleIndicator extends StatefulWidget {
  const ScaleIndicator({super.key, required this.subscribedSignal, required this.minValue, required this.maxValue});

  final String subscribedSignal;
  final num minValue;
  final num maxValue;

  @override
  State<ScaleIndicator> createState() => _ScaleIndicatorState();
}

class _ScaleIndicatorState extends State<ScaleIndicator> {
  late final String label;
  late final CompoundUnit unit;

  @override
  void initState() {
    DataStorage.storage[widget.subscribedSignal]?.changeNotifier.addListener(_update);
    label = DataStorage.storage[widget.subscribedSignal]?.displayName ?? widget.subscribedSignal;
    unit = DataStorage.storage[widget.subscribedSignal]?.unit ?? CompoundUnit.scalar();
    super.initState();
  }

  void _update() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: CustomPaint(
              size: const Size(170, 80),
              painter: _ScaleIndicatorPainter(
                label: label,
                maxValue: widget.maxValue,
                minValue: widget.minValue,
                value: DataStorage.storage[widget.subscribedSignal]?.vt.lastOrNull?.value
              ),
            ),
          ),
          SizedBox(
            height: 30,
            width: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  representNumber(DataStorage.storage[widget.subscribedSignal]?.vt.lastOrNull?.value), style: ThemeManager.textStyle
                ),
                LaTexT(
                  laTeXCode: Text(
                    " [${unit.toLaTextString()}]",
                    style: ThemeManager.textStyle
                  ),
                ),
              ],
            ),
          )
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

class _ScaleIndicatorPainter extends CustomPainter {
  final String label;
  final num maxValue;
  final num minValue;
  final num? value;

  _ScaleIndicatorPainter({required this.label, required this.maxValue, required this.minValue, required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final TextPainter labeltp = TextPainter(
      text: TextSpan(text: label, style: ThemeManager.textStyle),
      textDirection: TextDirection.ltr
    );

    labeltp.layout();

    final Offset labels = Offset(labeltp.size.width, labeltp.size.height);

    labeltp.paint(canvas, Offset(size.width / 2, 12) - labels / 2);

    const double insetW = 10;
    const double insetH = 25;
    final double splitHeight = size.height - normalizeInbetween(value ?? 0, minValue, maxValue, 0, size.height - 1 * insetH);

    final Path empty = Path();
    empty.moveTo(insetW, insetH);
    empty.lineTo(size.width - insetW, insetH);
    empty.lineTo(size.width - insetW, splitHeight);
    empty.lineTo(insetW, splitHeight);
    empty.lineTo(insetW, insetH);

    final Path filled = Path();
    filled.moveTo(insetW, splitHeight);
    filled.lineTo(size.width - insetW, splitHeight);
    filled.lineTo(size.width - insetW, size.height);
    filled.lineTo(insetW, size.height);
    filled.lineTo(insetW, splitHeight);

    final Paint paintBase = Paint()..style = PaintingStyle.fill;
    canvas.drawPath(empty, paintBase..color = ThemeManager.globalStyle.secondaryColor);
    canvas.drawPath(filled, paintBase..color = ThemeManager.globalStyle.primaryColor);
  }

  @override
  bool shouldRepaint(_ScaleIndicatorPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(_ScaleIndicatorPainter oldDelegate) => true;
}