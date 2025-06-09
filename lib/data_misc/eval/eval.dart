import 'package:supaeromoon_ground_station/data_misc/eval/parser.dart';
import 'package:supaeromoon_ground_station/data_misc/eval/tokens.dart';
import 'package:supaeromoon_ground_station/data_storage/data_storage.dart';
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
  static ExecTree compile<T>(final String expr){
    try{
      final List<Token> tokens = Tokenizer.tokenize(expr);
      final ExecTree exec = Parser.parse(tokens);
      if(T is bool && !BOOLRES[exec.op]!){
        localLogger.error("Expression does not resolve to bool", doNoti: false);
        throw Exception();
      }
      else if(T is num && BOOLRES[exec.op]!){
        localLogger.error("Expression does not resolve to num", doNoti: false);
        throw Exception();
      }
      else if(!_validityChecks(exec)){
        localLogger.error("Expression has invalid operations", doNoti: false);
        throw Exception();
      }
      return exec;
    }
    catch(ex){
      localLogger.error("Compilation failed", doNoti: false);
      rethrow;
    }
  }

  static bool _typeVisitor(final ExecTree node){
    final bool ltype;
    final bool rtype;

    if(node.left == null || node.right == null || node.op == null){
      return true;
    }

    if(node.left!.op != null){
      ltype = BOOLRES[node.left!.op]!;
    }
    else{
      ltype = node.left!.value! is bool;
    }
    if(node.right!.op != null){
      rtype = BOOLRES[node.right!.op]!;
    }
    else{
      rtype = node.right!.value! is bool;
    }

    final bool valid = NUMIN[node.op]! && !ltype && !rtype || BOOLIN[node.op]! && ltype && rtype;
    if(!valid){
      localLogger.error("Operation ${OPERATORS[node.op!.index]} had lhs of ${ltype ? 'bool' : 'num'} and rhs ${rtype ? 'bool' : 'num'}", doNoti: false);
    }
    return valid;
  }

  static dynamic _execVisitor(final Op op, final dynamic left, final dynamic right){
    switch(op){
      case Op.ADD:
        return left + right;
      case Op.SUB:
        return left - right;
      case Op.MUL:
        return left * right;
      case Op.DIV:
        return left / right;
      case Op.IDIV:
        return left ~/ right;
      case Op.MOD:
        return left % right;
      case Op.XOR:
        return left ^ right;
      case Op.EQ:
        return left == right;
      case Op.NEQ:
        return left != right;
      case Op.LT:
        return left < right;
      case Op.MT:
        return left > right;
      case Op.LEQ:
        return left <= right;
      case Op.MEQ:
        return left >= right;
      case Op.AND:
        return left && right;
      case Op.OR:
        return left || right;
      case Op.BAND:
        return left & right;
      case Op.BOR:
        return left | right;
    }
  }

  static bool _traverse(final ExecTree node, final bool Function(ExecTree) visit){
    if(node.left != null){
      if(!_traverse(node.left!, visit)){
        return false;
      }
    }
    if(node.right != null){
      if(!_traverse(node.right!, visit)){
        return false;
      }
    }

    return visit(node);
  }

  static dynamic _traverseReturn(final ExecTree node, final dynamic Function(Op, dynamic, dynamic) visit){
    final dynamic left;
    final dynamic right;
    
    if(node.left != null && node.right != null){
      left = _traverseReturn(node.left!, visit);
      right = _traverseReturn(node.right!, visit);
    }
    else{
      if(node.value is String){
        return DataStorage.storage[node.value]!.vt.lastOrNull!.value;
      }
      else{
        return node.value;
      }
    }

    return visit(node.op!, left, right);
  }

  static bool _validityChecks(final ExecTree exec){
    return _traverse(exec, _typeVisitor);    
  }

  static T eval<T>(final ExecTree exec){
    return _traverseReturn(exec, _execVisitor) as T;
  }

  static List<String> requiredSignals(final ExecTree exec){
    final Set<String> signals = {};

    signalVisitor(final ExecTree node){
      if(node.value is String){
        signals.add(node.value);
      }
      return true;
    }

    _traverse(exec, signalVisitor);
    return signals.toList();
  }
}

/*void main(){
  final ExecTree t = Evaluator.compile<bool>("-10 > ((-5 + 15) * (5 + 10))");
  final bool res = Evaluator.eval<bool>(t);
}*/