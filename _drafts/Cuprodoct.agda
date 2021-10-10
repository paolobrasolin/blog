module Cuprodoct where

open import Function
open import Data.Product

open import Relation.Binary.PropositionalEquality
open Relation.Binary.PropositionalEquality.≡-Reasoning


record _≅_ (A B : Set) : Set where
  field
    from : A → B
    to : B → A
    from∘to : from ∘ to ≡ id
    to∘from : to ∘ from ≡ id

--data _∐_ (A B : Set) : Set where
--  i₀ : A → A ∐ B
--  i₁ : A ∐ B → A ∐ B

record _∪_ (A B : Set) : Set where
  --coinductive
  field
    i₀ : A ∪ B
    i₁ : A ∪ B

-- ∐-univ : ∀ {A B C : Set} → (f : A → {!!}) → {!!}




