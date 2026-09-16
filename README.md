# Visual Cortex Plasticity: Receptive Field Expansion Model

## Overview

This repository contains tools to explore how receptive fields in the primary visual cortex (V1) might adapt after a lesion. The goal is to better understand how cortical activity could reorganize to support recovery. The project combines simple computational models, neural simulations, and information theory measures.

## Main Components

### Receptive Field Models  
MATLAB code for simulating 2D Gaussian receptive fields, which expand and shift asymmetrically toward the lesioned area.

### Plasticity Model  
A basic model that adjusts receptive fields over time to mimic plastic changes in response to injury.

### Neural Simulations  
Uses Izhikevich neuron models to simulate how local activity evolves near the lesion site.

### Information Theory Metrics  
Includes tools to compute permutation entropy, complexity, and causal measures based on ordinal patterns.

## Contributions

This is a work in progress and open to collaboration. If you're interested in neural plasticity, feel free to explore, modify, and extend the code. Contributions and feedback are always welcome.

---

## Folder Structure

### `Information/`  
Includes functions for computing probability distributions using the Bandt and Pompe method, as well as entropy and complexity measures. These are useful for analyzing patterns and causal relationships in time series data.

If you have any questions or ideas, feel free to open an issue or start a discussion.

---

## Related Work

This project corresponds to the manuscript published in *The European Physical Journal B*:

**Information flow and plasticity: modeling visual cortex recovery after stroke**  
by Natalí Guisande, Roman Baravalle, and Fernando Montani  

* **Paper (View-Only / SharedIt):** [Read Full-Text Article](https://rdcu.be/riLjRByywt3a)
* **DOI:** [https://doi.org/10.1140/epjb/s10051-026-01246-8](https://doi.org/10.1140/epjb/s10051-026-01246-8)

