import 'package:flutter/material.dart';
import 'package:supaeromoon_ground_station/ui/theme.dart';

final GlobalKey<NavigatorState> mainWindowNavigatorKey = GlobalKey<NavigatorState>();

void rebuildAllChildren(BuildContext context) {
  void rebuild(Element el) {
    el.markNeedsBuild();
    el.visitChildren(rebuild);
  }
  (context as Element).visitChildren(rebuild);
}

String representNumber(final num? v, {int targetChar = 10}){
  if(v == null){
    return "";
  }
  String ret = v.toStringAsPrecision(targetChar);
  if(ret.contains('.')){
    while(ret.endsWith('0') && ret.length >= 2){
      ret = ret.substring(0, ret.length - 1);
    }
  }
  if(ret.endsWith('.')){
    ret = ret.substring(0, ret.length - 1);
  }
  return ret;
}

double normalizeInbetween(num value, num min, num max, double minHeight, double maxHeight){
  if(min <= value && value <= max){
    return ((value - min) / (max - min)) * (maxHeight - minHeight) + minHeight;
  }
  else if(value > max){
    return maxHeight;
  }
  else if(value < min){
    return minHeight;
  }
  else{
    return minHeight;
  }
}

class AdvancedTooltip extends StatelessWidget{
  const AdvancedTooltip({super.key, required this.tooltipText, required this.child});

  final String tooltipText;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltipText,
      decoration: BoxDecoration(
        color: ThemeManager.globalStyle.secondaryColor,
        border: Border.all(color: ThemeManager.globalStyle.primaryColor, width: 0),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(7.5), bottomRight: Radius.circular(7.5))
      ),
      textStyle: TextStyle(color: ThemeManager.globalStyle.textColor),
      showDuration: const Duration(milliseconds: 0),
      waitDuration: const Duration(milliseconds: 1000),
      verticalOffset: 10,
      child: child,
    );
  }
}