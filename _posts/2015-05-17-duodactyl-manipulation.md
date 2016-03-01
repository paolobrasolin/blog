---
latex: mathjax
language: en
macros: |
  \def\norm#1{\left\vert{#1}\right\vert}
  \def\i{\mathbf{i}}
  \def\f{\mathbf{f}}
  \def\mat#1#2#3#4{\begin{pmatrix}#1& #2\\ #3& #4\end{pmatrix}}
title: Duodactyl manipulation
excerpt: >
  Two fingers moving on a screen can perform gestures naturally associated
  with dragging, rotating and zooming. Any gesture univoquely determines a
  direct similitude of the euclidean plane. Let's see how.
---

Say one finger moves from point `$ A $` to point `$ B =: A + \i $`
and the other one moves from point `$ X $` to point `$ Y =: X + \f $`.
Calling `$ \theta $` the counter-clockwise angle between `$ \i $` and
`$ \f $` we can factor the similitude into a rotation sandwiched between
scalings and translations. The orderes sequence of operations is

``` tex
$$\begin{align}
  P &\mapsto P - A \\
  P &\mapsto P \norm\i^{-1} \\
  P &\mapsto R_\theta P \\
  P &\mapsto P \norm\f \\
  P &\mapsto P + B
\end{align}$$
```

and their composition is

``` tex
$$
  P \mapsto \frac{\norm\f}{\norm\i}
            R_\theta(P-A) + B
$$
```

Two obviously defined products

``` tex
$$\begin{align}
  \i \cdot  \f &= \norm\i \norm\f \cos\theta \\
  \i \times \f &= \norm\i \norm\f \sin\theta
\end{align}$$
```

allow us to write

``` tex
$$\begin{align}
  R_\theta
    &= \mat{\cos\theta}{-\sin\theta}{\sin\theta}{\cos\theta} \\
    &= \frac{1}{\norm\i \norm\f}
       \mat{\i\cdot\f}{-\i\times\f}{\i\times\f}{\i\cdot\f}
\end{align}$$
```

and produce the full trasformation in a convenient form:

``` tex
$$
  P \mapsto \mat{\i\cdot\f}{-\i\times\f}{\i\times\f}{\i\cdot\f}
            \frac{P-A}{\i\cdot\i} + B
$$
```

