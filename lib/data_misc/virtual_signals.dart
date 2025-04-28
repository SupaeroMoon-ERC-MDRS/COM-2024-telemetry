// Input: string of c++ like code
//      operators for now: +-*/ with &|^ and ()brackets
//      in future functions like abs() etc
//      allow numeric constants

// Parsing: tokenize -> create op tree based on op precedence and brackets
//      then create gettable input list (not map)

// Exec: give input list to exec that runs bottom up on op tree
//      return value/failresult