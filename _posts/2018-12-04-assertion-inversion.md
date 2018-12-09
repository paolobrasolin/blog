---
mathjax: true
---

# Assertion inversion

Ana Ulin published a fascinating blog post listing [things nobody told her about being a software engineer](https://anaulin.org/blog/things-nobody-told-me-about-being-a-software-engineer/).
One of these left me wondering.

She ignored:
> That I would be *this* suspicious when the tests pass on first try, and have to invert my assertions to force a test failure and convince myself that things are working as intended. (Aside: why is this not a standard feature of testing frameworks? I want some way to re-run tests flipping some of the assertions, to make sure they are testing what I think they are.)

"Yeah! That sounds cool," I thought while starting to fiddle with [RSpec](http://rspec.info/) internals.

I soon realized that inverting assertions expecting tests to fail is **not** how I check passing tests that I don't trust: I break them *changing the code* they should be testing!
Moreover, we can intuitively grasp that the success of a test should be logically equivalent to the failure of its negation (i.e. the test with the inverted assertion).

Blinded by my enthusiasm, I needed console myself and crystallize this notion into a *neat* argument.

---

Let $S$ be the **state-space** of a machine, i.e. the set containing all possible states of the memory accessible by programs.
A **program** is then a function $P\colon S\to S$.

Let $\mathbf{1}$ and $\mathbf{2}$ be the sets with one and two elements respectively.
We can effectively think of $\mathbf{2}$ as the state-space of a single bit and denote $t,f\colon\mathbf{1}\to\mathbf{2}$ the functions pointing to the **true** and **false** state respectively.

A test **case** is a function $c\colon\mathbf{1}\to S$ choosing the initial state of the machine.
A test **assertion** is a function $a\colon S\to\mathbf{2}$ expressing a proposition about the final machine state.
A **test** on the program $P\colon S\to S$ is then a case/assertion pair $(c, a)$.

In common parlance, we say a test is passing (failing) when *the test assertion about the result of running the program on the test case evaluates to true (false)*.

In equations, we say a test $(c, a)$ on $P$ is passing when $a\circ P \circ c = t$ and failing when $a\circ P \circ c = f$.

In diagrams, we say a test $(c, a)$ on $P$ is **passing** (**failing**) when the left (right) diagram commutes:

$$
  \require{AMScd}
  \begin{CD}
    S @< c<< \mathbf{1}\\
    @VPVV @VVtV\\
    S @>>a> \mathbf{2}
  \end{CD}
  \qquad
  \begin{CD}
    S @< c<< \mathbf{1}\\
    @VPVV @VVfV\\
    S @>>a> \mathbf{2}
  \end{CD}
$$

Let $\sigma\colon\mathbf{2}\to\mathbf{2}$ be the the **negation**, i.e. the function exchanging *true* and *false*.
It is an involution and some obvious identities hold: $\sigma\circ\sigma = \mathrm{id}_\mathbf{2}$, $\sigma\circ t=f$ and $\sigma\circ f=t$. We can also write the **inversion** $\bar{a}$ of an assertion $a$ as $\bar{a}=\sigma\circ a$.

It is then a trivial exercise to prove that a test $(c,a)$ passes iff $(c,\bar{a})$ fails:

$$
  \begin{align}
    a\circ P \circ c &= t \\
    \sigma\circ a\circ P \circ c &= \sigma\circ t \\
    \bar{a}\circ P \circ c &= f \\
  \end{align}
$$

---

This concludes the formal proof that inverting an assertion to observe the test failure adds no information and is in fact equivalent to observing the original test passing.

I'm clearly using a sledgehammer to crack a nut but I feel I'm now *actually* grokking this.
I think this formalism might elucidate some other aspects of TDD, at least for me, so I'm definitely interested in bringing it further.
