---
title: Left fold vs. right fold
published: true
latex: katex
language: en
katex:
---

What's the difference between a right fold and a left fold on a list?
It has been said and written an inordinate amount of times, so one more won't hurt... Right?

Note that this article is literate Agda: you can load and execute its [sourcecode]({{site.github.blobs_url}}/{{page.path}}).

```agda
open import Function
open import Relation.Binary.PropositionalEquality
open Relation.Binary.PropositionalEquality.≡-Reasoning
```

## First contact

First of all, let's refresh the definitions:

```agda
open import Data.List hiding (foldl; foldr)

variable
  A B : Set

foldl : (f : B → A → B) → B → List A → B
foldl f b [] = b
foldl f b (a ∷ as) = foldl f (f b a) as

foldr : (f : A → B → B) → B → List A → B
foldr f b [] = b
foldr f b (a ∷ as) = f a (foldr f b as)
```

I'll pull two rabbits out of the hat and state that each fold can be expressed in terms of the other:

```agda
foldl-as-foldr : (f : B → A → B) (b : B) (as : List A)
  → foldl f b as ≡ foldr (λ α ϕ β -> ϕ (f β α)) id as b

foldr-as-foldl : (f : A → B → B) (b : B) (as : List A)
  → foldr f b as ≡ foldl (λ ϕ α β -> ϕ (f α β)) id as b
```

Let's ignore the two weird lambdas for now and prove the statements instead.

The proof of `foldl-as-foldr` is a straightforward case splitting.
The only interesting part is the necessity for a `ploy`:

```agda
foldl-as-foldr f b [] =
  begin
    foldl f b []     ≡⟨⟩ -- by def. of foldl
    b                ≡⟨⟩
    id b             ≡⟨⟩ -- by def. of foldr
    foldr Λ id [] b
  ∎
  where Λ = λ α ϕ β → ϕ (f β α)

foldl-as-foldr f b (a ∷ as) =
  begin
    foldl f b (a ∷ as)        ≡⟨⟩ -- by def. of foldl
    foldl f (f b a) as        ≡⟨ foldl-as-foldr f (f b a) as ⟩
    foldr Λ id as (f b a)     ≡⟨⟩ -- by def. of Λ
    foldr Λ id as (Λ a id b)  ≡⟨ cong-app (ploy {a} {as}) b ⟩
    Λ a (foldr Λ id as) b     ≡⟨⟩ -- by def. of foldr
    foldr Λ id (a ∷ as) b
  ∎
  where
    Λ = λ α ϕ β → ϕ (f β α)
    ploy : ∀ {a as} → (foldr Λ id as) ∘ (Λ a id) ≡ Λ a (foldr Λ id as)
    ploy = refl
```

The proof of `foldr-as-foldl` is structurally identical to the previous one.
Only the necessity for a slightly generalized `ploy` catches the eye:

```agda

foldr-as-foldl f b [] =
  begin
    foldr f b []     ≡⟨⟩ -- by def. of foldr
    b                ≡⟨⟩
    id b             ≡⟨⟩ -- by def. of foldl
    foldl Λ id [] b
  ∎
  where
    Λ = λ ϕ α β -> ϕ (f α β)

foldr-as-foldl f b (a ∷ as) =
  begin
    foldr f b (a ∷ as)        ≡⟨⟩ -- by def. of foldr
    f a (foldr f b as)        ≡⟨ cong (f a) (foldr-as-foldl f b as) ⟩
    f a (foldl Λ id as b)     ≡⟨⟩ -- by def. of Λ
    Λ id a (foldl Λ id as b)  ≡⟨ cong-app (ploy {a} {as} {id}) b ⟩
    foldl Λ (Λ id a) as b     ≡⟨⟩ -- by def. of foldl
    foldl Λ id (a ∷ as) b
  ∎
  where
    Λ = λ ϕ α β -> ϕ (f α β)
    -- Strictly speaking, in the reasoning above we just need
    --   ∀ {a as} → (Λ id a) ∘ (foldl Λ id as) ≡ foldl Λ (Λ id a) as
    -- but that's not enough to prove itself. We need a generalization:
    ploy : ∀ {a as p} → (Λ p a) ∘ (foldl Λ id as) ≡ foldl Λ (Λ p a) as
    ploy {a} {[]} {p} = refl
    ploy {a} {x ∷ as} {p} =
      begin
        Λ p a ∘ foldl Λ id (x ∷ as)     ≡⟨⟩ -- by def. of foldl
        Λ p a ∘ foldl Λ (Λ id x) as     ≡⟨ cong (Λ p a ∘_) (sym (ploy {x} {as} {id})) ⟩
        Λ p a ∘ Λ id x ∘ foldl Λ id as  ≡⟨⟩ -- by def. of Λ
        Λ (Λ p a) x ∘ foldl Λ id as     ≡⟨ ploy {x} {as} {Λ p a} ⟩
        foldl Λ (Λ (Λ p a) x) as        ≡⟨⟩ -- by def. of foldl
        foldl Λ (Λ p a) (x ∷ as)
      ∎
```

