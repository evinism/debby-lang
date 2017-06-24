/*

all whitespace is tokenized equivalently
slashes start comments and are ignored by lexer.

-- rough CFG --
  [statement] one of:
    [import];
    [expression];
    [declaration];
    [export];
    [typeDeclaration];

  // [import] is:
  // import [name] from [stringLiteral]

  // [export]

  [expression] one of:
    ([expression]) //binds infinitely tightly
    [name]
    [expression].[name] //binds rather tightly
    [morph]
    [expression]([name2] [name3]) // binds relatively tightly
    [expression] [infixOperator] [expression] //binds relatively loosely.
    [stringLiteral]
    [numberLiteral]
    [listLiteral]
    let [name] be [expression] in [expression] // binds super tightly

  [list]:
    [ [name] ([expression]) ] // or something like that

  [name]:
    stringOfNameCharacters

  [stringLiteral] one of:
    "stringCharacters"
    'stringCharacters'

  [numberLiteral] one of:
    you know what a number should look like

  [declaration] one of:
    morph [name] = [expression] // but we have to check on compile time whether the expression is actually of type morphism
    list [name] = [expression] // same here
    obs [name] = [expression] // same here
    string [name] = [expression] // same
    num [name] = [expression] // same

  [morph]:
    \ [name1] [name2] -> [expression]

  [typeDeclaration]:
    type [name] [withStatement] [equipsStatement]

  [withStatement] one of:
    [empty string]
    with [name1] [name2] (...)

  [equipsStatement]

*/

%lex
%%

\/\/.*\n        { /* line comment ignore */ }
\/\*.*\*\/      { /*block comment ignore*/ }
\s*\n\s*        { /* ignore */ }
"("\s*          { return 'OPENPAREN'; }
\s*")"          { return 'CLOSEPAREN'; }
"["\s*          { return 'OPENBRACKET'; }
\s*"]"          { return 'CLOSEBRACKET'; }
[a-zA-Z_]+      { return 'NAME'; }
\s*";"          { return 'SEMI'; }
\s+             { return 'SEP' }
<<EOF>>         { return 'EOF'; }

/lex

%%

file
  : stmts EOF
    { return $stmts; }
  ;

stmts
  :
    { $$ = [] }
  | stmt stmts
    {
      $$ = $stmt.type !== 'emptyStatement'
        ? [].concat([$stmt], $stmts)
        : $stmts;
    }
  ;

stmt
  : SEMI
    { $$ = { type: 'emptyStatement' }; }
  | expr SEMI
    { $$ = {
      type: 'expressionStatement',
      expr: $expr
    }; }
  ;

expr
  : name
    { $$ = $name; }
  | parenthetical
    { $$ = $parenthetical }
  | tuple
    { $$ = $tuple }
  | list
  ;


parenthetical
  : OPENPAREN expr CLOSEPAREN
    { $$ = $expr; }
  ;

tuple
  : OPENPAREN subtuple CLOSEPAREN
    { $$ = {type: 'tuple', value: $subtuple}; }
  ;

list
  : OPENBRACKET sublist CLOSEBRACKET
    { $$ = {type: 'list', value: $sublist}; }
  ;

subtuple
  : expr SEP sublist
    { $$ = [$expr].concat( $sublist ); }
  ;

sublist
  : expr
    { $$ = [$expr]; }
  | expr SEP sublist
    { $$ = [$expr].concat( $sublist ); }
  ;

name
  : NAME
    { $$ = {type: 'name', value: $NAME } }
  ;
