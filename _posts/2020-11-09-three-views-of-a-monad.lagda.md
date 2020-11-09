---
title: Three views of a monad
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


I once tried ~~proving~~ convincing myself of the equivalence of different implementations of a monad using Haskell and pseudocode.
It was unconvincing and extremely tedious, so I gave up pretty soon.
Now that I have some AGDA under my belt I can have some sweet revenge.

Shout out to [Fosco](https://twitter.com/ququ7) for helping me iron out a few kinks in the proofs.

Note that this article is literate AGDA: you can load and execute its [sourcecode]({{site.github.blobs_url}}/{{page.path}}).

```agda
open import Function
open import Relation.Binary.PropositionalEquality
open Relation.Binary.PropositionalEquality.≡-Reasoning
```




## Mathematicians' monads

First things first, what's a monad to a mathematician?

A **monad** $\langle M,\eta,\mu\rangle$ in a category $C$ is a functor $M\:C\to C$ together with two natural transformations, the unit $\eta\:\id_C\to M$ and the multiplication $\mu\:M^2\to M$, such that the diagrams expressing associativity and unit laws commute:

{% tex classes: [antex, display] %}
\begin{codi}
  \obj (S) { M^3 & M^2 \\ M^2 & M \\ };
  \mor M^3 M\mu:-> S-1-2 \mu:-> M;
  \mor[swap] * {\mu M}:-> S-2-1 \mu:-> *;
\end{codi}
\qquad
\begin{codi}
  \obj (S) { M & M^2 \\ M^2 & M \\ };
  \mor S-1-1 M\eta:-> S-1-2 \mu:-> S-2-2;
  \mor[swap] * {\eta M}:-> S-2-1 \mu:-> *;
  \mor:[double, double distance=.2em] * - *;
\end{codi}
{% endtex %}

This definition is exhaustive but a little terse.
We need to implement it, so let's unpack it a little bit.

$M\:C\to C$ needs to be a functor, which means that:
* it maps each object $X$ in $C$ to an object $M(X)$ in $C$;
* it maps each morphism $f\:X\to Y$ in $C$ to a morphism $M(f)\:M(X)\to M(Y)$ in $C$;
* it preserves identities, i.e. $M(\id_X)=\id_{M(X)}$ for every object $X$ in $C$;
* it preserves composition, i.e. $M(f\circ g)=M(f)\circ M(g)$ for every pair of composable morphisms $f$, $g$ in $C$.

$\eta:\id_C\to M$ needs to be a natural transformation, which means that:
* it maps each object $X$ in $C$ to a morpism $\eta_X\:\id_C(X)\to M(X)$;
* $\eta_Y\circ f=M(f)\circ\eta_X$ for every morphism $f\:X\to Y$ in $C$.

$\mu:M^2\to M$ needs to be a natural transformation, which means that:
* it maps each object $X$ in $C$ to a morpism $\mu_X\:M(M(X))\to M(X)$;
* $\mu_Y\circ M(M(f))=M(f)\circ\mu_X$ for every morphism $f\:X\to Y$ in $C$.

The commutative diagrams expressing associativity and unit laws can be redrawn making the customary notation for natural transformations explicit:

{% tex classes: [antex, display] %}
\begin{codi}[tetragonal=base 9em height 4em]
  \obj (S) { M(M(M(X))) & M(M(X)) \\ M(M(X)) & M(X) \\ };
  \mor S-1-1 M(\mu_X):-> S-1-2 \mu:-> S-2-2;
  \mor[swap] * {\mu_{M(X)}}:-> S-2-1 \mu_X:-> *;
\end{codi}
\qquad
\begin{codi}[tetragonal=base 7em height 4em]
  \obj (S) { M(X) & M(M(X)) \\ M(M(X)) & M(X) \\ };
  \mor S-1-1 M(\eta_X):-> S-1-2 \mu_X:-> S-2-2;
  \mor[swap] * {\eta_{M(X)}}:-> S-2-1 \mu_X:-> *;
  \mor:[double, double distance=.2em] * - *;
\end{codi}
{% endtex %}

for every object $X$ in $C$.
Translating diagrams into equations,
* $\mu_X\circ M(\mu_X)=\mu_X\circ\mu_{M(X)}$ for every object $X$ in $C$;
* $\mu_X\circ M(\eta_X)=\id_{M(X)}$ for every object $X$ in $C$;
* $\mu_X\circ \eta_{M(X)}=\id_{M(X)}$ for every object $X$ in $C$.

Everything is unpacked now and we just need to transcribe it into an AGDA type.
In the code $\mu$, $\eta$ and the action of $M$ on morphisms will be named `mult`, `unit` and `fmap`, respectively.
Here's the result:

```agda
record MathMon (M : Set → Set) : Set₁ where
  field
    fmap : {A B : Set} → (A → B) → M A → M B
    unit : {A : Set} → A → M A
    mult : {A : Set} → M (M A) → M A
    -- functoriality
    fun-idty : ∀ {A : Set} → fmap {A} id ≡ id
    fun-comp : ∀ {A B C : Set} {f : B → C} {g : A → B} → fmap (f ∘ g) ≡ (fmap f) ∘ (fmap g)
    -- naturality
    nat-unit : ∀ {A B : Set} {f : A → B} → (fmap f) ∘ unit ≡ unit ∘ f
    nat-mult : ∀ {A B : Set} {f : A → B} → (fmap f) ∘ mult ≡ mult ∘ fmap (fmap f)
    -- monadicity
    unitˡ : ∀ {A : Set} → mult {A} ∘ unit ≡ id
    unitʳ : ∀ {A : Set} → mult {A} ∘ fmap unit ≡ id
    assoc : ∀ {A : Set} → mult {A} ∘ fmap mult ≡ mult ∘ mult
```




## Programmers' monads

Programmers tipically use a terser definition of monad.

To an Haskeller, a monad is simply this type class:

```haskell
class Monad m where
  return :: a -> m a
  (>>=) :: m a -> (a -> m b) -> m b -- pronounced "bind"
```

The programmer must also ensure that the following properties expressed in pseudocode hold for any `Monad` instance she implements:

```haskell
return x >>= f = f x                      -- left unit
m >>= return = m                          -- right unit
(m >>= f) >>= g = m >>= (\x -> f x >>= g) -- associativity
```

These properties are related to the monad laws we have seen before.

We have all we need to define an AGDA type for the programmers' definition of a monad:

```agda
record ProgMon (M : Set → Set) : Set₁ where
  field
    return : {A : Set} → A -> M A
    _>>=_ : {A B : Set} → M A → (A → M B) -> M B
    -- monadicity
    unitˡ : ∀ {A B : Set} {x : A} {f : A → M B}
      → (return x) >>= f ≡ f x
    unitʳ : ∀ {A : Set} {m : M A}
      → m >>= return ≡ m
    assoc : ∀ {A B C : Set} {m : M A} {f : A → M B} {g : B → M C}
      → (m >>= f) >>= g ≡ m >>= λ{x → f x >>= g}
```




## Mathematicians VS programmers

We expect the two definitions to be equivalent.

To prove that we can build a `ProgMon` from a `MathMon` and vice versa, we need to know how to relate `return` and `>>=` with `fmap`, `unit` and `mult`.

By either reading around or trying to fill holes in AGDA you'll find out:

```haskell
-- return and >>= can be expressed using fmap, unit and mult as follows:
return x = unit x
x >>= f = mult (fmap f x)
-- fmap, unit and mult can be expressed using return and >>= as follows:
fmap f x = x >>= (return . f)
unit x = return x
mult x = x >>= id
```

Knowing this we can start writing a proof.

```agda
MathMon→ProgMon : {M : Set → Set} → MathMon M → ProgMon M
MathMon→ProgMon {M}
  record
    { fmap = fmap
    ; unit = unit
    ; mult = mult
    ; fun-comp = fun-comp
    ; fun-idty = _
    ; nat-unit = nat-unit
    ; nat-mult = nat-mult
    ; unitʳ = unitʳ
    ; unitˡ = unitˡ
    ; assoc = assoc
    }
  =
  record
    { return = unit
    ; _>>=_ = _>>=_
    ; unitˡ = λ {_} {_} {x} {f} →
      begin
        (unit x) >>= f          ≡⟨⟩
        mult (fmap f (unit x))  ≡⟨ cong mult (cong-app nat-unit x) ⟩
        mult (unit (f x))       ≡⟨⟩
        (mult ∘ unit) (f x)     ≡⟨ cong-app unitˡ (f x) ⟩
        id (f x)                ≡⟨⟩
        f x
      ∎
    ; unitʳ = λ {_} {m} →
      begin
        m >>= unit            ≡⟨⟩
        mult (fmap unit m)    ≡⟨⟩
        (mult ∘ fmap unit) m  ≡⟨ cong-app unitʳ m ⟩
        id m                  ≡⟨⟩
        m
      ∎
    ; assoc = λ {_} {_} {_} {m} {f} {g} →
      begin
        ((m >>= f) >>= g)                         ≡⟨⟩
        (mult (fmap f m)) >>= g                   ≡⟨⟩
        mult (fmap g (mult (fmap f m)))           ≡⟨⟩
        (mult ∘ fmap g ∘ mult ∘ fmap f) m         ≡⟨ cong mult (cong-app nat-mult (fmap f m)) ⟩
        (mult ∘ mult ∘ fmap (fmap g) ∘ fmap f) m  ≡⟨ cong (mult ∘ mult) (cong-app (sym fun-comp) m) ⟩
        (mult ∘ mult ∘ fmap (fmap g ∘ f)) m       ≡⟨ cong-app (cong (λ{h → h ∘ fmap (fmap g ∘ f)}) (sym assoc)) m ⟩
        (mult ∘ fmap mult ∘ fmap (fmap g ∘ f)) m  ≡⟨ cong mult (cong-app (sym fun-comp) m) ⟩
        (mult ∘ fmap (mult ∘ fmap g ∘ f)) m       ≡⟨⟩
        m >>= (mult ∘ fmap g ∘ f)                 ≡⟨⟩
        m >>= (λ{ x → (mult ∘ fmap g ∘ f) x })    ≡⟨⟩
        m >>= (λ{ x → f x >>= g })
      ∎
    }
    where
      _>>=_ : {A B : Set} → M A → (A → M B) -> M B
      _>>=_ x f = mult (fmap f x)
```


To prove the reverse implication we need to postulate extensionality, but that's okay.

```agda
postulate
  ext : ∀ {A B : Set} {f g : A → B}
    → (∀ {x : A} → f x ≡ g x)
    → f ≡ g
```

This is a bit longer, so brace yourself.

```agda
ProgMon→MathMon : {M : Set → Set} → ProgMon M → MathMon M
ProgMon→MathMon {M}
  record
    { return = return
    ; _>>=_ = _>>=_
    ; unitˡ = unitˡ
    ; unitʳ = unitʳ
    ; assoc = assoc
    }
  =
  record
    { fmap = fmap
    ; unit = return
    ; mult = mult
    ; fun-comp = λ {_} {_} {_} {f} {g} →
      begin
        fmap (f ∘ g)                                           ≡⟨⟩
        (λ x → fmap (f ∘ g) x)                                 ≡⟨⟩
        (λ x → x >>= (return ∘ (f ∘ g)))                       ≡⟨⟩
        (λ x → x >>= (λ y → (return ∘ f ∘ g) y))               ≡⟨ ext (λ {x} → cong (_>>=_ x) (ext (sym unitˡ))) ⟩
        (λ x → x >>= (λ y → (return ∘ g) y >>= (return ∘ f)))  ≡⟨ ext (sym assoc) ⟩
        (λ x → ((x >>= (return ∘ g)) >>= (return ∘ f)))        ≡⟨⟩
        (λ x → (fmap f) (x >>= (return ∘ g)))                  ≡⟨⟩
        (λ x → (fmap f ∘ fmap g) x)                            ≡⟨⟩
        fmap f ∘ fmap g
      ∎
    ; fun-idty =
      begin
        fmap id                      ≡⟨⟩
        (λ x → (fmap id) x)          ≡⟨⟩
        (λ x → x >>= (return ∘ id))  ≡⟨⟩
        (λ x → x >>= return)         ≡⟨⟩
        (λ x → (id x) >>= return)    ≡⟨ ext unitʳ ⟩
        (λ x → id x)                 ≡⟨⟩
        id
      ∎
    ; nat-unit = λ {_} {_} {f} →
      begin
        fmap f ∘ unit                      ≡⟨⟩
        (λ x → (fmap f ∘ return) x)        ≡⟨⟩
        (λ x → return x >>= (return ∘ f))  ≡⟨ ext unitˡ ⟩
        (λ x → (return ∘ f) x)             ≡⟨⟩
        unit ∘ f
      ∎
    ; nat-mult = λ {_} {_} {f} →
      begin
        fmap f ∘ mult                                         ≡⟨⟩
        (λ x → (fmap f ∘ mult) x)                             ≡⟨⟩
        (λ x → (mult x) >>= (return ∘ f))                     ≡⟨⟩
        (λ x → (x >>= id) >>= (return ∘ f))                   ≡⟨ ext assoc ⟩
        (λ x → x >>= (λ y → id y >>= (return ∘ f)))           ≡⟨⟩
        (λ x → x >>= (λ y → y >>= (return ∘ f)))              ≡⟨⟩
        (λ x → x >>= (λ y → fmap f y))                        ≡⟨⟩
        (λ x → x >>= (λ y → (id ∘ (fmap f)) y))               ≡⟨ ext (λ {x} → cong (_>>=_ x) (ext (sym unitˡ))) ⟩
        (λ x → x >>= (λ y → ((return ∘ (fmap f)) y) >>= id))  ≡⟨ ext (sym assoc) ⟩
        (λ x → (x >>= (return ∘ (fmap f))) >>= id)            ≡⟨⟩
        (λ x → (fmap (fmap f) x) >>= id)                      ≡⟨⟩
        (λ x → (mult ∘ fmap (fmap f)) x)                      ≡⟨⟩
        mult ∘ fmap (fmap f)
      ∎
    ; unitʳ =
      begin
        mult ∘ fmap unit                                ≡⟨⟩
        (λ x → (mult ∘ fmap return) x)                  ≡⟨⟩
        (λ x → fmap return x >>= id)                    ≡⟨⟩
        (λ x → (x >>= (return ∘ return)) >>= id)        ≡⟨ ext assoc ⟩
        (λ x → x >>= (λ y → return (return y) >>= id))  ≡⟨ ext (λ {x} → cong (_>>=_ x) (ext unitˡ)) ⟩
        (λ x → x >>= (λ y → return y))                  ≡⟨⟩
        (λ x → x >>= return)                            ≡⟨ ext unitʳ ⟩
        (λ x → id x)                                    ≡⟨⟩
        id
      ∎
    ; unitˡ =
      begin
        mult ∘ unit                ≡⟨⟩
        (λ x → (mult ∘ return) x)  ≡⟨⟩
        (λ x → return x >>= id)    ≡⟨ ext unitˡ ⟩
        (λ x → id x)               ≡⟨⟩
        id
      ∎
    ; assoc =
      begin
        mult ∘ fmap mult                                ≡⟨⟩
        (λ x → (mult ∘ fmap mult) x)                    ≡⟨⟩
        (λ x → (fmap mult x) >>= id)                    ≡⟨⟩
        (λ x → (x >>= (return ∘ mult)) >>= id)          ≡⟨ ext assoc ⟩
        (λ x → x >>= (λ y → (return ∘ mult) y >>= id))  ≡⟨ ext (λ {x} → cong (_>>=_ x) (ext unitˡ)) ⟩
        (λ x → x >>= (λ y → mult y))                    ≡⟨⟩
        (λ x → x >>= (λ y → y >>= id))                  ≡⟨ ext (sym assoc) ⟩
        (λ x → (x >>= id) >>= id)                       ≡⟨⟩
        (λ x → mult (x >>= id))                         ≡⟨⟩
        (λ x → (mult ∘ mult) x)                         ≡⟨⟩
        mult ∘ mult
      ∎
    }
  where
    fmap : {A B : Set} → (A → B) → M A → M B
    fmap f x = x >>= (return ∘ f)
    unit : {A : Set} → A → M A
    unit x = return x
    mult : {A : Set} → M (M A) → M A
    mult x = x >>= id
```

Ta-da! `MathMon` is equivalent to `ProgMon` and we can sleep peacefully.




## Aesthetes' monads

We are not done yet: a third common characterization of a monad exists!

Haskellers define the `>=>` operator (pronounced _fish_) as

```haskell
(>=>) :: Monad m => (a -> m b) -> (b -> m c) -> (a -> m c)
(m >=> n) x  = m x >>= n
```

Its type signature makes it more intuitive to use than `>>=`.

Replacing `>>=` in the old monad type class we obtain:

```haskell
class Monad m where
  return :: a -> m a
  (>=>) :: (a -> m b) -> (b -> m c) -> a -> m c
```

The monad laws can also be rewritten in term of `>=>`:

```haskell
return >=> g = g                   -- left unit
f >=> return = f                   -- right unit
(f >=> g) >=> h = f >=> (g >=> h)  -- associativity
```

Their meaning is finally apparent! This makes `>=>` very compelling.

It seems like we struck gold, but we're in for a sad surprise.
Let's define the AGDA type:

```agda
record DopeMon (M : Set → Set) : Set₁ where
  field
    return : {A : Set} → A -> M A
    _>=>_ : {A B C : Set} → (A → M B) → (B → M C) → (A → M C)
    -- monadicity
    unitˡ : ∀ {A C : Set} {g : A → M C}
      → return >=> g ≡ g
    unitʳ : ∀ {A B : Set} {f : A → M B}
      → f >=> return ≡ f
    assoc : ∀ {A B C D : Set} {f : A → M B} {g : B → M C} {h : C → M D}
      → (f >=> g) >=> h ≡ f >=> (g >=> h)
```

You can search Haskell lore or work out for yourself how to tie the operators together.
I will just give you the result (omitting `unit` and `return`s for brevity):

```haskell
-- MathMon → DopeMon
(f >=> g) x = mult (fmap g (f x))
-- DopeMon → MathMon
fmap f x = ((const x) >=> (return . f)) ()
mult x = ((const x) >=> id) ()
-- ProgMon → DopeMon
(m >=> n) x = m x >>= n
-- DopeMon → ProgMon
ma >>= f = ((const ma) >=> f) ()
```

We have all we need, but unfortunately if we try to prove[^dope-mon-types] the equivalence of this definition and the previous two we come to a hard stop.

[^dope-mon-types]:
    Wanna try it? You will realize that replacing Hakell's unit `()` with an `_` brings some typechecking issues.
    The simplest solution is replacing `((const x) >=> ?) _` with `(id >=> ?) x`.

`MathMon → DopeMon` and `ProgMon → DopeMon` pose no problem, but
`DopeMon → ProgMon` and `DopeMon → DopeMon` both have holes which cannot be filled.
This means that `DopeMon` is weaker than both `MathMon` and `ProgMon`.

If you are pernickety enough, you can reduce all unfilled holes to have one of two forms:
you will rediscover the two properties we are missing from `DopeMon`.
That is a road I have traveled and do not recommend.

So... where do we go from here?

`>=>` is often referred to as _Kleisli composition_ and that is a clue leading to _Kleisli categories_.

Every monad $\langle M, \eta, \mu\rangle$ over a category $C$ has an associated **Kleisli category** $C_M$ with
* objects given by $\Obj(C_M)=\Obj(C)$;
* morphisms given by $\Hom_{C_M}(X,Y)=\Obj_C(X,M(Y))$ for every pair of objects $X$, $Y$ in $C$;
* composition given by $g\circ_Mf=\mu_Z\circ M(g)\circ f$ for every pair of morphisms $f\:X\to M(Y)$, $g\:Y\to M(Z)$ in $C$;
* identities given by $\id_X=\eta_X$ for every object $X$ in $C$.

The Haskell lore above tells us that `f >=> g = mult . fmap g . f` and we can recognize that `>=>` is just the Kleisli composition $\circ_M$ with flipped arguments.

In turn, this means the properties we were requiring of `>=>` are the associativity and identity axioms for the composition $\circ_M$ in the category $C_M$. Those _do not imply_ the monad laws for $M$!

Luckily there's an equivalent characterization of a monad which allows us to both succintly characterize $\circ_M$ and simplify our next proofs.

A **Kleisli triple** $\langle M,\eta,(-)^\star\rangle$ in a category $C$ is the ensemble of
* a function $M\:\Obj(C)\to\Obj(C)$,
* a morphism $\eta_X\:X\to M(X)$ for every object $X$ in $C$,
* a morphism $f^\star\:M(X)\to M(Y)$ for every morphism $f\:X\to Y$ in $C$,

such that
* $\eta^\star_X=\id_{M(X)}$ for every object $X$ in $C$,
* $f^\star\circ\eta_X=f$ for every morphism $f\:X\to Y$ in $C$,
* $(g^\star\circ f)^\star=g^\star\circ f^\star$ for every pair of composable morphisms $f$, $g$ in $C$.


To give a monad $\langle M,\eta,\mu\rangle$ is to give a Kleisli triple $\langle M,\eta,(-)^\star\rangle$.

$(-)^\star\:\Hom(X,M(Y))\to\Hom(M(X),M(Y))$ is called the _extension operator_ and it connects the two definitions
for every morphism $f\:X\to Y$ in $C$ like so:

$$
f^\star=\mu_Y\circ M(f)
$$

Therefore it allows to succintly rewrite the Kleisli composition for every pair of composable morphisms $f$, $g$ in $C$ as

$$
g\circ_M f=g^\star\circ f^\star
$$

With that being said, what is the plan now?

We will define the type of Kleisli triples and endow it with `>=>` and its properties by building and deducing them from the extension operator and its properties:

```agda
record KlslMon (M : Set → Set) : Set₁ where
  field
    unit : {A : Set} → A -> M A
    _⋆ : {A B : Set} → (A → M B) → (M A → M B)
    -- extension axioms
    ext-unitˡ : ∀ {A : Set}
      → (unit {A} ⋆) ≡ id
    ext-unitʳ : ∀ {A B : Set} {f : A → M B}
      → (f ⋆) ∘ unit ≡ f
    ext-assoc : ∀ {A B C : Set} {f : A → M B} {g : B → M C}
      → ((g ⋆) ∘ f)⋆ ≡ (g ⋆) ∘ (f ⋆)
  ---
  _>=>_ : {A B C : Set} → (A → M B) → (B → M C) → (A → M C)
  _>=>_ f g = (g ⋆) ∘ f
  -- monadicity
  unitˡ : ∀ {A C : Set} {g : A → M C}
    → unit >=> g ≡ g
  unitˡ {_} {_} {g} =
    begin
      unit >=> g    ≡⟨⟩
      (g ⋆) ∘ unit  ≡⟨ ext-unitʳ ⟩
      g
    ∎
  unitʳ : ∀ {A B : Set} {f : A → M B}
    → f >=> unit ≡ f
  unitʳ {_} {_} {f} =
    begin
      f >=> unit    ≡⟨⟩
      (unit ⋆) ∘ f  ≡⟨ cong (_∘ f) ext-unitˡ ⟩
      f
    ∎
  assoc : ∀ {A B C D : Set} {f : A → M B} {g : B → M C} {h : C → M D}
    → (f >=> g) >=> h ≡ f >=> (g >=> h)
  assoc {_} {_} {_} {_} {f} {g} {h} =
    begin
      (f >=> g) >=> h      ≡⟨⟩
      (h ⋆) ∘ ((g ⋆) ∘ f)  ≡⟨⟩
      ((h ⋆) ∘ (g ⋆)) ∘ f  ≡⟨ cong (_∘ f) (sym ext-assoc) ⟩
      (((h ⋆) ∘ g)⋆) ∘ f   ≡⟨⟩
      f >=> (g >=> h)
    ∎
```

We are now ready for the last stretch.

Scroll way down for the final remarks.



## Aesthetes VS everyone

```agda
MathMon→KlslMon : {M : Set → Set} → MathMon M → KlslMon M
MathMon→KlslMon {M}
  record
    { fmap = fmap
    ; unit = unit
    ; mult = mult
    ; fun-comp = fun-comp
    ; fun-idty = _
    ; nat-unit = nat-unit
    ; nat-mult = nat-mult
    ; unitʳ = unitʳ
    ; unitˡ = unitˡ
    ; assoc = assoc
    }
  =
  record
    { unit = unit
    ; _⋆ = _⋆
    ; ext-unitˡ = λ {_} →
      begin
        (unit ⋆)          ≡⟨⟩
        mult ∘ fmap unit  ≡⟨ unitʳ ⟩
        id
      ∎
    ; ext-unitʳ = λ {_} {_} {f} →
      begin
        (f ⋆) ∘ unit          ≡⟨⟩
        mult ∘ fmap f ∘ unit  ≡⟨ cong (mult ∘_) nat-unit ⟩
        mult ∘ unit ∘ f       ≡⟨ cong (_∘ f) unitˡ ⟩
        f
      ∎
    ; ext-assoc = λ {_} {_} {_} {f} {g} →
      begin
        (((g ⋆) ∘ f) ⋆)                            ≡⟨⟩
        mult ∘ fmap (mult ∘ fmap g ∘ f)            ≡⟨ cong (mult ∘_) fun-comp ⟩
        mult ∘ fmap mult ∘ fmap (fmap g ∘ f)       ≡⟨ cong ((mult ∘ fmap mult) ∘_) fun-comp ⟩
        mult ∘ fmap mult ∘ fmap (fmap g) ∘ fmap f  ≡⟨ cong (_∘ (fmap (fmap g) ∘ fmap f)) assoc ⟩
        mult ∘ mult ∘ fmap (fmap g) ∘ fmap f       ≡⟨ cong (λ h → (mult ∘ h ∘ fmap f)) (sym nat-mult) ⟩
        mult ∘ fmap g ∘ mult ∘ fmap f              ≡⟨⟩
        (g ⋆) ∘ (f ⋆)
      ∎

    }
  where
    _⋆ : {A B : Set} → (A → M B) → (M A → M B)
    _⋆ f = mult ∘ fmap f
```

```agda
KlslMon→MathMon : {M : Set → Set} → KlslMon M → MathMon M
KlslMon→MathMon {M}
  record
    { unit = unit
    ; _⋆ = _⋆
    ; ext-unitˡ = ext-unitˡ
    ; ext-unitʳ = ext-unitʳ
    ; ext-assoc = ext-assoc
    }
  =
  record
    { fmap = fmap
    ; unit = unit
    ; mult = mult
    ; fun-comp = λ {_} {_} {_} {f} {g} →
      begin
        fmap (f ∘ g)                ≡⟨⟩
        (unit ∘ f ∘ g)⋆             ≡⟨ cong (λ h → (h ∘ g)⋆) (sym ext-unitʳ) ⟩
        ((unit ∘ f)⋆ ∘ unit ∘ g)⋆   ≡⟨ ext-assoc ⟩
        (unit ∘ f)⋆ ∘ (unit ∘ g)⋆   ≡⟨⟩
        fmap f ∘ fmap g
      ∎
    ; fun-idty =
      begin
        fmap id       ≡⟨⟩
        (unit ∘ id)⋆  ≡⟨⟩
        unit ⋆        ≡⟨ ext-unitˡ ⟩
        id
      ∎
    ; nat-unit = λ {_} {_} {f} →
      begin
        fmap f ∘ unit       ≡⟨⟩
        (unit ∘ f)⋆ ∘ unit  ≡⟨ ext-unitʳ ⟩
        unit ∘ f
      ∎
    ; nat-mult = λ {_} {_} {f} →
      begin
        fmap f ∘ mult                 ≡⟨⟩
        (unit ∘ f)⋆ ∘ id ⋆            ≡⟨ sym ext-assoc ⟩
        ((unit ∘ f)⋆ ∘ id )⋆          ≡⟨⟩
        (id ∘ (unit ∘ f)⋆)⋆           ≡⟨ cong (λ h → (h ∘ (unit ∘ f)⋆)⋆) (sym ext-unitʳ) ⟩
        (id ⋆ ∘ unit ∘ (unit ∘ f)⋆)⋆  ≡⟨ ext-assoc ⟩
        id ⋆ ∘ (unit ∘ (unit ∘ f)⋆)⋆  ≡⟨⟩
        mult ∘ fmap (fmap f)
      ∎
    ; unitʳ =
      begin
        mult ∘ fmap unit       ≡⟨⟩
        id ⋆ ∘ (unit ∘ unit)⋆  ≡⟨ sym ext-assoc ⟩
        (id ⋆ ∘ unit ∘ unit)⋆  ≡⟨ cong (λ h → (h ∘ unit)⋆) ext-unitʳ ⟩
        (id ∘ unit)⋆           ≡⟨⟩
        unit ⋆                 ≡⟨ ext-unitˡ ⟩
        id
      ∎
    ; unitˡ =
      begin
        mult ∘ unit                ≡⟨⟩
        id ⋆ ∘ unit                ≡⟨ ext-unitʳ ⟩
        id
      ∎
    ; assoc =
      begin
        mult ∘ fmap mult             ≡⟨⟩
        id ⋆ ∘ (unit ∘ id ⋆)⋆        ≡⟨ sym ext-assoc ⟩
        (id ⋆ ∘ unit ∘ id ⋆)⋆        ≡⟨ cong (λ h → (h ∘ id ⋆)⋆) ext-unitʳ ⟩
        (id ∘ id ⋆)⋆                 ≡⟨⟩
        (id ⋆ ∘ id)⋆                 ≡⟨ ext-assoc ⟩
        id ⋆ ∘ id ⋆                  ≡⟨⟩
        mult ∘ mult
      ∎
    }
  where
    fmap : {A B : Set} → (A → B) → M A → M B
    fmap f = (unit ∘ f) ⋆
    mult : {A : Set} → M (M A) → M A
    mult = id ⋆
```

Yes, I know that

* `ProgMon→MathMon` and `MathMon→KlslMon` together imply `ProgMon→KlslMon`
* `KlslMon→MathMon` and `MathMon→ProgMon` together imply `KlslMon→ProgMon`

but we're on a roll..

```agda
ProgMon→KlslMon : {M : Set → Set} → ProgMon M → KlslMon M
ProgMon→KlslMon {M}
  record
    { return = return
    ; _>>=_ = _>>=_
    ; unitˡ = unitˡ
    ; unitʳ = unitʳ
    ; assoc = assoc
    }
  =
  record
    { unit = unit
    ; _⋆ = _⋆
    ; ext-unitˡ = λ {_} →
      begin
        (unit ⋆) ≡⟨⟩
        (λ x → (unit ⋆) x)    ≡⟨⟩
        (λ x → x >>= return)  ≡⟨ ext unitʳ ⟩
        (λ x → x)             ≡⟨⟩
        id
      ∎
    ; ext-unitʳ = λ {_} {_} {f} →
      begin
        (f ⋆) ∘ unit ≡⟨⟩
        (λ x → ((f ⋆) ∘ unit) x)  ≡⟨⟩
        (λ x → (return x) >>= f)  ≡⟨ ext unitˡ ⟩
        (λ x → f x)               ≡⟨⟩
        f
      ∎
    ; ext-assoc = λ {_} {_} {_} {f} {g} →
      begin
        (((g ⋆) ∘ f) ⋆)                      ≡⟨⟩
        (λ x → (((g ⋆) ∘ f) ⋆) x)            ≡⟨⟩
        (λ x → x >>= ((g ⋆) ∘ f))            ≡⟨⟩
        (λ x → x >>= (λ y → ((g ⋆) ∘ f) y))  ≡⟨⟩
        (λ x → x >>= (λ y → (f y) >>= g))    ≡⟨ ext (sym assoc) ⟩
        (λ x → (x >>= f) >>= g)              ≡⟨⟩
        (λ x → (g ⋆) (x >>= f))              ≡⟨⟩
        (λ x → ((g ⋆) ∘ (f ⋆)) x)            ≡⟨⟩
        (g ⋆) ∘ (f ⋆)
      ∎
    }
  where
    unit : {A : Set} → A -> M A
    unit = return
    _⋆ : {A B : Set} → (A → M B) → (M A → M B)
    _⋆ f x = x >>= f

```

```agda
KlslMon→ProgMon : {M : Set → Set} → KlslMon M → ProgMon M
KlslMon→ProgMon {M}
  record
    { unit = unit
    ; _⋆ = _⋆
    ; ext-unitˡ = ext-unitˡ
    ; ext-unitʳ = ext-unitʳ
    ; ext-assoc = ext-assoc
    }
  =
  record
    { return = return
    ; _>>=_ = _>>=_
    ; unitˡ = λ {_} {_} {x} {f} →
      begin
        (return x >>= f)  ≡⟨⟩
        (f ⋆) (unit x)    ≡⟨⟩
        ((f ⋆) ∘ unit) x  ≡⟨ cong-app ext-unitʳ x ⟩
        f x
      ∎
    ; unitʳ = λ {_} {m} →
      begin
        (m >>= unit) ≡⟨⟩
        (unit ⋆) m   ≡⟨ cong-app ext-unitˡ m ⟩
        m
      ∎
    ; assoc = λ {_} {_} {_} {m} {f} {g} →
      begin
        ((m >>= f) >>= g)              ≡⟨⟩
        (g ⋆) ((f ⋆) m)                ≡⟨⟩
        ((g ⋆) ∘ (f ⋆)) m              ≡⟨ cong-app (sym ext-assoc) m ⟩
        (((g ⋆) ∘ f )⋆) m              ≡⟨⟩
        ((λ { x → (g ⋆) (f x) })⋆) m   ≡⟨⟩
        (m >>= (λ { x → f x >>= g }))
      ∎
    }
  where
    return : {A : Set} → A -> M A
    return = unit
    _>>=_ : {A B : Set} → M A → (A → M B) -> M B
    _>>=_ x f = (f ⋆) x
```




## Final remarks

I embarked on this endeavor because I could not find an exhaustive treatment of the equivalence of the three definitions.
Having an _executable_ proof which doubles as a reference by spelling out every detail is extremely satisfying to me,
especially because my initial idea was just to throw together some Haskell pseudocode.

Using AGDA is ludicrously empowering! This was my first semi-serious exercise and I loved every part of it.

