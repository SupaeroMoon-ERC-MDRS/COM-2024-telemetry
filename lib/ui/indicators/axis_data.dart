import 'dart:math';

const double log10 = 2.302585092994046;
const int decimalPrec = 10;
const List<num> _intervalDivisions = <num>[10, 5, 2, 1];
const int _majorTickCount = 4;
const int _tickPerMajorTick = 3;

double _roundToDecimalPlaces(double value, int places){ 
   num mod = pow(10, places); 
   return (value * mod).roundToDouble() / mod; 
}

class ValueAxisData{
  final List<double> tickPositions;
  final List<double> majorTickPositions;
  final List<num> majorTickValues;
  final String? unit;

  const ValueAxisData._(this.tickPositions, this.majorTickPositions, this.majorTickValues, this.unit);

  factory ValueAxisData.from(final num startValue, final num range, final double axisLength, final String? unit){
    final num trueIntervalCount = max(_majorTickCount + 1, 1);
    num niceInterval = range / trueIntervalCount;
    final num minimumInterval = niceInterval <= 0
        ? 0
        : pow(10, (log(niceInterval) / log10).floor());
    
   for (int i = 0; i < _intervalDivisions.length; i++) {
      final num interval = _intervalDivisions[i];
      final num currentInterval = minimumInterval * interval;
      if (trueIntervalCount < (range / currentInterval)) {
        break;
      }
      niceInterval = currentInterval;
    }
    
    final List<num> majorTickValues = [];

    num i;
    if(startValue <= 0){
      i = (startValue ~/ niceInterval) * niceInterval;
    }
    else{
      i = (startValue ~/ niceInterval + 1) * niceInterval;
    }

    final num tickOffset = (i - startValue - niceInterval) / range * axisLength;
    while(i < startValue + range){
      majorTickValues.add(_roundToDecimalPlaces(i.toDouble(), decimalPrec));
      i += niceInterval;
    }    

    final List<double> majorTickPositions = List.generate(majorTickValues.length, ((index) {
      return _roundToDecimalPlaces((majorTickValues[index] - startValue) / range * axisLength, decimalPrec);
    }));

    late final double tickPosDelta;
    if(majorTickPositions.length >= 2){
      tickPosDelta = (majorTickPositions[1] - majorTickPositions[0]) / (_tickPerMajorTick + 1);
    }
    else if(majorTickPositions.length == 1){
      tickPosDelta = majorTickPositions[0] / (_tickPerMajorTick + 1);
    }
    else{
      tickPosDelta = range / (_tickPerMajorTick + 1);
    }
    
    final List<double> tickPositions = List.generate(axisLength ~/ tickPosDelta - 1, ((index) {
      return _roundToDecimalPlaces((index + 1) * tickPosDelta + tickOffset, decimalPrec);
    }));
    
    while(tickPositions[0] <= 1){
      tickPositions.removeAt(0);
      tickPositions.add(_roundToDecimalPlaces(tickPositions.last + tickPosDelta, decimalPrec));
    }
    
    i = tickPositions.length - 1;
    while(tickPositions[i as int] > axisLength){
      tickPositions.removeAt(i);
      tickPositions.insert(0, _roundToDecimalPlaces(tickPositions.first - tickPosDelta, decimalPrec));
    }
    
    final num baseLine = pow(10, -decimalPrec + 1);
    tickPositions.removeWhere((tick) => majorTickPositions.any((majorTick) => 
      (majorTick - tick).abs() <= baseLine
    ));
    return ValueAxisData._(tickPositions, majorTickPositions, majorTickValues, unit);
  }
}