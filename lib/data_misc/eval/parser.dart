import 'package:supaeromoon_ground_station/data_misc/eval/eval.dart';
import 'package:supaeromoon_ground_station/data_misc/eval/tokens.dart';
import 'package:supaeromoon_ground_station/data_storage/data_storage.dart';
import 'package:supaeromoon_ground_station/io/logger.dart';

abstract class Parser{
  static bool _sanityCheck(final List<Token> tokens){
    int boCount = 0;
    int bcCount = 0;
    for(final Token token in tokens){
      if(token.bracketOpen) boCount++;
      if(token.bracketClose) bcCount++;

      if(token.isIdent){
        final bool isSig = DataStorage.storage.containsKey(token.ident!);
        final bool isConst = num.tryParse(token.ident!) != null;
        final bool isBool = ["false", "true"].contains(token.ident!);
        if(!(isSig || isConst || isBool)){
          localLogger.error("Identifier ${token.ident} is neither a signal or a constant");
          return false;
        }
      }
    }
    final List<int> bracketPos = tokens.indexed
      .where((element) => element.$2.bracketOpen || element.$2.bracketClose)
      .map((e) => e.$1).toList();
    for(int i = 0; i < bracketPos.length - 1; i++){
      if((bracketPos[i + 1] - bracketPos[i]) == 1 && tokens[bracketPos[i + 1]].bracketOpen != tokens[bracketPos[i]].bracketOpen){
        localLogger.error("Opening and closing brackets cannot be neighbouring");
        return false;
      }
    }

    if(tokens.first.isOp || tokens.last.isOp){
      localLogger.error("Cannot start or finish with operator");
      return false;
    }

    for(int i = 0; i < tokens.length - 1; i++){
      if(tokens[i].isOp && tokens[i + 1].bracketClose){
        localLogger.error("Operator cannot be followed by closing bracket");
      }
    }

    if(boCount != bcCount){
      localLogger.error("Opening and closing brackets mismatch");
      return false;
    }
    return true;
  }

  static ExecTree parse(final List<Token> tokens){
    if(!_sanityCheck(tokens)){
      throw Exception();
    }

    final List<ExecTree> level = [];
    int precLevel = 0;
    for(final Token t in tokens){
      if(t.bracketOpen){
        precLevel -= 100;
        continue;
      }
      else if(t.bracketClose){
        precLevel += 100;
        continue;
      }

      final dynamic value;
      if(t.isIdent){
        num? maybeNum = num.tryParse(t.ident!);
        if(DataStorage.storage.containsKey(t.ident!)){
          value = t.ident!;
        }
        else if(maybeNum != null){
          value = maybeNum;
        }
        else if(["false", "true"].contains(t.ident!)){
          value = t.ident == "false" ? false : true;
        }
        else{ // this in theory cannot happen just to make the compiler happy :)
          value = null;
        }
      }
      else{
        value = null;
      }

      level.add(ExecTree(left: null, right: null, op: t.op, value: value));
      if(t.isOp){
        level.last.prec = precLevel + PRECEDENCE[level.last.op!]!;
      }
    }
    
    while(level.length > 1){
      int mini = 1;
      int prec = 1e10.toInt();
      for(int i = 1; i < level.length - 1; i++){
        if(level[i].op != null && level[i].left == null && level[i].prec! < prec){
          prec = level[i].prec!;
          mini = i;
        }
      }

      final ExecTree t = ExecTree(left: level[mini - 1], right: level[mini + 1], op: level[mini].op!, value: null);
      level.removeRange(mini - 1, mini + 2);
      level.insert(mini - 1, t);
    }

    return level[0];
  }
}