Great: nothing stated so far is false!

I appreciate the symmetry, but I still feel like I have no hint of understanding.




## Second contact

What were those two weird lambdas?

We can rewrite them as combinators

```agda
Λᴿ : (B → A → B) → A → (B → B) → B → B
Λᴿ f = λ α ϕ β -> ϕ (f β α)

Λᴸ : (A → B → B) → (B → B) → A → B → B
Λᴸ f = λ ϕ α β -> ϕ (f α β)
```

and rephrase the fold equivalences more succintly

```agda
foldl-as-foldr' : (f : B → A → B) → foldl f ≡ flip (foldr (Λᴿ f) id)
foldr-as-foldl' : (f : A → B → B) → foldr f ≡ flip (foldl (Λᴸ f) id)
```

We're not gonna bother proving them again, though.

Let's fiddle with concrete examples instead:

```agda
fiddleᴿ : ∀ (f : B → A → B) (a b c : A) (z : B)
  → foldl f z (a ∷ b ∷ c ∷ []) ≡ foldr (Λᴿ f) id (a ∷ b ∷ c ∷ []) z
fiddleᴿ f a b c z =
  begin
    foldl f z (a ∷ b ∷ c ∷ [])    ≡⟨⟩ -- Expanding the definition of foldl, we get
    f (f (f z a) b) c             ≡⟨⟩ -- the full call tree of f. Then we write it as
    (fᶠ c ∘ fᶠ b ∘ fᶠ a) z        ≡⟨⟩ -- a chain of compositions. Since fᶠ x ≡ Λ x id
    (Λ c id ∘ Λ b id ∘ Λ a id) z  ≡⟨⟩ -- we rewrite the chain in terms of Λ,
    Λ a (Λ b (Λ c id)) z          ≡⟨⟩ -- which absorbs precomposition, exposing the chain
    foldr Λ id (a ∷ b ∷ c ∷ []) z ≡⟨⟩ -- as a right fold applied to z.
    ((z fⁱ a) fⁱ b) fⁱ c              -- Fun fact: left fold is "left associative".
  ∎
  where
    fᶠ = flip f
    Λ = Λᴿ f
    _fⁱ_ = f

fiddleᴸ : ∀ (f : A → B → B) (a b c : A) (z : B)
  → foldr f z (a ∷ b ∷ c ∷ []) ≡ foldl (Λᴸ f) id (a ∷ b ∷ c ∷ []) z
fiddleᴸ f a b c z =
  begin
    foldr f z (a ∷ b ∷ c ∷ [])    ≡⟨⟩ -- Expanding the definition of foldr, we get
    f a (f b (f c z))             ≡⟨⟩ -- the full call tree of f. Then we write it as
    (f a ∘ f b ∘ f c) z           ≡⟨⟩ -- a chain of compositions. Since f x ≡ Λ id x
    (Λ id a ∘ Λ id b ∘ Λ id c) z  ≡⟨⟩ -- we rewrite the chain in terms of Λ,
    Λ (Λ (Λ id a) b) c z          ≡⟨⟩ -- which absorbs precomposition, exposing the chain
    foldl Λ id (a ∷ b ∷ c ∷ []) z ≡⟨⟩ -- as a left fold applied to z.
    a fⁱ (b fⁱ (c fⁱ z))              -- Fun fact: right fold is "right associative".
  ∎
  where
    Λ = Λᴸ f
    _fⁱ_ = f
```

