---
title: Enumerare associazioni
latex: mathjax
language: it
excerpt: >
  Mi è stato chiesto: in quanti modi un'operazione di arietà arbitraria
  può agire su di un numero finito di elementi? Rispondo.
---

# Enumerare associazioni

Mi è stato chiesto: in quanti modi un'operazione di arietà arbitraria
può agire su di un numero finito di elementi? Rispondo.

Consideriamo un'operazione `$p$`-aria.
Il numero di modi in cui essa può agire su di un'`$n$`-upla di elementi è

``` tex
$$ {p(n-1) \choose n-1} \frac{1}{(p-1)(n-1) + 1} $$
```

Perché? Enumerandoli col nome di `$\tilde{f}_n$` si osservano i casi banali

``` tex
$$
  \tilde{f}_n =
    \begin{cases}
      1 \text{ se } 1 = n     \\
      0 \text{ se } 1 < n < p \\
      1 \text{ se }     n = p
    \end{cases}
$$
```

mentre un semplice argomento ricorsivo mostra

``` tex
$$
  \tilde{f}_n =
    \sum_{1 \leq \tilde{k}_1,  \ldots,  \tilde{k}_p}
        ^{n   =  \tilde{k}_1 + \ldots + \tilde{k}_p}
      \prod_{i=1}^p \tilde{f}_{\tilde{k}_i}
  \qquad \text{ se } n > p
$$
```

Conviene ora traslare un po' d'indici:

``` tex
$$
\begin{align}
  \tilde{k}_i &\mapsto k_i = \tilde{k}_i - 1 \\
  \tilde{f}_i &\mapsto f_i = \tilde{f}_{i+1} \\
\end{align}
$$
```

``` tex
$$
  f_{n+p-1} =
    \sum_{0 \leq k_1,  \ldots,  k_p}
        ^{n   =  k_1 + \ldots + k_p}
      \prod_{i=1}^p f_{k_i}
$$
```

Definita la funzione generatrice `$ F(x) = \sum_{k=0}^\infty f_k x^k $`
notiamo che

``` tex
$$
  [F(x)]^p
    = \sum_{k=0}
        \left(
          \sum_{0 \leq k_1,  \ldots,  k_p}
              ^{k   =  k_1 + \ldots + k_p}
            \prod_{i=1}^p f_{k_i}
        \right) x^k
    = \sum_{k=0}^\infty f_{k+p-1} x^k
$$
```

ovvero

``` tex
$$
  x^{p-1} [F(x)]^p
    = F(x) - \sum_{k=0}^{p-2} f_k x^k
    = F(x) - 1
$$
```

Risolvendo quest'ultima equazione funzionale in `$F$` ed `$x$` per
`$p=2,3,4$` e studiando gli sviluppi delle soluzioni reali e pole free
sull'origine ci si rende conto di un pattern che suggerisce la soluzione
proposta nell'incipit:

``` tex
$$ f_k = {pk \choose k} \frac{1}{(p-1)k + 1} $$
```

Ovviamente la validità di tale espressione andrebbe verificata a
posteriori in qualche maniera, ma quanto detto basta a rintracciare
il nome dei numeri in questione, appartenenti alla serie multivariata
di Fuss-Catalan. In [arXiv:0711.0906](http://arxiv.org/abs/0711.0906)
si trova una soluzione dettagliata del problema.

