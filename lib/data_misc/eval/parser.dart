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
      if(bracketPos[i + 1] - bracketPos[i] == 1 && tokens[i + 1].bracketOpen != tokens[i].bracketOpen){
        localLogger.error("Opening and closing brackets cannot be neighbouring");
        return false;
      }
    }

    if(boCount != bcCount){
      localLogger.error("Opening and closing brackets mismatch");
      return false;
    }
    return true;
  }

  static int _getDepth(final List<Token> tokens, final List<bool> used){
    int d = 0;
    for(int i = 0; i < tokens.length; i++){
      if(tokens[i].bracketOpen && !used[i]){
        d++;
      }
    }
    return d;
  }

  static ExecTree parse(final List<Token> tokens){
    if(!_sanityCheck(tokens)){
      throw Exception();
    }

    /*//final int nonBracketLen = tokens.where((final Token t) => t.isIdent || t.isOp).length;
    final List<bool> used = List.filled(tokens.length, false);
    final List<ExecTree> level = List.filled(tokens.length, ExecTree.empty());

    int depth = _getDepth(tokens, used);
    while(depth > 0){
      late final int sectionBegin;
      late final int sectionEnd;
      final List<Token> section = [];
      final Map<List<int>, int> replaceMap = {};

      int d = 0;
      bool collect = false;
      for(int i = 0; i < tokens.length; i++){
        if(tokens[i].bracketOpen){
          d++;
        }
        else if(tokens[i].bracketClose){
          d--;
        }
        else if(collect){
          section.add(tokens[i]);
        }

        if(tokens[i].bracketOpen && d == depth && !used[i]){
          sectionBegin = i;
          collect = true;
        }
        else if(tokens[i].bracketClose && d == depth - 1 && !used[i]){
          sectionEnd = i;
          break;
        }
      }

      final List<ExecTree> sectionExec = section.map((final Token t) { 
        if(t.isIdent){
          return ExecTree(left: null, right: null, op: null, value: t.ident!);
        } 
        else if(t.isOp){
          return ExecTree(left: null, right: null, op: t.op!, value: null);
        }
        else{
          return ExecTree.empty();
        }
      }).toList();

      final List<bool> sectionUsed = used.sublist(sectionBegin, sectionEnd);

      if(sectionUsed.contains(true)){
        final int inSectionBegin = sectionUsed.indexWhere((element) => true);
        final int inSectionEnd = sectionUsed.lastIndexWhere((element) => true);  
        
        // there could be multiple chunks
        sectionExec.removeRange(inSectionBegin, inSectionEnd + 1);
        sectionExec.insert(inSectionBegin, level[replaceMap.remove([inSectionBegin + sectionBegin, inSectionEnd + sectionEnd])!]);
      }

      while(sectionExec.length > 1){
        int mini = 1;
        int prec = 1e10.toInt();
        for(int i = 1; i < sectionExec.length - 1; i++){
          if(sectionExec[i].op != null && PRECEDENCE[sectionExec[i].op!]! < prec){
            prec = PRECEDENCE[sectionExec[i].op!]!;
            mini = i;
          }
        }

        final ExecTree t = ExecTree(left: sectionExec[mini - 1], right: sectionExec[mini + 1], op: sectionExec[mini].op!, value: null);
        sectionExec.removeRange(mini - 1, mini + 2);
        sectionExec.insert(mini - 1, t);
      }

      // leave tokens alone
      final int levelBegin;
      final int levelEnd;

      level.removeRange(levelBegin, levelEnd + 1);
      replaceMap[[sectionBegin, sectionEnd]] = levelBegin;
      level.insert(levelBegin, sectionExec[0]);

      for(int i = sectionBegin; i < sectionEnd; i++){
        used[i] = true;
      }
    }
    
    while(level.length > 1){
      // ... same as from 117
    }

    return level[0];*/
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

      level.add(ExecTree(left: null, right: null, op: t.op, value: t.ident));
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