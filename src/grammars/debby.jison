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

\/\/.*\n          { /* line comment ignore */ }
\/\*.*\*\/        { /*block comment ignore, would be better in custom lexer */ }
"type"            { return 'TYPE'; }
"over"            { return 'OVER'; }
"equips"          { return 'EQUIPS'; }
"import"          { return 'IMPORT'; }
"export"          { return 'EXPORT'; }
"from"            { return 'FROM'; }
\".*\"            { return 'STRINGLIT'; }
\'.*\'            { return 'STRINGLIT'; }
[0-9]+(\.[0-9]*)? { return 'NUMBERLIT'; }
[a-zA-Z_]+        { return 'NAME'; }
"->"              { return 'RIGHTARROW' }
"("               { return 'OPENPAREN'; }
")"               { return 'CLOSEPAREN'; }
"["               { return 'OPENBRACKET'; }
"]"               { return 'CLOSEBRACKET'; }
"="               { return 'ASSIGN'; }
":"               { return 'COLON'; }
";"               { return 'SEMI'; }
","               { return 'COMMA'; }
"."               { return 'DOT'; }
"\\"              { return 'BACKSLASH'; }
<<EOF>>           { return 'EOF'; }
\s+               { /* ignore whitespace after everything else has been matched */ }

/lex

%%

/* --- Top Level Grammar --- */

/* TODO: introduce symbol table */

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
  | expr SEMI /* Expression Statement */
    { $$ = {
      type: 'expressionStatement',
      expr: $expr
    }; }
  | typedec SEMI
    { $$ = $typedec; }
  | assignstmt SEMI
    { $$ = $assignstmt }
  | import SEMI
    { $$ = $import; }
  | export SEMI
    { $$ = $export; }
  ;

/* --- Type Declarations --- */

typedec
  : TYPE NAME OVER namelist equipsclause
    { $$ = {
      type: 'typeStatement',
      name: $NAME,
      over: $namelist,
      equips: $equipsclause
    }; }
  ;

equipsclause
  :
  | EQUIPS maplist
    { $$ = $maplist }
  ;

maplist
  : mapitem
    { $$ = [$mapitem]; }
  | mapitem COMMA maplist
    { $$ = [$mapitem].concat($maplist); }
  ;

mapitem
  : NAME COLON expr
    { $$ = {
      type: "mapItem",
      key: $NAME,
      value: $expr
    }; }
  ;

/* --- Imports / Exports --- */

import
  : IMPORT namelist FROM stringlit
    { $$ = {
      type: "importStatement",
      source: $stringlit.value,
      items: $namelist,
    }; }
  ;

export
  : EXPORT namelist
    { $$ = {
      type: "importStatement",
      items: $namelist,
    }; }
  ;

/* --- Assignment --- */

assignstmt
  : NAME NAME ASSIGN expr
    { $$ = {
      type: 'assignStatement',
      vartype: $1,
      name: $2,
      value: $expr
    }; }
  ;

/* --- Expressions --- */


expr
  : applicativeexpr
    { $$ = $applicativeexpr; }
  | morph
    { $$ = $morph; }
  ;

/* This hacks around operator precedence of applying functions */
applicativeexpr
  : name
    { $$ = $name; }
  | parenthetical
    { $$ = $parenthetical }
  | tuple
    { $$ = $tuple }
  | list
    { $$ = $list }
  | stringlit
    { $$ = $stringlit }
  | numberlit
    { $$ = $numberlit }
  | application
    { $$ = $application }
  | dotexp
    { $$ = $dotexp }
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
  : OPENBRACKET exprlist CLOSEBRACKET
    { $$ = {type: 'list', value: $exprlist}; }
  ;

subtuple
  : expr COMMA exprlist
    { $$ = [$expr].concat( $exprlist ); }
  ;

exprlist
  :
    { $$ = []; }
  | expr
    { $$ = [$expr]; }
  | expr COMMA exprlist
    { $$ = [$expr].concat( $exprlist ); }
  ;

morph
  : BACKSLASH namelist RIGHTARROW expr
    { $$ = {
      type: 'morph',
      params: $namelist,
      body: $expr,
    }; }
  ;

application
  : applicativeexpr OPENPAREN exprlist CLOSEPAREN
    { $$ = {
      type: 'application',
      left: $applicativeexpr,
      right: $exprlist
    }}
  ;

dotexp
  : applicativeexpr DOT name
    { $$ = {
      type: 'dot',
      source: $applicativeexpr,
      value: $name
    }; }
  ;


/* --- Literals --- */

stringlit
  : STRINGLIT
    { $$ = {
      type: 'stringLiteral',
      value: $STRINGLIT.slice(1, -1)
    }; }
  ;

numberlit
  : NUMBERLIT
    { $$ = {
      type: 'numberLiteral',
      value: parseFloat($NUMBERLIT)
    }; }
  ;

/* --- Shared --- */

name
  : NAME
    { $$ = {type: 'name', value: $NAME } }
  ;

namelist
  : NAME
    { $$ = [$NAME]; }
  | NAME COMMA namelist
    { $$ = [$NAME].concat($namelist); }
  ;
