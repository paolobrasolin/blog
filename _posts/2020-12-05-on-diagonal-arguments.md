---
title: On diagonal arguments
published: true
latex: katex
language: en
---

I'm emotionally bound to diagonal arguments (weird, huh?) because that's how I stumbled upon someone who gestured and made me gaze upon mathematics for the first time.
I'd like to tell you about some of these ideas, all revolutionary in their own right, and how they are shadows of a single encompassing truth.

**Note:** I will sweep quite a lot of nonobvious stuff under the rug in order not to bog down the causal reader this is written for[^yeah].
I promise not to lie, though!
In a mild attempt to atone I will also mark the most egregious omissions with an ⚠.

[^yeah]: Yeah, it's definitely not because I wouldn't be able to delve into the full detail even if I wanted to. Definitely not.


## Cantor's diagonal argument

In 1891 Georg Cantor published[^Can91] his diagonal argument.
He proved the existence of infinite sets which cannot be put into one-to-one correspondence with the set of natural numbers.
More clearly: he proved the existence of sets bigger than the infinite set of natural numbers.
This was the first step which led to the development of the theory of cardinal numbers, a generalization of the natural numbers capable of measuring the size of sets (and the different kinds of infinities they can be).

[^Can91]: Georg Cantor, _Uber eine elementare Frage der Mannigfaltigkeitslehre_, 1891.

Let $C$ be the set of infinite sequences of binary digits, i.e. objects like $(0,0,1,0,0,1,0,0,\ldots)$.

**Theorem.** Given any enumeration $s_1, s_2, \ldots, s_n, \ldots$ of elements from T, there is an $s\in T$ which corresponds to no $s_n$ in the enumeration.

_Proof._ Consider an enumeration $s_1, s_2, \ldots$ and build a sequence $s$ such that its $n$th digit is the complementary[^complementary] of the $n$th digit of the $n$th sequence in the enumeration:

$$
\begin{aligned}
  s_1 & = (\mathbf{0},0,0,\ldots) \\
  s_2 & = (1,\mathbf{0},1,\ldots) \\
  s_3 & = (0,1,\mathbf{1},\ldots) \\
  & \vdots \\[.2em]\hline\\[-1em]
  s & = (\mathbf{1},\mathbf{1},\mathbf{0},\ldots) \\
\end{aligned}
$$

By construction, $s$ differs from each $s_n$ in the enumeration since their $n$th digit is different.
Hence, $s$ cannot occur in the sequence. $\blacksquare$

[^complementary]: Taking the complement means swapping $0$s for $1$s and vice versa.

Don't be fooled by the underwhelming simplicity: this result is important.
Enumerating a set means labeling its elements with natural numbers, so we just proved that no enumeration of $T$ is exhaustive.
In other terms, the correspondence established by no enumeration can be one-to-one.
This means that while we know that the set of natural numbers is infinite, we now also know that $T$ is strictly bigger[^cardinality].

[^cardinality]: The notion of _set size_ is made precise by the definition of _cardinality_, which you won't regret looking up.


## The Halting problem

In 1928, amidst a period of fervent debate on the foundations of mathematics, David Hilbert and Wilhelm Ackermann posed[^Hil28] the Entscheidungsproblem (decision problem):

[^Hil28]: David Hilbert and Wilhelm Ackermann, _Grundzüge der Theoretischen Logik_, 1928.

> exhibit an algorithm which takes a statement of a first-order[^first-order-logic] logic as an input and outputs _Yes_ or _No_ according to whether the statement is provable from the axioms using the rules of logic.

[^first-order-logic]: Loosely speaking, a first-order logic is a logic allowing not only propositions (e.g. "Socrates is a man") but also quantification (e.g. "there exists x such that x is a man and x is not Socrates" or "for every x, if x is Socrates then x is a man").

Before answering, the notion of _algorithm_ had to be made precise.
That was done during the 30s by Alonzo Church with his λ-calculus, and then again by Alan Turing with his Turing machines.
The two notions proved to be equivalent models of computation, and during those years the fields of computation and computability theory theory sprung to life with the contribution of many others, _well before the construction of the first computer_[^predated-pcs].

[^predated-pcs]: Let me emphasize that: the theories of computation and computability with all their theorems about the fundamental limits of computers existed well before the first computer was engineered.

Once the necessary machinery was established, the answer to Hilbert's request was found to be a resounding _no_.

A _Turing machine_ (TM for short) is a box<sup>⚠</sup> which maintains and evolves a state by consuming input.
When given an input, it can either _halt by accepting_ the input, _halt by rejecting_ the input, or not halt at all by _looping_ forever in an infinite computation.

A _language_ is a collection of inputs that can be fed to a TM.
A TM is said to _recognize_ a language if it accepts all its inputs, and either rejects or never halts on inputs not in the language.
A TM is said to _decide_ a language if it accepts all inputs in the language and rejects all inputs not in the language.

Intuitively, saying that a TM decides a language means that it is always able to give an answer to the problem represented by the language.

Given an _encoding_ $\langle-\rangle$ which maps things<sup>⚠</sup> to an input the machine can recognize, we can write the Halting problem as a language encoding all pairs composed by machines and inputs on which they halt:

