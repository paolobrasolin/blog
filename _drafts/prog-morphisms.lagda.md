---
title: weird morphisms
published: true
latex: katex
language: en
katex:
---








```agda

open import Data.Nat
open import Data.List hiding (foldl; foldr; sum; reverse; length; map; filter)

foldr : {A B : Set} → (f : A → B → B) → B → List A → B
foldr f b [] = b
foldr f b (a ∷ as) = f a (foldr f b as)

```









http://okmij.org/ftp/Haskell/AlgorithmsH1.html#foldl



https://stackoverflow.com/questions/14699334/recursion-schemes-in-agda


https://blog.sumtypeofway.com/posts/introduction-to-recursion-schemes.html
https://blog.sumtypeofway.com/posts/recursion-schemes-part-2.html
https://blog.sumtypeofway.com/posts/recursion-schemes-part-3.html
https://blog.sumtypeofway.com/posts/recursion-schemes-part-4.html
https://blog.sumtypeofway.com/posts/recursion-schemes-part-4-point-5.html
https://blog.sumtypeofway.com/posts/recursion-schemes-part-5.html
https://blog.sumtypeofway.com/posts/recursion-schemes-part-6.html

https://maartenfokkinga.github.io/utwente/mmf91m.pdf

generality increases in vertical
dual pairs are horizontal


| IA -> A                    | C -> FC  | ?                 |                   |   |
|----------------------------|----------|-------------------|-------------------|---|
| fold                       | (unfold) | ?                 | ?                 |   |
| cata "iteration"           | ana      | cata ∘ ana = hylo | ana ∘ cata = meta |   |
| para "primitive recursion" | apo      | ?                 | ?                 |   |
| histo "strong induction"   | futu     | (k) ?             | ?                 |   |
| dyna                       |          |                   |                   |   |
| chrono                     |          |                   |                   |   |

(k): http://comonad.com/reader/2008/generalized-hylomorphisms/

histo/futu/chrono: http://comonad.com/reader/2008/time-for-chronomorphisms/
  > While a histomorphism is a generalized catamorphism parameterized by the cofree comonad of your functor, a futumorphism is a generalized anamorphism parameterized by the free monad of your functor.

http://comonad.com/reader/2008/dynamorphisms-as-chronomorphisms/
  > In case it wasn't obvious, I thought I should mention that Kabanov and Vene's dynamorphisms which optimize histomorphisms for dynamic programming can be expressed readily as chronomorphisms; they just use an anamorphism instead of a futumorphism.

histo/dyna
  http://citeseerx.ist.psu.edu/viewdoc/download;jsessionid=BA4CCC586864C57099F3D7092439228C?doi=10.1.1.416.2381&rep=rep1&type=pdf


hierarchy: https://stackoverflow.com/a/24895262/6438061
cata: generalizes fold to arbitrary algebraic data types (which can be described as initial algebras)
para: generalizes cata giving the step function access to the original subobject (along with the recursively computed subobject)
histo: generalizes pata maintaining full history of partial "right folds"
dyna: generalizes histo by allowing operating on any type you can build a coalgebra for, not just foldable ones


First two columns are categorical duals.



https://stackoverflow.com/questions/13317242/what-are-paramorphisms

chronomorphisms is rewrite dynamorphisms! You can read more about dynamorphisms here https://stackoverflow.com/a/46698107/6438061
https://stackoverflow.com/a/36911924/6438061

Histomorphism models dynamic programming, the technique of tabulating the results of previous subcomputations https://en.wikipedia.org/wiki/Mathematical_induction#Complete_induction

https://stackoverflow.com/a/37002861/6438061

zygomorphism has a big sister called mutumorphism, which captures mutual recursion in all its glory. mutu generalises zygo in that both the folding functions are allowed to inspect the other's result from the previous iteration.

https://stackoverflow.com/a/36911924/6438061

https://stackoverflow.com/questions/36851766/histomorphisms-zygomorphisms-and-futumorphisms-specialised-to-lists



dynamorphisms ??? http://citeseerx.ist.psu.edu/viewdoc/download;jsessionid=BA4CCC586864C57099F3D7092439228C?doi=10.1.1.416.2381&rep=rep1&type=pdf


Catamorphism:
  * from the Greek: κατά "downwards" and μορφή "form, shape"
  * denotes the unique homomorphism from an initial algebra into some other algebra
  * One writes a function which recursively replaces the constructors of the datatype with provided functions, and any constant values of the type with provided values
  * generalizes folds on lists to arbitrary algebraic datatypes

Anamorphism:
  * In computer programming, an anamorphism is a function that generates a sequence by repeated application of the function to its previous result
  * You begin with some value A and apply a function f to it to get B. Then you apply f to B to get C, and so on until some terminating condition is reached. The anamorphism is the function that generates the list of A, B, C, etc. You can think of the anamorphism as unfolding the initial value into a sequence.
  * the anamorphism of a coinductive type denotes the assignment of a coalgebra to its unique morphism to the final coalgebra of an endofunctor
  * In functional programming, an anamorphism is a generalization of the concept of unfolds on coinductive lists. Formally, anamorphisms are generic functions that can corecursively construct a result of a certain type and which is parameterized by functions that determine the next single step of the construction.

Paramorphism:
  * paramorphism (from Greek παρά, meaning "close together")
  * categorical dual of an apomorphism
  ? extension of the concept of catamorphism (induction)
  * models primitive recursion over an inductive data type
  --
  * It is a more convenient version of catamorphism in that it gives the combining step function immediate access not only to the result value recursively computed from each recursive subobject, but the original subobject itself as well.
  * is an extension of the concept of catamorphism first introduced by Lambert Meertens [1] to deal with a form which “eats its argument and keeps it too”,[2][3] as exemplified by the factorial function

Apomorphism:
  * apomorphism (from ἀπό — Greek for "apart")
  * categorical dual of a paramorphism
  * extension of the concept of anamorphism (coinduction)
  * models primitive corecursion over a coinductive data type



Hylomorphism:
  * recursive function, corresponding to the composition of
    - an anamorphism (which first builds a set of results; also known as 'unfolding') followed by
    - a catamorphism (which then folds these results into a final return value)
  * Fusion of these two recursive computations into a single recursive pattern then avoids building the intermediate data structure.