This should clarify why the combinators are working:
switching from `f` to `Λ` reverses the order of list items in the call tree,
allowing an expression in terms of the opposite fold.

While the _precomposition absorption_ property is trivial

```agda
_ : ∀ {f : B → A → B} {p a} → (Λᴿ f) a p ≡ p ∘ ((Λᴿ f) a id)
_ = refl

_ : ∀ {f : A → B → B} {p a} → (Λᴸ f) p a ≡ p ∘ ((Λᴸ f) id a)
_ = refl
```

the _composition chain as a fold_ is not, in the general case.
In fact, that's exactly what our `ploy`s come into play.
Let's restate them:

```agda
ployᴿ : ∀ {f : B → A → B} {a as}
  → (foldr (Λᴿ f) id as) ∘ ((Λᴿ f) a id) ≡ (Λᴿ f) a (foldr (Λᴿ f) id as)

ployᴸ : ∀ {f : A → B → B} {a as}
  → ((Λᴸ f) id a) ∘ (foldl (Λᴸ f) id as) ≡ foldl (Λᴸ f) ((Λᴸ f) id a) as
```

Only one of the two is trivial:

```agda
ployᴿ = refl

ployᴸ {A} {B} {f} {a} {as} = ployᴸ⁺ {f} {a} {as} {id}
  where
    ployᴸ⁺ : ∀ {f : A → B → B} {a as p}
      → ((Λᴸ f) p a) ∘ (foldl (Λᴸ f) id as) ≡ foldl (Λᴸ f) ((Λᴸ f) p a) as
    ployᴸ⁺ {f} {a} {[]} {p} = refl
    ployᴸ⁺ {f} {a} {x ∷ as} {p} =
      begin
        Λ p a ∘ foldl Λ id (x ∷ as)     ≡⟨⟩ -- by def. of foldl
        Λ p a ∘ foldl Λ (Λ id x) as     ≡⟨ cong (Λ p a ∘_) (sym (ployᴸ⁺ {f} {x} {as} {id})) ⟩
        Λ p a ∘ Λ id x ∘ foldl Λ id as  ≡⟨⟩ -- by def. of Λ
        Λ (Λ p a) x ∘ foldl Λ id as     ≡⟨ ployᴸ⁺ {f} {x} {as} {Λ p a} ⟩
        foldl Λ (Λ (Λ p a) x) as        ≡⟨⟩ -- by def. of foldl
        foldl Λ (Λ p a) (x ∷ as)
      ∎
      where Λ = Λᴸ f
```













## Universality of foldr
## Righting a left fold

https://willamette.edu/~fruehr/haskell/evolution.html
(leaned so far right he came back left again!)
fac n = foldr (\x g n -> g (x*n)) id [1..n] 1


## Lefting a right fold

Blah[^Mor19]
How do you implement `foldl` using `foldr`?


First of all, we need a static argument transformation on the definition of `foldl`:

```agda
foldlᵗ : (f : B → A → B) → B → List A → B
foldlᵗ {B} {A} f b l = auxˡ l b
  where
    auxˡ : List A → B → B
    auxˡ []       b = b
    auxˡ (x ∷ xs) b = auxˡ xs (f b x)

foldrᵗ : (f : A → B → B) → B → List A → B
foldrᵗ {A} {B} f b l = auxʳ l b
  where
    auxʳ : List A → B → B
    auxʳ []       b = b
    auxʳ (x ∷ xs) b = f x (auxʳ xs b)
```

Then we notice we can use the univerality of `foldr` on `aux`.
However we need to fiddle a little bit to find out how.

