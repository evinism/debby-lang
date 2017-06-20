# Debby: a toy language

```
// Toy language 1:
// debby
// Forces you to define your program in terms of observables
//  keeping it fairly minimal

[] defines Lists
(5 4) defines tuples

import Events EventTypes SendTypes from "system";
import blah1 blah2 from "./[path]";

// currying is disabled by default
// no free variables.
morph blah = \arg1 arg2 arg3 -> if (expr) else (otherExp);
morph blah = \arg1 arg2 -> arg1 && arg2;
morph still = \arg1 arg2 -> arg1 + arg2;

// we can define static data from within the closure.
list a = [];

//

add(5 6); // function calls

// your program must export a 'Main' observable
export Main;

// type declarations are roughly algebraic
// TODO: reduce type specific syntax.
type Rockable with internalType internalType equips (
  blah: [morph], // should have no free variables (but can access item1, item2)
  blah2: [morph]
);

// [1, 2, 3, 4] != [1, 2, 3, 4]
// list a = [1, 2, 3, 4];
// a == a;
// lists compare their pointers
// Since immutable, this is a sufficient condition for arrays to be exactly equivalent.


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


other general notes:
  all data is immutable (aka calling things makes new things);

  types define what methods values have, for example
  * morphisms have:
    - pipe
    ...uhhh
  * lists have:
    - map
    - filter
    - reduce (where you reduce down to a 1-length array)
    - flatten (for that monadic cred)
    ... and probably a few others.
  * observables have:
    - takeLatest
    - concatAll
    - mergeAll
    ... etc

  So when you do ([expr]).value, you're getting the morphism defined for that particular type.
  When you do morph func = ([expr]).value, func keeps lexical env of the old object.
  so morph oneThruTen = [1 2 3 4 5 6 7 8 9 10].map keeps the reference back to the orig array.
  and so cannot get GC'd

*/

```
