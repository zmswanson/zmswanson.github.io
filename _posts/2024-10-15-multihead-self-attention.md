---
layout: post
title: "Multi-Head Self-Attention in Vision Transformers"
description: "A conceptual and mathematical breakdown of how Vision Transformers learn global relationships using multi-head self-attention."
categories: [research, vision-transformers, interpretability, attention]
image: /assets/images/mhsa_diagram.png
mathjax: true
---

## Overview

In my Master’s thesis,
[*Analysis of Vision Transformers and Domain Adaptation in Long-Range Facial Recognition*](https://digitalcommons.unl.edu/elecengtheses/159/),
I analyzed how **Vision Transformers (ViTs)** outperform convolutional neural networks (CNNs) by
learning *global* rather than *local* relationships. At the center of this ability lies the 
**multi-head self-attention (MHSA)** mechanism — the core operation that allows a model to decide
*which* parts of an image deserve focus.

This post first explains the idea intuitively, then dives into the mathematical details with
equations rendered in LaTeX.

---

## From Words to Pixels

Transformers were originally designed for *language* tasks, where each word’s meaning depends on
others around it. For instance, in the sentence:

> “The cat sat on the mat,”

the word **“cat”** influences how we interpret **“sat.”** The transformer models these relationships
by comparing every word with every other word — this is the **attention mechanism**.

In Vision Transformers, the same principle applies to **images**. An image is divided into small
**patches** (for example, 16×16 pixels), flattened into vectors, and linearly projected to form a
sequence of **tokens** — just like words in a sentence.

---

## The Mechanics of Self-Attention

Each token generates three learned representations:

- **Query (Q):** “What am I looking for?”
- **Key (K):** “What information do I have?”
- **Value (V):** “What information should I pass along?”

The model measures how similar each query is to every key. These similarity scores determine how
much each patch should “attend” to every other patch — forming an **attention map** that captures
relationships across the image. For self-attention, Q, K, and V are the same set of tokens. Other
types of attention like cross-attention have queries that come from one source and keys from
another.

<p>
  <img src="/assets/images/scaled_dot_product_attention.png"
       alt="Scaled Dot Product Attention"
       style="display:block;margin:auto;max-height:450px;height:auto;width:auto;object-fit:contain;">
</p>

The process allows each patch to update its representation based on other relevant patches —
for example, connecting both eyes of a face, or linking shadows to their light sources.

---

## Understanding Multihead

Doing this comparison once captures a single kind of relationship. But there are many different cues
in an image — shape, color, texture, symmetry, and position — all of which contribute to
understanding.

So transformers use **multiple attention heads**. And this mechanism, as shown below 
(Vaswani et al. 2017), was one that I scratched my head over for a while. Was the input being
partitioned into separate parts? Or was the same vector just being projected into a lower
dimension with independent weights?

<p>
  <img src="/assets/images/mhsa_diagram.png"
       alt="Multi-Head Attention"
       style="display:block;margin:auto;max-height:500px;height:auto;width:auto;object-fit:contain;">
</p>

The seminal _Attention is All You Need_ paper (Vaswani et al. 2017) clearly explains that it is the
latter:

> "Instead of performing a single attention function with $d_{\text{model}}$-dimensional keys, values and 
queries, we found it beneficial to project the queries, keys and values h times with different, 
learned linear projections to $d_k$, $d_k$ and $d_v$ dimensions, respectively."

For vision systems, each head learns to focus on a different type of relationship, like several
people analyzing the same photo through different lenses:

- One focuses on **edges and outlines**,  
- Another on **color consistency**,  
- Another on **spatial symmetry**,  
- Yet another on **texture continuity**.

Each head forms its own attention map; their results are then concatenated and mixed to form a
unified understanding of the scene.

---

## Mathematical Dive — Scaled Dot-Product Attention

Suppose our image was divided into $N$ patches, each represented by a feature vector of 
dimension $d_{\text{model}}$. We collect them into a matrix:

$$
X \in \mathbb{R}^{N \times d_{\text{model}}}
$$

Each patch produces **query**, **key**, and **value** vectors using learned projection matrices:

$$
Q = XW_Q, \quad K = XW_K, \quad V = XW_V
$$

where $W_Q, W_K, W_V \in \mathbb{R}^{d_{\text{model}} \times d_k}$.

The **attention** between tokens is computed as a scaled dot-product:

$$
\text{Attention}(Q, K, V) = \text{softmax}\!\left(\frac{QK^\top}{\sqrt{d_k}}\right)V
$$

The scaling factor $\sqrt{d_k}$ prevents the dot products from growing too large, which would
otherwise cause the softmax to produce overly peaked distributions and lead to unstable gradients.

The result is a weighted combination of the values **V**, where each patch aggregates information
from all other patches according to its learned relevance weights.

---

## Multi-Head Self-Attention (MHSA)

To capture multiple types of relationships in parallel, we use $h$ independent attention heads,
each with its own set of projection matrices:

$$
\text{head}_i = \text{Attention}(XW_Q^{(i)}, XW_K^{(i)}, XW_V^{(i)})
$$

Each head outputs a matrix of size $ N \times d_v $. The outputs of all heads are concatenated and
linearly projected back to the model’s original dimensionality:

$$
\text{MultiHead}(Q,K,V) = \text{Concat}(\text{head}_1, \ldots, \text{head}_h) W_O
$$

where $ W_O \in \mathbb{R}^{h d_v \times d_{\text{model}}} $.

For example, in ViT-Base, $ d_{\text{model}} = 768 $ and $ h = 12 $, so each head operates in a
$ 64 $-dimensional subspace $( 768 / 12 = 64 \)$.

---

## Why It Matters

Unlike convolutional networks, which process images locally through filters and build global
information via increasing receptive fields, 
**self-attention connects every patch to every other patch**, enabling the model to reason globally.
This property is essential for tasks like **long-range facial recognition**, where fine local 
details may blur due to atmospheric distortion, but global geometry and symmetry remain
discriminative.

---

## References

[1] A. Vaswani, N. Shazeer, N. Parmar *et al.*,  
*Attention Is All You Need*, NeurIPS 2017. [arXiv:1706.03762](https://arxiv.org/abs/1706.03762)

[2] A. Dosovitskiy, L. Beyer, A. Kolesnikov *et al.*,  
*An Image Is Worth 16×16 Words: Transformers for Image Recognition at Scale*, ICLR 2021. [arXiv:2010.11929](https://arxiv.org/abs/2010.11929)

[3] Z. Liu, Y. Lin, Y. Cao *et al.*,  
*Swin Transformer: Hierarchical Vision Transformer Using Shifted Windows*, ICCV 2021. [arXiv:2103.14030](https://arxiv.org/abs/2103.14030)
