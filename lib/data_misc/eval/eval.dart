import 'package:supaeromoon_ground_station/data_misc/eval/parser.dart';
import 'package:supaeromoon_ground_station/data_misc/eval/tokens.dart';
import 'package:supaeromoon_ground_station/io/logger.dart';

class ExecTree{
  final ExecTree? left;
  final ExecTree? right;
  final Op? op;
  final dynamic value;
  int? prec;

  ExecTree({required this.left, required this.right, required this.op, required this.value});

  factory ExecTree.empty(){
    return ExecTree(left: null, right: null, op: null, value: null);
  }
}

abstract class Evaluator{
  static ExecTree compile(final String expr){
    try{
      final List<Token> tokens = Tokenizer.tokenize(expr);
      // TODO check that this results in a bool(alarm) or a number(virtualsignal)
      return Parser.parse(tokens);
    }
    catch(ex){
      localLogger.error("Compilation failed", doNoti: false);
      rethrow;
    }
  }

  // only poss to use scalar signals
  /*static T eval<T>(final ExecTree tree, final Map<String, num> values){

  }*/
}

/*void main(){
  final ExecTree t = Evaluator.compile("-10 > ((right_trigger + left_trigger) * (right_trigger + left_trigger))");
}*/