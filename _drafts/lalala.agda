module lalala where

open import Function
open import Data.Product
open import Functors

open import Relation.Binary.PropositionalEquality
open Relation.Binary.PropositionalEquality.≡-Reasoning

data _∪_ (A B : Set) : Set where
  ll : A → A ∪ B
  rr : B → A ∪ B

open _∪_ public

data ⊥ : Set where
  t : ⊥

f : {A : Set} → Set → Set
f {A} S = ⊥ ∪ (A × S)

isFun : {A : Set} → Functor (f {A})
isFun {A} =
  record
  { fmap = fmap
  ; fun-idty = fun-idty
  ; fun-comp = fun-comp
  }
  where
    fmap : {X Y : Set} → (X → Y) → f {A} X → f {A} Y
    fmap u (ll fx) = ll fx
    fmap u (rr fx) = rr (proj₁ fx , u (proj₂ fx))

    ffun-idty : {Z : Set} → ∀ {x : f {A} Z} → fmap {Z} {Z} id x ≡ id x
    ffun-idty {Z} {ll x} = refl
    ffun-idty {Z} {rr x} = refl

    fun-idty : {Z : Set} → fmap {Z} {Z} id ≡ id
    fun-idty {Z} =
      begin
        fmap id
      ≡⟨⟩
        (λ x → fmap id x)
      ≡⟨ {!!} ⟩
        (λ x → x)
      ≡⟨⟩
        id
      ∎
    fun-comp :  {A B C : Set} {f : B → C} {g : A → B} → fmap (f ∘ g) ≡ fmap f ∘ fmap g
    fun-comp = {!   !}
