# Debby: a toy language

```
// Toy language 1:
// debby
// Forces you to define your program in terms of observables
//  keeping it fairly minimal

[] defines Lists
(5, 4) defines tuples

import Events EventTypes SendTypes from "system";
import blah1, blah2 from "./[path]";

// currying is disabled by default
// no free variables.
morph blah = \arg1, arg2 arg3 -> if (expr) else (otherExp);
morph blah = \arg1, arg2 -> arg1 && arg2;
morph still = \arg1, arg2 -> arg1 + arg2;

// we can define static data from within the closure.
list a = [];

//

add(5, 6); // function calls

// your program must export a 'Main' observable
export Main;

// type declarations are roughly algebraic
// TODO: reduce type specific syntax.
type Rockable with internalType internalType2 equips (
  blah: [morph], // should have no free variables (but can access item1, item2)
  blah2: [morph]
);


// [1, 2, 3, 4] != [1, 2, 3, 4]
// list a = [1, 2, 3, 4];
// a == a;
// lists compare their pointers
// Since immutable, this is a sufficient condition for arrays to be exactly equivalent.


/*

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
  so morph oneThruTen = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map keeps the reference back to the orig array.
  and so cannot get GC'd

*/

```