```agda
module FiddleAroundR where
  postulate
    f : B → A → B

  aux : List A → B → B
  aux []       = id
  aux (x ∷ xs) = λ b → aux xs (f b x)

  tau : ∀ {A B : Set} (x : A) (xs : List A) → aux (x ∷ xs) ≡ aux (x ∷ xs)
  tau {A} {B} = λ x xs → begin
    aux (x ∷ xs)                                ≡⟨⟩
    (λ β → aux (x ∷ xs) β)                      ≡⟨⟩
    (λ β → aux xs (f β x))                      ≡⟨⟩
    (λ α β → (aux xs) (f β α)) x                ≡⟨⟩
    (λ α (ϕ : B → B) β → ϕ (f β α)) x (aux xs)  ≡⟨⟩
    (Λᴿ f) x (aux xs)  ∎
    -- Λᴿ f = λ α ϕ β -> ϕ (f β α)

module FiddleAroundL where
  postulate
    f : A → B → B

  aux : List A → B → B
  aux []       = id
  aux (x ∷ xs) = λ b → f x (aux xs b)

  tau : ∀ {A B : Set} (x : A) (xs : List A) → aux (x ∷ xs) ≡ aux (x ∷ xs)
  tau {A} {B} = λ x xs → begin
    aux (x ∷ xs)                                ≡⟨⟩
    (λ β → aux (x ∷ xs) β)                      ≡⟨⟩
    -- (λ β → f x (aux xs β))                      ≡⟨⟩
    -- (λ α (β : B) → f α (aux xs β)) x                  ≡⟨⟩
    -- (λ ϕ α β → f α (ϕ β)) (aux xs) x            ≡⟨⟩
    (Λᴸ f) (aux xs) x                           ∎
    -- Λᴸ f = λ ϕ α β -> ϕ (f α β)
```


Awesome!



Continuation passing!







All left folds are _exactly_ this loop:
```text
f(f(f(f(z,a),b),c),d)

λ f z list →
  var r = z
  foreach(a in list)
    r = f(r, a)
  return r
```

Therefore they:
  * have exactly the same properies as the loop
    * will **never** work on infinite list
  * we have easy and familiar intuition


What about a right fold?
```text
f(a,f(b,f(c,f(d,z))))

λ f z list →
  var g
  foreach(a in list)
    g = λ x → f(a,x)
  return r
```


```agda
--{-# OPTIONS --cubical #-}

open import Data.Nat



-- g = foldl f v
-- g [] = v
-- g (x ∷ xs) = ???


--sum : List ℕ → ℕ
--sum = foldl _+_ 0


```


`foldr` performs _constructor replacement_. <= this is the right intuition

```text
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

-- map : {A B : Set} → (f : A → B) → List A → List B
-- map f = foldr (λ x xs → f x ∷ xs) [] -- replaces ∷ with ∷ ∘ f and [] with []

flatten : {A : Set} → List (List A) → List A
flatten = foldr append [] -- replaces ∷ with append and [] with []

open import Data.Bool
-- filter : {A : Set} → (f : A → Bool) → List A → List A
-- filter f [] = []
-- filter f (x ∷ xs) with f x
-- ... | false = filter f xs
-- ... | true = x ∷ filter f xs

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
foldrId : ∀ {as : List A} → foldr _∷_ [] as ≡ id as
foldrId {A} {[]} = refl
foldrId {A} {x ∷ as} rewrite foldrId {A} {as} = refl
```





So, we gained a precise intuition (is it just intuition, though?) which needs no footnotes.

```agda
module Rex where
```

```text
--record Stream (A : Set) : Set where
--  inductive
--  constructor _∷_
--  field
--    hd : A
--    tl : Stream A
--open Stream


--∞foldl : {A B : Set} → (f : B → A → B) → B → Stream A → B
--∞foldl {A} {B} f z (x ∷ xs) = ∞foldl f (f z x) xs
--
--∞foldr : {A B : Set} → (f : A → B → B) → B → Stream A → B
--∞foldr {A} {B} f z (x ∷ xs) = f x (∞foldr f z xs)


∞foldrId : {A : Set} → ∀ {zs : Stream A} → ∀ (xs : Stream A) → ∞foldr _∷_ zs xs ≡ xs
∞foldrId {_} {zs} (x ∷ xs) rewrite ∞foldrId {_} {zs} xs = refl

--module Lol where
  --open import Cubical.Core.Everything
  --open import Cubical.Foundations.Prelude


```



