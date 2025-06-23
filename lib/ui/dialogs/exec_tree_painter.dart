import 'dart:math';

import 'package:flutter/material.dart';
import 'package:supaeromoon_ground_station/data_misc/eval/eval.dart';
import 'package:supaeromoon_ground_station/data_misc/eval/tokens.dart';
import 'package:supaeromoon_ground_station/ui/theme.dart';

class ExecTreePainter extends CustomPainter {

  final String expr;

  ExecTreePainter({super.repaint, required this.expr});

  double calulateXPos(final List<bool> pathL, final double horizontalStep){
    int d = 0;
    double pos = 0;
    for(final bool l in pathL){
      pos += l ? - horizontalStep / pow(2, d++) : horizontalStep / pow(2, d++);
    }
    return pos;
  }

  @override
  void paint(Canvas canvas, Size size) {
    ExecTree? tree;
    String? failReason;
    try{
      tree = Evaluator.compile(expr);
    }catch(ex){
      failReason = ex.toString();
    }

    if(failReason != null){
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: failReason,
          style: ThemeManager.subTitleStyle
        ),
        textDirection: TextDirection.ltr
      );
      tp.layout();
      tp.paint(canvas, size.center(Offset.zero) - tp.size.center(Offset.zero));
      return;
    }
    else if(tree == null){
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: "Evaluation failed without a reason, contact GS responsible",
          style: ThemeManager.subTitleStyle
        ),
        textDirection: TextDirection.ltr
      );
      tp.layout();
      tp.paint(canvas, size.center(Offset.zero) - tp.size.center(Offset.zero));
      return;
    }

    final Map<int, int> depthMap = Evaluator.getDepthMap(tree);
    final Map<int, int> remainingDepthMap = Map.of(depthMap);
    final int depth = (depthMap.keys.toList()..sort()).last;

    final double verticalStep = min(100, size.height / (depth + 1));

    ExecTree node = tree;
    final List<ExecTree> path = [];
    int downPos = 0;
    while(true){
      if(node.left != null && node.left!.prec == null){ // go down left
        path.add(node);
        node = node.left!;
        downPos++;

        int slot = 1 + depthMap[downPos - 1]! - remainingDepthMap[downPos - 1]!;
        final Offset a = Offset(slot * size.width / (depthMap[downPos - 1]! + 1), (downPos - 1) * verticalStep);
        slot = 1 + depthMap[downPos]! - remainingDepthMap[downPos]!;
        final Offset b = Offset(slot * size.width / (depthMap[downPos]! + 1), downPos * verticalStep);
        canvas.drawLine(a, b, Paint()..color = ThemeManager.globalStyle.primaryColor);

        continue;
      }
      else if(node.right != null && node.right!.prec == null){ // go down right
        path.add(node);
        node = node.right!;
        downPos++;

        int slot = 1 + depthMap[downPos - 1]! - remainingDepthMap[downPos - 1]!;
        final Offset a = Offset(slot * size.width / (depthMap[downPos - 1]! + 1), (downPos - 1) * verticalStep);
        slot = 1 + depthMap[downPos]! - remainingDepthMap[downPos]!;
        final Offset b = Offset(slot * size.width / (depthMap[downPos]! + 1), downPos * verticalStep);
        canvas.drawLine(a, b, Paint()..color = ThemeManager.globalStyle.primaryColor);
        continue;
      }
      else if(node.left == null && node.right == null && node.prec == null){ // no more left possible
        node.prec = 0;
        final TextPainter tp = TextPainter(
          text: TextSpan(
            text: node.value!.toString(),
            style: ThemeManager.textStyle
          ),
          textDirection: TextDirection.ltr
        );
        tp.layout();

        final int slot = 1 + depthMap[downPos]! - remainingDepthMap[downPos]!;
        remainingDepthMap[downPos] = remainingDepthMap[downPos]! - 1;
        final Offset pos = Offset(slot * size.width / (depthMap[downPos]! + 1), downPos * verticalStep);

        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: pos, width: tp.size.width * 1.5, height: tp.size.height), Radius.circular(ThemeManager.globalStyle.padding)),
          Paint()..style = PaintingStyle.fill..color = ThemeManager.globalStyle.secondaryColor
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: pos, width: tp.size.width * 1.5, height: tp.size.height), Radius.circular(ThemeManager.globalStyle.padding)),
          Paint()..style = PaintingStyle.stroke..color = ThemeManager.globalStyle.primaryColor
        );

        tp.paint(canvas, pos - tp.size.center(Offset.zero));

        node = path.removeLast();
        downPos--;
        continue;
      }
      else if((node.left == null || node.left!.prec != null) && (node.right == null || node.right!.prec != null)){ // no more down possible
        node.prec = 0;
        final TextPainter tp = TextPainter(
          text: TextSpan(
            text: OPERATORS[node.op!.index],
            style: ThemeManager.textStyle
          ),
          textDirection: TextDirection.ltr
        );
        tp.layout();

        final int slot = 1 + depthMap[downPos]! - remainingDepthMap[downPos]!;
        remainingDepthMap[downPos] = remainingDepthMap[downPos]! - 1;
        final Offset pos = Offset(slot * size.width / (depthMap[downPos]! + 1), downPos * verticalStep);

        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: pos, width: tp.size.width * 1.5, height: tp.size.height), Radius.circular(ThemeManager.globalStyle.padding)),
          Paint()..style = PaintingStyle.fill..color = ThemeManager.globalStyle.secondaryColor
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: pos, width: tp.size.width * 1.5, height: tp.size.height), Radius.circular(ThemeManager.globalStyle.padding)),
          Paint()..style = PaintingStyle.stroke..color = ThemeManager.globalStyle.primaryColor
        );

        tp.paint(canvas, pos - tp.size.center(Offset.zero));

        node = path.removeLast();
        downPos--;
        continue;
      }
      else{
        break;
      }
    }
  }

  @override
  bool shouldRepaint(ExecTreePainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(ExecTreePainter oldDelegate) => true;
}