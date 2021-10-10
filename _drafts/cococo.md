



function
  * block of executable code
  * one point of entry
  * somehow returns value

subroutine
  * block of executable code
  * one point of entry
  * does not return value

coroutine
  * block of executable code
  * one point of entry
  * returns ???
  * can yield (and that's interesting)
    * awesome example https://stackoverflow.com/a/26226835/6438061
  * one or more points of re-entry
  * Coroutines are simply concurrent subroutines(functions, methods,closures) that are non preemptive.That is they cannot be interrupted,instead coroutines have multiple points thoughout which allows multiple points of suspension or scope reentry.

continuation
  * is an abstract representation of the control state of a computer program. A continuation implements (reifies) the program control state, i.e. the continuation is a data structure that represents the computational process at a given point in the process's execution
  * basically the functional version of GOTO
  * is an abstract representation of the control state of a computer program. A continuation implements (reifies) the program control state, i.e. the continuation is a data structure that represents the computational process at a given point in the process's execution


delimited continuation (composable, partial)
  * is a "slice" of a continuation frame that has been reified into a function
  * Unlike regular continuations, delimited continuations return a value, and thus may be reused and composed