```text
record Colist (A : Set) : Set where
  coinductive
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




universality of foldr

```text
foldr : {A B : Set} → (f : A → B → B) → B → List A → B
foldr f b [] = b
foldr f b (a ∷ as) = f a (foldr f b as)
```

```agda
import Relation.Binary.PropositionalEquality as PE
open PE.≡-Reasoning
```

```agda
open import Data.Product using (_×_; proj₁; proj₂; _,_)

runiversality₁ : ∀ {g : List A → B} {f : A → B → B} {v : B}
  → (g [] ≡ v) × (∀ {x : A} {xs : List A} → (g (x ∷ xs) ≡ f x (g xs)))
  --------------------------------------------------------------------
  → ∀ (l : List A) → g l ≡ foldr f v l

runiversality₁ ( p₀ , _ ) [] = p₀

runiversality₁ {_} {_} {g} {f} {v} ( p₀ , pᵢ ) (y ∷ ys) = begin
  g (y ∷ ys)          ≡⟨ pᵢ ⟩
  f y (g ys)          ≡⟨ cong (f y) (runiversality₁ {_} {_} {g} {f} {v} ( p₀ , pᵢ ) ys) ⟩
  f y (foldr f v ys)  ∎

runiversality₂ : ∀ {g : List A → B} {f : A → B → B} {v : B}
  → (∀ (l : List A) → g l ≡ foldr f v l)
  --------------------------------------------------------------------
  → (g [] ≡ v) × (∀ {x : A} {xs : List A} → (g (x ∷ xs) ≡ f x (g xs)))

proj₁ (runiversality₂ {_} {_} {g} {f} {v} p) = begin
  g []          ≡⟨ p [] ⟩
  foldr f v []  ≡⟨⟩
  v             ∎

proj₂ (runiversality₂ {_} {_} {g} {f} {v} p) {x} {xs} = begin
  g (x ∷ xs)          ≡⟨ p (x ∷ xs) ⟩
  foldr f v (x ∷ xs)  ≡⟨⟩
  f x (foldr f v xs)  ≡⟨ cong (f x) (sym (p xs)) ⟩
  f x (g xs)          ∎


luniversality₁ : ∀ {g : List A → B} {f : B → A → B} {v : B}
  → (g [] ≡ v) × (∀ {x : A} {xs : List A} → (g (x ∷ xs) ≡ f x (g xs)))
  --------------------------------------------------------------------
  → ∀ (l : List A) → g l ≡ foldl f v l

```

```text
open import Data.Nat
open import Data.Nat.Properties
open import Function

-- sum : List ℕ → ℕ
-- sum [] = 0
-- sum (n ∷ ns) = n + sum ns

-- (+1) · sum = fold (+) 1

module Booyah where
  -- let's name thing to make stuff more readable
  f = _+_
  g = (_+ 1) ∘ sum
  v = 1

  p₀ : g [] ≡ v
  p₀ = begin
    sum [] + 1  ≡⟨⟩
    0 + 1       ≡⟨⟩
    1           ∎

  pₙ : (∀ {n : ℕ} {ns : List ℕ} → (g (n ∷ ns) ≡ f n (g ns)))
  pₙ {n} {ns} = begin
    (sum (n ∷ ns)) + 1  ≡⟨⟩
    (n + sum ns) + 1    ≡⟨ +-assoc n (sum ns) 1 ⟩
    n + (sum ns + 1)    ∎

  _ : ∀ (l : List ℕ) → g l ≡ (foldr f v) l
  _ = universality₁ ( p₀ , pₙ )

```

```text
fusion : ∀ {g : A → B → B} {h : B → B}
           {w : B} {f : A → B → B} {v : B}
  → (h w ≡ v) × (∀ {x : A} {y : B} → (h (g x y) ≡ f x (h y)))
  ----------------------------------------
  → ∀ (l : List A) → (h ∘ foldr g w) l ≡ foldr f v l

fusion {_} {_} {g} {h} {w} {f} {v} ( p₀ , pᵢ ) [] = begin
  (h ∘ foldr g w) []  ≡⟨⟩
  h (foldr g w [])    ≡⟨⟩
  h w                 ≡⟨ p₀ ⟩
  v                   ∎

