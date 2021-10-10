---
title: initalgebra
published: true
latex: katex
language: en
katex:
---


https://en.wikipedia.org/wiki/F-algebra#:~:text=Initial%20F%2Dalgebra,-Main%20article%3A%20Initial&text=Various%20finite%20data%20structures%20used,parametricity%20holds%20for%20the%20type.
https://www.schoolofhaskell.com/user/bartosz/understanding-algebras
https://ncatlab.org/nlab/show/initial+algebra+of+an+endofunctor
https://ncatlab.org/nlab/show/algebra+for+an+endofunctor

https://blog.ploeh.dk/2019/04/29/catamorphisms/
qui ci sono esempi di cosa è cata ma non fold, e altre cose cruciali


```agda

{-
data Expr = Const Int
          | Add Expr Expr
          | Mul Expr Expr
          -}

open import Data.Nat

data Expr : Set where
  Const : ℕ → Expr
  Add : Expr → Expr → Expr
  Mul : Expr → Expr → Expr

data ExprF (A : Set) : Set where
  Const : ℕ → ExprF A
  Add : A → A → ExprF A
  Mul : A → A → ExprF A


-- newtype Fix f = Fx (f (Fix f))

data Fix (f : Set → Set) : Set where
  Fx : f (Fix f) → Fix f





```
