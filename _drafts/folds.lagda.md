---
title: foldl vs foldr
published: true
latex: katex
language: en
katex:
---




All left folds are _exactly_ this loop:
```text
λ f z list →
  var r = z
  foreach(a in list)
    f = f(r, a)
  return r
```

Therefore they:
  * have exactly the same properies as the loop
    * will **never** work on infinite list
  * we have easy and familiar intuition




```agda
--{-# OPTIONS --cubical #-}

open import Data.Nat
open import Data.List hiding (foldl; foldr; sum; reverse; length; map; filter)


foldl : {A B : Set} → (f : B → A → B) → B → List A → B
foldl f b [] = b
foldl f b (a ∷ as) = foldl f (f b a) as



sum : List ℕ → ℕ
sum = foldl _+_ 0

prod : List ℕ → ℕ
prod = foldl _*_ 1

reverse : {A : Set} → List A → List A
reverse = foldl (λ xs x → x ∷ xs) []

length : {A : Set} → List A → ℕ
length = foldl (λ n _ → n + 1) 0

```


```agda
foldr : {A B : Set} → (f : A → B → B) → B → List A → B
foldr f b [] = b
foldr f b (a ∷ as) = f a (foldr f b as)
```

`foldr` performs _constructor replacement_. <= this is the right intuition

```agda
open import Relation.Binary.PropositionalEquality

foo : {A : Set} → {list : List A} → foldr _∷_ [] list ≡ list
foo {A} {[]} = refl
foo {A} {x ∷ list} rewrite foo {A} {list} = refl
```


We can also reimplement sum and mult, but
* there is an associativity order
* there is NO execution order
* TRUE: associates to the right
* FALSE: starts execution on the right
* it can work therefore on infinite lists (e.g. folding AND on infinite list of booleans)


```agda
open import Relation.Binary.PropositionalEquality

append : {A : Set} → List A → List A → List A
append xs ys = foldr _∷_ ys xs

map : {A B : Set} → (f : A → B) → List A → List B
map f = foldr (λ x xs → f x ∷ xs) [] -- replaces ∷ with ∷ ∘ f and [] with []

flatten : {A : Set} → List (List A) → List A
flatten = foldr append [] -- replaces ∷ with append and [] with []

open import Data.Bool
filter : {A : Set} → (f : A → Bool) → List A → List A
filter f [] = []
filter f (x ∷ xs) with f x
... | false = filter f xs
... | true = x ∷ filter f xs

headOr : {A : Set} → A → List A → A
headOr h = foldr (λ x _ → x) h

-- OMITTED: sequencing a monad

```


So, `foldr` may work on an infinite list:
* no _order_ is specified, just associativity
* depends on the strictness of the given function (TODO: what's that mean?)
* replaces the `Nil` constructor _if it ever comes to exist_

In fact, `foldr Cons Nil` is the identity!


```agda

foldrId : {A : Set} → ∀ (xs : List A) → foldr _∷_ [] xs ≡ xs
foldrId [] = refl
foldrId (x ∷ xs) rewrite foldrId xs = refl


```





So, we gained a precise intuition (is it just intuition, though?) which needs no footnotes.

```agda
module Rex where
```

```agda
record Stream (A : Set) : Set where
  inductive
  constructor _∷_
  field
    hd : A
    tl : Stream A
open Stream


∞foldl : {A B : Set} → (f : B → A → B) → B → Stream A → B
∞foldl {A} {B} f z (x ∷ xs) = ∞foldl f (f z x) xs

∞foldr : {A B : Set} → (f : A → B → B) → B → Stream A → B
∞foldr {A} {B} f z (x ∷ xs) = f x (∞foldr f z xs)


∞foldrId : {A : Set} → ∀ {zs : Stream A} → ∀ (xs : Stream A) → ∞foldr _∷_ zs xs ≡ xs
∞foldrId {_} {zs} (x ∷ xs) rewrite ∞foldrId {_} {zs} xs = refl

--module Lol where
  --open import Cubical.Core.Everything
  --open import Cubical.Foundations.Prelude


```


```agda
record Colist (A : Set) : Set where
  --coinductive
  field
    Nil : Colist A
    cons : A → Colist A → Colist A
open Colist


cfoldl : {A B : Set} → (f : B → A → B) → B → Colist A → B
--∞foldl {A} {B} f z (x ∷ xs) = ∞foldl f (f z x) xs

cfoldr : {A B : Set} → (f : A → B → B) → B → Colist A → B
--∞foldr {A} {B} f z (x ∷ xs) = f x (∞foldr f z xs)


--cfoldrId : {A : Set} → ∀ {zs : Stream A} → ∀ (xs : Stream A) → ∞foldr _∷_ zs xs ≡ xs
--∞foldrId {_} {zs} (x ∷ xs) rewrite ∞foldrId {_} {zs} xs = refl

--module Lol where
--open import Cubical.Core.Everything
--open import Cubical.Foundations.Prelude


```




An Intuition for List Folds by Tony Morris #FnConf19
https://www.youtube.com/watch?v=t9pxo7L8mS0