fusion {_} {_} {g} {h} {w} {f} {v} ( p₀ , pᵢ ) (x ∷ xs) = begin
  (h ∘ foldr g w) (x ∷ xs)  ≡⟨⟩
  h (foldr g w (x ∷ xs))    ≡⟨⟩
  h (g x (foldr g w xs))    ≡⟨ pᵢ ⟩
  f x (h (foldr g w xs))    ≡⟨ cong (f x) (fusion {_} {_} {g} {h} (p₀ , pᵢ) xs) ⟩
  f x (foldr f v xs)        ≡⟨⟩
  foldr f v (x ∷ xs)        ∎
```

```text
module Bagonghi where
  h = (_+ 1)
  g = _+_
  w = 0

  f = _+_
  v = 1

  p₀ : h w ≡ v
  p₀ = begin
    0 + 1  ≡⟨⟩
    1      ∎

  pᵢ : ∀ {x : ℕ} {y : ℕ} → (h (g x y) ≡ f x (h y))
  pᵢ {x} {y} = begin
    (x + y) + 1  ≡⟨ +-assoc x y 1 ⟩
    x + (y + 1)  ∎

  _ : ∀ (ns : List ℕ) → (h ∘ foldr g w) ns ≡ foldr f v ns
  _ = fusion {_} {_} {g} {h} {w} {f} {v} (p₀ , pᵢ)
```



## Primitive recursion





```text
module ThatsIt where
  postulate
    f' : ∀ {A B : Set} → B → A → B

  aux : ∀ {A B : Set} → List A → B → B
  aux []       = id
  aux (x ∷ xs) = λ b → aux xs (f' b x)

  -- (λ α (β : B → B) γ → β (f' γ α)) x (aux xs)  ∎
  -- f x (aux xs)
  -- let's name thing to make stuff more readable
  g = aux

  f : ∀ {A B : Set} → A → (B → B) → B → B
  f = (λ b g x → g (f' x b))
  v = id

  --foldr (\b g x -> g (f x b)) id bs a

  p₀ : ∀ {A B : Set} → g {A} {B} [] ≡ v
  p₀ = refl

  pₙ : ∀ {A B : Set} → (∀ {x : A} {xs : List A} → (g {A} {B} (x ∷ xs) ≡ f x (g xs)))
  pₙ {A} {B} {x} {xs} = begin
    aux (x ∷ xs) ≡⟨ {!!} ⟩
    f x (aux xs) ∎

  goo : ∀ (l : List A) → g {A} {B} l ≡ (foldr f v) l
  goo {A} {B} = universality₁ ( p₀ {A} {B} , pₙ {A} {B} )

```





[^Mor19]: Tony Morris, [_An Intuition for List Folds_](https://www.youtube.com/watch?v=t9pxo7L8mS0), 2019.
[^Hut99]: Graham Hutton, [_A tutorial on the universality and expressiveness of fold_](http://www.cs.nott.ac.uk/~pszgmh/fold.pdf), 1999.
[^Mei00]: Erik Meijer, Maarten Fokkinga and Ross Paterson, [_Functional Programming with Bananas, Lenses, Envelopes and Barbed Wire_](https://maartenfokkinga.github.io/utwente/mmf91m.pdf), 2000.


SUPER IMPORTANTE

http://neilsculthorpe.com/publications/workIt-extended.pdf


SUPER COOL
http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.45.2247&rep=rep1&type=pdf


BUON PIANO
https://jeremykun.com/2013/09/30/the-universal-properties-of-map-fold-and-filter/
>  I do believe that with some extra work we could use universal properties to give a trivial proof of the third homomorphism theorem for lists, which says that any function expressible as both a foldr and a foldl can be expressed as a list homomorphism. The proof would involve formulating a universal property for foldl, which is very similar to the one for foldr, and attaching the diagrams in a clever way to give the universal property of a monoid homomorphism for lists. Caveat emptor: this author has not written such a proof, but it seems likely that it would work.

mostly useful
https://wiki.haskell.org/Foldl_as_foldr