$$
H = \left\{ \left\langle M, x \right\rangle \vert \mathrm{\ Turing\ machine\ } M \mathrm{\ halts\ on\ input\ } x \right\}
$$

If a TM is able to decide $H$ it means that it's able to determine whether any possible TM halts on any possible input.

**Theorem.** No Turing machine[^that-depends][^that-really-depends] can decide $H$.

[^that-depends]: Halting problems for simpler computation models are decidable, but we're interested in Turing machines because they are deemed to be universal in the sense implied by the [Church-Turing Thesis](https://plato.stanford.edu/entries/church-turing/).
[^that-really-depends]: Interestingly, the Halting problem restricted to physical computers can be decided by Turing machines, because the former have finite memory and the latter can successfully simulate them having infinite memory. It is the general problem which cannot be decided.

_Proof._ 
Suppose there exists a TM $A$ that decides $H$.
Consider a TM B constructed<sup>⚠</sup> as follows:
* $B$ halts on $\langle p\rangle$ if $A$ rejects $\langle p, \langle p\rangle\rangle$;
* $B$ loops on $\langle p\rangle$ if $A$ accepts $\langle p, \langle p\rangle\rangle$.

Consider the two possible behaviours of $A$ on $\langle B,\langle B\rangle\rangle$:
* if $A$ accepts $\langle B,\langle B\rangle\rangle$ then
  * $B$ must halt on $\langle B\rangle$ by definition of $A$,
  * $B$ must loop on $\langle B\rangle$ by definition of $B$;
* if $A$ rejects $\langle B,\langle B\rangle\rangle$ then
  * $B$ must loop on $\langle B\rangle$ by definition of $A$,
  * $B$ must halt on $\langle B\rangle$ by definition of $B$.

In both cases we derive a contradiction from the construction of $B$.
Hence, $A$ cannot exist. $\blacksquare$

This proof was also relatively simple to follow.
But... what does it have to do with the Cantor's diagonal argument?

TMs can be enumerated[^enumerable-tm], so given any pair $M_i$ and $M_j$ we can build a table presenting whether the first halts when given the second is encoded and fed to it as an input.
That is, whether $\langle M_i, \langle M_j\rangle\rangle \in H$ or in other words how $A$ acts on a certain subset of $H$:

[^enumerable-tm]: A Turing machine is mathematically represented by a combination of finite objects; with some effort one can find an encoding to represent it with a finite number of symbols and order them lexicographically to obtain an enumeration. 

$$
\begin{matrix}
& \langle M_1\rangle & \langle M_2\rangle & \langle M_3\rangle & \ldots \\
M_1 & \mathrm{\textbf{accepts}} & \mathrm{accepts} & \mathrm{accepts} & \ldots \\
M_2 & \mathrm{rejects} & \mathrm{\textbf{accepts}} & \mathrm{rejects} & \ldots \\
M_3 & \mathrm{accepts} & \mathrm{rejects} & \mathrm{\textbf{rejects}} & \ldots \\
\vdots & \vdots & \vdots & \vdots & \ddots \\[.2em]\hline\\[-1em]
B & \mathrm{\textbf{loops}} & \mathrm{\textbf{loops}} & \mathrm{\textbf{halts}} & \ldots \\
\end{matrix}
$$

Juxtaposing $B$ to the table, it becomes noticeable how it has been built as a "complementary of the diagonal".
Furthermore, the previous proof essentially states $B$ cannot occur in the enumeration.
This looks very much like a generalization of Cantor's technique.

What the hell is going on?


## Gödel's First incompleteness theorem

We only mentioned Hilbert's Entscheidungsproblem, but it is just the last of the three question he recast in 1928 freshening some of the famous _23 Hilbert Problems_ posed three decades earlier:
1. Is mathematics complete? I.e. can any statement be proved or disproved from the axioms?
2. Is mathematics consistent? I.e. does any provable statement exist such that its negation is provable too?
3. Is mathematics decidable?

We now know how the last one was answered.
However -- brace yourself -- that result was informed by the work Gödel did on the first two questions a few years before.
In 1931 Gödel stated[^God31] the result known as the _First incompleteness theorem_.
The details are pretty technical, so we'll just sketch this result.

**Theorem sketch.**<sup>⚠⚠</sup> Any consistent formal system within which a certain amount of elementary arithmetic can be carried out is incomplete (i.e. there are statements of its language which can neither be proved nor disproved).

[^God31]: Kurt Gödel, _On Formally Undecidable Propositions of Principia Mathematica and Related Systems I_, 1931.

_Proof sketch._<sup>⚠⚠</sup> The proof is composed of three steps: arithmetization of syntax, construction of the provability statement, and diagonalization.
1. Expressions of the formal system can enumerated by a mapping to natural numbers called _Gödel numbering_. Thanks to this, proving properties of expressions (e.g. falsehood) is equivalent to proving properties of numbers.
2. Build an expression meaning "statement $S$ is provable in the system" which can be applied to any statement $S$.
3. Use the diagonalization technique to build the _Gödel sentence_, a self-referential expression meaning it itself is unprovable.
Assuming the system is consistent, show the _Gödel sentence_ is unprovable thus demonstrating the system is not complete. By _reductio ad absurdum_ the system cannot be consistent.
$\blacksquare$

