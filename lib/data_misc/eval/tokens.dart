import 'package:supaeromoon_ground_station/data_source/database.dart';
import 'package:supaeromoon_ground_station/data_storage/data_storage.dart';
import 'package:supaeromoon_ground_station/io/logger.dart';

enum Op{
  // ignore: constant_identifier_names
  ADD,
  // ignore: constant_identifier_names
  SUB,
  // ignore: constant_identifier_names
  MUL,
  // ignore: constant_identifier_names
  DIV,
  // ignore: constant_identifier_names
  IDIV,
  // ignore: constant_identifier_names
  MOD,
  // ignore: constant_identifier_names
  XOR,
  // ignore: constant_identifier_names
  EQ,
  // ignore: constant_identifier_names
  NEQ,
  // ignore: constant_identifier_names
  LT,
  // ignore: constant_identifier_names
  MT,
  // ignore: constant_identifier_names
  LEQ,
  // ignore: constant_identifier_names
  MEQ,
  // ignore: constant_identifier_names
  AND,
  // ignore: constant_identifier_names
  OR,
  // ignore: constant_identifier_names
  BAND,
  // ignore: constant_identifier_names
  BOR,
}

// https://en.cppreference.com/w/cpp/language/operator_precedence
const Map<Op, int> PRECEDENCE = {
  Op.ADD : 6,
  Op.SUB : 6,
  Op.MUL : 5,
  Op.DIV : 5,
  Op.IDIV : 5,
  Op.MOD : 5,
  Op.XOR : 12,
  Op.EQ : 10,
  Op.NEQ : 10,
  Op.LT : 9,
  Op.MT : 9,
  Op.LEQ : 9,
  Op.MEQ : 9,
  Op.AND : 14,
  Op.OR : 15,
  Op.BAND : 11,
  Op.BOR : 13,
};

// ignore: constant_identifier_names
const List<String> OPERATORS = [
    '+',
    '-',
    '*',
    '/',
    '~/',
    '%',
    '^',
    '==',
    '!=',
    '<',
    '>',
    '<=',
    '>=',
    '&&',
    '||',
    '&',
    '|',
];
const String forbiddenChars = "+-*/~%^=!<>&|";

class Token{
  final String? ident;
  final Op? op;
  final bool bracketOpen;
  final bool bracketClose;

  const Token._({required this.ident, required this.op, required this.bracketOpen, required this.bracketClose});

  factory Token.op(final Op op){
    return Token._(ident: null, op: op, bracketOpen: false, bracketClose: false);
  }

  factory Token.ident(final String ident){
    return Token._(ident: ident, op: null, bracketOpen: false, bracketClose: false);
  }

  factory Token.bracketOpen(){
    return const Token._(ident: null, op: null, bracketOpen: true, bracketClose: false);
  }

  factory Token.bracketClose(){
    return const Token._(ident: null, op: null, bracketOpen: false, bracketClose: true);
  }

  bool get isOp => op != null;
  bool get isIdent => ident != null;
}

abstract class Tokenizer{
  static List<Token> tokenize(final String str){
    final List<Token> res = [];
    String symbol = "";
    bool readingIdent = true;
    final CharBuf buf = CharBuf(str: str);

    int pos = 0;
    while(pos < str.length){
      buf.seekg(pos);
      final String char = buf.peek();

      if(char == '(' || char == ')'){
        if(readingIdent && symbol.trim().isNotEmpty){
          res.add(Token.ident(symbol.trim()));
        }
        else if(!readingIdent && symbol.trim().isNotEmpty){
          final String opString = symbol.trim();
          try{
            res.add(Token.op(Op.values[OPERATORS.indexWhere((op) => op == opString)]));
          }
          catch(ex){
            localLogger.error("Operator $opString not recognized");
            rethrow;
          }
        }
        symbol = "";
        res.add(char == '(' ? Token.bracketOpen() : Token.bracketClose());
        pos++;
        continue;
      }

      if(forbiddenChars.contains(char)){
        if(readingIdent && symbol.trim().isNotEmpty){
          res.add(Token.ident(symbol.trim()));
          symbol = "";
        }
        symbol += char;
        readingIdent = false;
      }
      else{
        if(!readingIdent && symbol.trim().isNotEmpty){
          final String opString = symbol.trim();
          try{
            res.add(Token.op(Op.values[OPERATORS.indexWhere((op) => op == opString)]));
          }
          catch(ex){
            localLogger.error("Operator $opString not recognized");
            rethrow;
          }
          symbol = "";
        }
        symbol += char;
        readingIdent = true;
      }

      pos++;
    }

    if(readingIdent && symbol.trim().isNotEmpty){
      res.add(Token.ident(symbol.trim()));
    }
    else if(!readingIdent && symbol.trim().isNotEmpty){
      final String opString = symbol.trim();
      try{
        res.add(Token.op(Op.values.firstWhere((op) => op.name == opString)));
      }
      catch(ex){
        localLogger.error("Operator $opString not recognized");
        rethrow;
      }
    }

    // Postprocess to fix unary operators
    if(res.first.isOp == [Op.ADD, Op.SUB].contains(res.first.op)){
      if(res[1].isIdent){  
        res[1] = Token.ident(OPERATORS[res.first.op!.index] + res[1].ident!);
        res.removeAt(0);
      }
      else if(res[1].bracketOpen){
        res[0] = Token.op(Op.MUL);
        res.insert(0, Token.ident("-1"));
      }
      else{
        localLogger.error("Syntax error at the start of the expression");
        throw Exception();    
      }
    }

    int i = 1;
    while(i < res.length - 1){
      if(res[i].isOp && [Op.ADD, Op.SUB].contains(res[i].op)){
        if((res[i - 1].isOp || res[i - 1].bracketOpen) && res[i + 1].isIdent){
          if(num.tryParse(res[i + 1].ident!) != null){
            res[i + 1] = Token.ident(OPERATORS[res[i].op!.index] + res[i + 1].ident!);
            res.removeAt(i);
          }
          else if(DataStorage.storage.containsKey(res[i + 1].ident!)){
            res[i] = Token.op(Op.MUL);
            res.insert(i, Token.ident("-1"));
            i++;
          }
        }
        else if((res[i - 1].isOp || res[i - 1].bracketOpen) && res[i + 1].bracketOpen){
          res[i] = Token.op(Op.MUL);
          res.insert(i, Token.ident("-1"));
          i++;
        }
      }
      i++;
    }

    return res;
  }
}