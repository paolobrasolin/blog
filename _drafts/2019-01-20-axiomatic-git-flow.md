---
title: Axiomatic GIT flow
published: true
antex:
    preamble:
        \usepackage{tikz}
        \tikzset{
            y=-10,
            gitnode/.style = {
                shape=circle,
                fill=#1,
                text=white,
                font={\small\tt\bfseries},
                inner sep=2pt
            },
            gitpath/.style = {
                draw=#1,
                line width=3pt,
            }
        }
---

`git` is an extremely powerful tool.

## Preliminaries

A repository is a merkelized directed acyclic graph[^MDAG].

[^MDAG]: Be warned: this description omits implementation details, so it is only *effectively* true.

The vertices represent the revisions of the project, or *commits*.

The edges are arrows pointing from a commit to its parent, i.e. the one it was built upon.
This explains why the graph is acyclic: chronological consistency forbids time loops.
Also note that vertices can have many afferent edges (history can fork towards the future)
but no more than a single efferent edge (history cannot fork towards the past).

Each commit carries some information:
 * metadata about its creation (timestamp, authors, etc.),
 * the diff with its parent commit (concretely realizing the changes to the project),
 * and a cryptographic hash that uniquely identifies it.

> TODO: hash calculation, hash is history consistency


## Rules

> **Axiom 1**: public history must not be altered.

Public history is the history of public branches.
Public branches are **TODO: not that simple to define**.

This has two immediate consequences:
* *force pushing* towards public branch is forbidden
* *merging* is the only allowed way to join two public branches

> **Axiom 2**: private history may be altered.

Should this actually be an axiom?

## Notes


* **master** branch
* **development** branch
* **feature** branches


NOTE: https://github.com/walmes/Tikz/blob/master/src/PET_git_workflow.pgf





## Test graph

{% tex classes: [antex, display] %}
    \begin{tikzpicture}
        \path[gitpath=orange] (1,0) to[out=0,in=180] (1+1,2) -- (5-1,2) to[out=0,in=180] (5,1);
        \path[gitpath=blue] (2,0) to[out=0,in=180] (2+1,1) -- (7-1,1) to[out=0,in=180] (7,0);
        \path[gitpath=red] (0,-0) -- (7,0);
        \node at (0,0) [gitnode=red]{1};
        \node at (1,0) [gitnode=red]{2};
        \node at (2,0) [gitnode=red]{3};
        \node at (3,2) [gitnode=orange]{4};
        \node at (4,0) [gitnode=red]{5};
        \node at (5,1) [gitnode=blue]{6};
        \node at (6,1) [gitnode=blue]{7};
        \node at (7,0) [gitnode=red]{8};
    \end{tikzpicture}
{% endtex %}