Provided you forgive me for skimping on details, you should now be seeing a general pattern which underlies all examples up to this point.

In fact, Gödel's main technical insights were the first two steps.
The punchline itself really is one of many diagonalization arguments in math, all alike in structure.

This trail we are following, where does it lead?


## Lawvere's Fixed point theorem

There are many results akin to the ones mentioned above, and various generalizations which historically elucidated their similarities.
There is also absolutely no hope for me to do any justice to them or the minds which produced them.

Therefore, I will yield now and simply point to the pot of gold at the end of the rainbow:
all previous results are instances of the _Fixed point theorem_ Lawvere presented[^Law69] in 1969.

[^Law69]: William Lawvere, _Diagonal Arguments and Cartesian Closed Categories_, 1969.

**Theorem**. For any cartesian closed category, if there exists a point-surjective morphism[^where-is-diag] $\phi\colon A\to B^A$, then every morphism $f\colon B\to B$ has a fixed point $s\colon 1 \to B$.

[^where-is-diag]: You might be wondering where the _diagonal flavour_ has gone to, in Lawvere's theorem. It's all in the definition of $\phi\colon A\to B^A$ and you'll be able to clearly see how [if you're interested](https://ncatlab.org/nlab/show/Lawvere's+fixed+point+theorem).

It is definitely not a _complex_ result, but understanding it requires a nontrivial amount of math.
Luckily, we can ~~butcher~~ rephrase it vaguely enough to feel how it may subsume the previous results:

> > For any cartesian closed category,
>
> In any setting (populated by the objects of our study) with enough structure to host a logic which models our intuitive notion of computation,
>
> > if there exists a point-surjective morphism $\phi\colon A\to B^A$,
>
> given two objects $A$ and $B$, if there exist a way to attribute an element of $A$ to every map from $A$ to $B$,
>
> > then every morphism $f\colon B\to B$ has a fixed point $s\colon 1 \to B$.
>
> then every map $f$ from $B$ to itself has a fixed point (i.e. an element $x$ of $B$ such that $f(x)=x$).

We can also easily apply the theorem's obverse to obtain negative results: if we can present an $f$ with no fixed point then such a $\phi$ cannot exists.
Let's consider Cantor's diagonal argument once again and do just that.

The infinite sequences we studied are secretly elements of $\mathbf{2}^\mathbb{N}$, i.e. maps from $\mathbb{N}$ (natural numbers) to $\mathbf{2}$ (binary digits) which map $n$ to the $n$th digit of the sequence.
The exhaustive enumeration of sequences we postulated the existence of is exactly a map $\phi\colon\mathbb{N}\to\mathbf{2}^\mathbb{N}$. However, it's easy to present a map $f\colon\mathbf{2}\to\mathbf{2}$ which has no fixed point: the map sending a binary digit to its complementary. Therefore $\phi$ cannot exist. QED.

All three negative results presented above, i.e.
* uncountability from Cantor's diagonal lemma,
* undecidability from the Halting problem, and
* incompleteness from Gödel's first theorem

can all be cast as consequences of Lawvere's Fixed point theorem obverse.
Along with these, many other results both positive and negative can be seen under this same angle.


## Conclusion

Each of the mentioned results revolutionized math in its own way, planting ideas which grew into whole new branches.
This didn't come without some human downsides: oftentimes those ideas have been shrouded by an esoteric and mysterious aura.
Lawvere[^Law08] himself clearly underlined that:

> In _Diagonal arguments and Cartesian closed categories_ we demystified the incompleteness theorem of Gödel and the truth-definition theory of Tarski by showing that both are consequences of some very simple algebra in the Cartesian-closed setting. It was always hard for many to comprehend how Cantor's mathematical theorem could be re-christened as a "paradox" by Russell and how Gödel's theorem could be so often declared to be the most significant result of the 20th century. There was always the suspicion among scientists that such extra-mathematical publicity movements concealed an agenda for re-establishing belief as a substitute for science. Now, one hundred years after Gödel's birth, the organized attempts to harness his great mathematical work to such an agenda have become explicit.

However, let the pragmatic optimism of Yanofsky[^Yan03] be the last quote. He wrote:

> The best part of this unified scheme is that it shows that there are really no paradoxes. There are limitations. Paradoxes are ways of showing that if you permit one to violate a limitation, then you will get an inconsistent systems.

[^Law08]: [An interview with F. William Lawvere](http://www.mat.uc.pt/~picado/lawvere/interview.pdf), 2008.

[^Yan03]: Noson S. Yanofsky, [_A Universal Approach to Self-Referential Paradoxes, Incompleteness and Fixed Points_](https://arxiv.org/pdf/math/0305282.pdf), 2003.

I on the other hand have written nearly nothing,
tracing just broad strokes across centuries of efforts
to share with you my amazement at both the minglings of history
and the clarity humans are capable of reaching.

Hopefully that's enough to make your curious,
or at the very least angry at the lack of details,
which for many purposes is equivalent.
