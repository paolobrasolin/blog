---
title: Inverting cotrees
published: true
latex: katex
language: en
katex:
  macros:
    '\id': '\mathrm{id}'
    '\Obj': '\mathrm{Obj}'
    '\Hom': '\mathrm{Hom}'
antex:
  preamble:
    \usepackage{commutative-diagrams}
---


So, yeah inverting trees is bullshit.


```agda
{-# OPTIONS --cubical #-}
```

```agda
data Tree (A : Set) : Set where
  leaf : A → Tree A
  node : Tree A → A → Tree A → Tree A

invert : {A : Set} → Tree A → Tree A
invert (leaf a) = leaf a
invert (node l a r) = node (invert r) a (invert l)

import Relation.Binary.PropositionalEquality as PE

inv²≡id : {A : Set} → (t : Tree A) → invert (invert t) PE.≡ t
inv²≡id (leaf x) = PE.refl
inv²≡id (node l x r) rewrite (inv²≡id l) | (inv²≡id r) = PE.refl
```


```agda
record ∞Tree (A : Set) : Set where
  coinductive
  field
    lhb : ∞Tree A
    apx : A
    rhb : ∞Tree A

open ∞Tree

∞invert : {A : Set} → ∞Tree A → ∞Tree A
lhb (∞invert t) = rhb t
apx (∞invert t) = apx t
rhb (∞invert t) = lhb t

coflipOK' : {A : Set} → (t : ∞Tree A) → ∞invert (∞invert t) PE.≡ t
coflipOK' t = {! :(!}

import Cubical.Core.Everything as HE

∞inv²≡id : {A : Set} → (t : ∞Tree A) → ∞invert (∞invert t) HE.≡ t
lhb (∞inv²≡id t i) = lhb t
apx (∞inv²≡id t i) = apx t
rhb (∞inv²≡id t i) = rhb t


```

```agda

open import Data.Nat using (ℕ; zero; suc; _*_)

truncate : {A : Set} → (n : ℕ) → ∞Tree A → Tree A
truncate zero t = leaf (apx t)
truncate (suc n) t = node (truncate n (lhb t)) (apx t) (truncate n (rhb t))

mapTree : {A B : Set} → (f : A → B) → Tree A → Tree B
mapTree f (leaf x) = leaf (f x)
mapTree f (node l x r) = node (mapTree f l) (f x) (mapTree f r)
```

Is this literate programming actually working? Woah!

```agda
open import Agda.Builtin.Int
open import Data.Rational using (ℚ; normalize; _+_; _-_; ½; show)

diadicsAround : ℚ → ∞Tree ℚ
lhb (diadicsAround q) = diadicsAround (q - normalize 1 (2 * ℚ.denominatorℕ q))
apx (diadicsAround q) = q
rhb (diadicsAround q) = diadicsAround (q + normalize 1 (2 * ℚ.denominatorℕ q))

dyadics : ∞Tree ℚ
dyadics = diadicsAround ½

_ : mapTree show (truncate 3 dyadics) PE.≡
  node (node (node (leaf "1/16" )   -- 0.0001
                         "1/8"      -- 0.0010
                   (leaf "3/16"))   -- 0.0011
                         "1/4"      -- 0.0100
             (node (leaf "5/16")    -- 0.0101
                         "3/8"      -- 0.0110
                   (leaf "7/16")))  -- 0.0111
                         "1/2"      -- 0.1000
       (node (node (leaf "9/16")    -- 0.1001
                         "5/8"      -- 0.1010
                   (leaf "11/16"))  -- 0.1011
                         "3/4"      -- 0.1100
             (node (leaf "13/16")   -- 0.1101
                         "7/8"      -- 0.1110
                   (leaf "15/16"))) -- 0.1111
_ = PE.refl
```



