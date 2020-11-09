---
title: Cotrees
published: true
latex: katex
language: en
katex:
---

Let's have some fun with (co)inductive types in AGDA.


Things are going to get spicy -- spoiler warning in this pragma!

```agda
{-# OPTIONS --cubical #-}
open import Data.Nat hiding (_+_)
```




## Lists

```agda
data List (A : Set) : Set where
  []  : List A
  _∷_ : A → List A → List A

infixr 5 _∷_
```


## Streams

```agda
record Stream (A : Set) : Set where
  coinductive
  field
    head : A
    tail : Stream A

open Stream
```


```agda
upto : ℕ → List ℕ
upto zero = []
upto (suc n) =  n ∷ upto n

digits = upto 10
```


```agda
module Foo where
  open import Relation.Binary.PropositionalEquality

  _ : digits ≡ 9 ∷ 8 ∷ 7 ∷ 6 ∷ 5 ∷ 4 ∷ 3 ∷ 2 ∷ 1 ∷ 0 ∷ []
  _ = refl
```


```agda
from : ℕ → Stream ℕ
head (from n) = n
tail (from n) = from (suc n)

naturals = from 0
```

`naturals` normalizes to `from 0`.


```agda
trimStream : {A : Set} → ℕ → Stream A → List A
trimStream zero s = []
trimStream (suc n) s = head s ∷ trimStream n (tail s)

module Bar where
  open import Relation.Binary.PropositionalEquality

  _ : trimStream 5 naturals ≡ 0 ∷ 1 ∷ 2 ∷ 3 ∷ 4 ∷ []
  _ = refl

```




```agda
loopList : {A : Set} → List A → A → Stream A
loopList {A} ls l = loop ls
  where
    loop : List A → Stream A
    head (loop []) = l
    tail (loop []) = loop ls
    head (loop (x ∷ xs)) = x
    tail (loop (x ∷ xs)) = loop xs
```

```agda
module Qux where
  open import Relation.Binary.PropositionalEquality

  _ : trimStream 8 (loopList (upto 3) 3) ≡ 2 ∷ 1 ∷ 0 ∷ 3 ∷ 2 ∷ 1 ∷ 0 ∷ 3 ∷ []
  _ = refl
```


```agda
data Tree (A : Set) : Set where
  leaf : A → Tree A
  node : Tree A → A → Tree A → Tree A
```

```agda
flip : {A : Set} → Tree A → Tree A
flip (leaf a) = leaf a
flip (node l a r) = node (flip r) a (flip l)
```

```agda
module Doo where
  open import Relation.Binary.PropositionalEquality

  flipIsInvolution : {A : Set} → (t : Tree A) → t ≡ flip (flip t)
  flipIsInvolution (leaf x) = refl
  flipIsInvolution (node l x r) rewrite sym (flipIsInvolution l) | sym (flipIsInvolution r) = refl
```

```agda
record Cotree (A : Set) : Set where
  coinductive
  field
    lhb : Cotree A -- Left Hand Branch
    apx : A        -- Apex
    rhb : Cotree A -- Right Hand Branch
open Cotree
```

```agda
coflip : {A : Set} → Cotree A → Cotree A
lhb (coflip t) = rhb t
apx (coflip t) = apx t
rhb (coflip t) = lhb t
```

```agda
module Rex where
  open import Relation.Binary.PropositionalEquality

  coflipIsInvolution' : {A : Set} → (t : Cotree A) → t ≡ coflip (coflip t)
  coflipIsInvolution' t = {!!}
```

```agda
module Lol where
  open import Cubical.Core.Everything
  --open import Cubical.Foundations.Prelude

  coflipOK : {A : Set} → (t : Cotree A) → t ≡ coflip (coflip t)
  lhb (coflipOK t i) = lhb t
  apx (coflipOK t i) = apx t
  rhb (coflipOK t i) = rhb t
```


```agda
trimCotree : {A : Set} → (n : ℕ) → Cotree A → Tree A
trimCotree zero t = leaf (apx t)
trimCotree (suc n) t = node (trimCotree n (lhb t)) (apx t) (trimCotree n (rhb t))
```


```agda
open import Agda.Builtin.Int
open import Data.Rational hiding (_*_)

diadicsAround : ℚ → Cotree ℚ
lhb (diadicsAround q) = diadicsAround (q - normalize 1 (2 * ℚ.denominatorℕ q))
apx (diadicsAround q) = q
rhb (diadicsAround q) = diadicsAround (q + normalize 1 (2 * ℚ.denominatorℕ q))

dyadics : Cotree ℚ
dyadics = diadicsAround ½

open import Data.String hiding (show; _++_)

mapTree : {A B : Set} → (f : A → B) → Tree A → Tree B
mapTree f (leaf x) = leaf (f x)
mapTree f (node l x r) = node (mapTree f l) (f x) (mapTree f r)
```


```agda
module Roo where
  open import Relation.Binary.PropositionalEquality

  _ : mapTree show (trimCotree 3 dyadics) ≡
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
  _ = refl
```



```text
record Tree (A : Set) : Set where
  inductive
  constructor ⟨_,_,_⟩
  field
    lhb : Tree A
    apx : A
    rhb : Tree A
open Tree

flip : {A : Set} → Tree A → Tree A
flip ⟨ l , a , r ⟩ = ⟨ (flip r) , a , (flip l) ⟩
```
