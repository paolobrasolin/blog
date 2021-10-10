{-# OPTIONS --cubical #-}

open import Cubical.Core.Everything

record Stream (A : Set) : Set where
  coinductive
  field
    h : A
    t : Stream A

open Stream

-- FUN FACT: se sbaglio e faccio alt (t x) (t y) me neaccorco solo da bar perché diventano irrilevanti gli argomenti
alt : {A : Set} → Stream A → Stream A → Stream A
h (alt x y) = h x
t (alt x y) = alt (t y) (t x)

foo : ∀ {A : Set} {s : Stream A} → alt s s ≡ s
h (foo {_} {s} i) = h s
t (foo {_} {s} i) = foo {_} {t s} i

-- FUN FACT: se splitto tulla tail posso leggere i tipi dei buchi invece di fare una verifica empirica convertendo a List
bar : ∀ {A : Set} {s r x y : Stream A} → alt s (alt x r) ≡ alt s (alt y r)
h (bar {_} {s} {r} {x} {y} i) = h s
t (bar {_} {s} {r} {x} {y} i) = {!!}
-- h (t (bar {_} {s} {r} {x} {y} i)) = {!!}
-- t (t (bar {_} {s} {r} {x} {y} i)) = bar {_} {t (t s)} {t (t r)} {t (t x)} {t (t y)} i
-- FUN FACT: devo splittare due volte la tail perché la forma del buco sia quella di bar, siccome alt inverte gli argomenti




