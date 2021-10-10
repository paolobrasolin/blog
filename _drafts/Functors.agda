module Functors where

open import Function

open import Relation.Binary.PropositionalEquality
open Relation.Binary.PropositionalEquality.≡-Reasoning


record Functor (M : Set → Set) : Set₁ where
  field
    fmap : {A B : Set} → (A → B) → M A → M B
    -- functoriality
    fun-idty : ∀ {A : Set} → fmap {A} id ≡ id
    fun-comp : ∀ {A B C : Set} {f : B → C} {g : A → B} → fmap (f ∘ g) ≡ (fmap f) ∘ (fmap g)
