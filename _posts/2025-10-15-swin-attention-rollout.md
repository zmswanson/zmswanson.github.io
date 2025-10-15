---
layout: post
title: "Swin Transformer Attention Rollout Visualization"
description: "A detailed explanation and visualization of my extended attention rollout algorithm for hierarchical and windowed Swin Transformers."
categories: [research, vision-transformers, interpretability, attention]
image: /assets/images/swin_attention_stages.png
---

## Overview

This post summarizes my work on **extending attention rollout to hierarchical and windowed Swin**
**Transformers**, as described in my Master's thesis —
[*Analysis of Vision Transformers and Domain Adaptation in Long-Range Facial Recognition*](https://digitalcommons.unl.edu/elecengtheses/159/).  

The **goal** of this work was to visualize how information propagates across Swin’s hierarchical
layers, revealing the internal flow of attention from localized windows to a unified global
representation. The algorithm and visualizations were implemented in
[**zmswanson/swin-attention-rollout**](https://github.com/zmswanson/swin-attention-rollout).

---

## From Global to Hierarchical Attention

Traditional Vision Transformers (ViT) apply **global self-attention** where each token attends to
every other token in the image sequence. This structure enables direct global reasoning, but its
computational cost scales quadratically with image size.

The **Swin Transformer** addresses this by applying attention within **local windows** and
introducing **shifted windows** between alternating layers to create connections across windows.
These shifts allow neighboring regions to exchange information without the full cost of global
attention.

![Swin Window Diagram](/assets/images/swin_attention_diagram.png){: .center }

This shifted-window mechanism forms the basis of a **hierarchical transformer**, where deeper stages
merge tokens into coarser representations, producing multi-scale features similar to CNN feature
pyramids — but learned entirely via self-attention.

The video below demonstrates how the windowed attention produces a unique attention matrix pattern.
For the traditional ViT, the attention matrix would be completely white because it is comparing
every patch to every other patch. The Swin transformer on the other hand produces a very sparse
attention matrix because it is only comparing patches within the given window. This is why special
care is required to accurately rollout the attention scores for visualization. Furthermore, the
video demonstrates how shifting the window and downsampling modify the attention matrix, which
further necessitates the need for special functionality for attention rollout.

<figure style="text-align:center;">
  <video controls autoplay loop muted playsinline width="800">
    <source src="/assets/videos/swin_attention_rollout.mp4" type="video/mp4">
    Your browser does not support the video tag.
  </video>
</figure>

---

## Challenge: Rollout for Hierarchical Models

The classical **attention rollout** algorithm (Abnar & Zuidema 2020; Chefer et al. 2021) was
designed for architectures with fixed token indexing across layers. In those models, the
correspondence between tokens is one-to-one from input to output.However, in Swin Transformers:

- Token positions **change** due to window partitioning and shifting.  
- Tokens are **merged** hierarchically, reducing spatial resolution.
- Local windows prevent direct computation of global attention matrices.  

As a result, applying standard rollout directly yields discontinuous and incomplete attention maps.

---

## Window-Aware Rollout Algorithm

To overcome these challenges, I developed a **window-aware rollout framework**  
that reconstructs full-image attention maps from Swin’s local attention matrices.  
The method proceeds in three main stages:

1. **Global Index Reconstruction**  
   - Each attention window is re-mapped to global coordinates using a *patch index image* that records
   token locations prior to merging and shifting.

2. **Hierarchical Upsampling**  
   - Attention maps are upsampled between stages so that each level aligns spatially with the input resolution.
   This preserves continuity between coarse and fine attention representations.

3. **Layerwise Aggregation**  
   - Normalized cumulative products of attention matrices are computed across layers,
   producing a composite map that expresses end-to-end attention flow through the network.

The process yields interpretable **attention rollout visualizations** that are spatially coherent across stages.

---

## Attention across Swin Stages

The shark image below visually explains the progression of normal-shifted pair attentions with
increasing scale and how these pairs combine to produce the collective attention map at the
top-right. It is interesting how each pair attends to different areas of the image but together they
attend to the regions of the image that humans would consider important for understanding what the
image contains. It appears that each block is able to explore locally, but collectively the blocks
are working together to identify the most important features globally.

![Swin Attention Shark Diagram](/assets/images/shark_attention.png){: .center }

This visualization conveys the **progressive accumulation of global information**  
despite Swin’s localized attention computations.

---

## Related Work

**Abnar & Zuidema (2020)** introduced *attention rollout* for transformer interpretability by
propagating attention matrices through the network’s layers. **Chefer et al. (2021)** extended this
concept to include gradient-based relevance. Both methods assume globally indexed tokens and uniform
layer structure — conditions that do not hold in hierarchical architectures such as Swin, CvT, or
PVT.

The **window-aware rollout** implemented here generalizes these approaches by tracking token
correspondences across window shifts and hierarchical merges. It thereby enables meaningful
visualization of attention propagation in models where spatial locality and token resolution change
over depth.

> 🔗 **Implementation:** [github.com/zmswanson/swin-attention-rollout](https://github.com/zmswanson/swin-attention-rollout)

---

## References

- **Z. M. Swanson**, [*Analysis of Vision Transformers and Domain Adaptation in Long-Range Facial Recognition*](https://digitalcommons.unl.edu/elecengtheses/159/), M.S. Thesis, University of Nebraska–Lincoln, 2025.  
- **Z. Liu et al.**, “Swin Transformer: Hierarchical Vision Transformer Using Shifted Windows,” *ICCV*, 2021.  
- **A. Dosovitskiy et al.**, “An Image is Worth 16×16 Words: Transformers for Image Recognition at Scale,” *ICLR*, 2021.  
- **H. Chefer et al.**, “Transformer Interpretability Beyond Attention Visualization,” *CVPR*, 2021.  
- **S. Abnar and W. Zuidema**, “Quantifying Attention Flow in Transformers,” *ACL*, 2020.  
