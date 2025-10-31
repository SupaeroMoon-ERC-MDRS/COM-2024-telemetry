import 'dart:math';

extension ListExtension<T> on List<T> {
  List<T> sorted(int Function(T a, T b) compare) => [...this]..sort(compare);
}

extension NumHelper on num {
  double roundToDecimalPlaces(int places){ 
    num mod = pow(10, places); 
    return (this * mod).roundToDouble() / mod; 
  }
}