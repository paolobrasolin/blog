---
title: An invariant for oriented hypercube graphs embeddings
published: true
latex: katex
language: it
katex:
antex:
    preamble:
        \usepackage{commutative-diagrams}
---

http://sites.oxy.edu/rnaimi/CV/publications/tsgEmbeddedGraphs.pdf
https://math.stackexchange.com/questions/1312214/eccentricity-of-a-vertex-in-hypercube-graph
https://arxiv.org/pdf/1512.08448.pdf
https://www.sciencedirect.com/science/article/pii/0012365X9400104Q
https://en.wikipedia.org/wiki/Orientation_(graph_theory)
https://en.wikipedia.org/wiki/Glossary_of_graph_theory_terms#C
https://en.wikipedia.org/wiki/Graph_canonization

Ever had a bunch of cubical commutative diagrams and needed to quickly discern which are equivalent up to homeomorphism of the underlying directed graph? Yeah! Thanks to [Fosco](https://twitter.com/ququ7/) for distracting me with this one.

Here's one of them babies:

{% tex classes: [antex, display] %}
\begin{codi}
  \obj[tetragonal=base 6em height 6em]{ X & B \\ Y & A \\ };
  \obj[tetragonal=base 6em height 6em] at (3em,-3em){ X' & B' \\ Y' & A' \\ };

  \mor[mid] X \phi:-> B;
  \mor[mid]:[near start] A \psi:-> Y;

  \mor[mid] X' \xi_1:-> X f:-> Y \xi_2:-> Y';
  \mor[mid, near start]:[crossing over] * f':-> *;

  \mor[mid] A \xi_4:-> A' g':-> B' \xi_3:-> B;
  \mor[mid]:[near start] * g:-> *;

  \mor[mid, near start]:[crossing over] X' \phi':-> B';
  \mor[mid] A' \psi':-> Y';
\end{codi}
{% endtex %}

Forgetting about labels yields a graph, and that's what we want to focus on.

One can hopefully conjecture the existence of some graph invariant which does the trick, but 


## Complete graphs

## Cube graphs

## Hypercube graphs
