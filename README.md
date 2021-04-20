# Adaptive-Sampling-for-Fast-Constrained-Maximization-of-Submodular-Functions.

This repository provides a python implementation of our [AISTATS 2020](http://proceedings.mlr.press/v130/quinzan21a.html) paper titled ''Adaptive Sampling for Fast Constrained Maximization of Submodular Functions''.

## Abstract

Several large-scale machine learning tasks, such as data summarization, can be approached by maximizing functions that satisfy submodularity. These optimization problems often involve complex side constraints, imposed by the underlying application. In this paper, we develop an algorithm with poly-logarithmic adaptivity for non-monotone submodular maximization under general side constraints. The adaptive complexity of a problem is the minimal number of sequential rounds required to achieve the objective.
Our algorithm is suitable to maximize a non-monotone submodular function under a p-system side constraint, and it achieves a $(p + O(p^(1/2)))$-approximation for this problem, after only poly-logarithmic adaptive rounds and polynomial queries to the valuation oracle function. Furthermore, our algorithm achieves a $(p + O(1))$-approximation when the given side constraint is a p-extendible system.
This algorithm yields an exponential speed-up, with respect to the adaptivity, over any other known constant-factor approximation algorithm for this problem. It also competes with previous known results in terms of the query complexity. We perform various experiments on various real-world applications. We find that, in comparison with commonly used heuristics, our algorithm performs better on these instances.

## Files and folders

This folder contains all algorithms and submodular objectives used to run the experiments.

The code for each tested algorithm is located in the following folders:

- FANTOM:       it contains the code for FANTOM;
- Greedy:       it contains the code for the REPEATEDGREEDY;
- Sampling:     it contains the code for the REPSAMPL algorithm;
- fastSGS:      it contains the code for the FASTSGS algorithm;
- sampleGreedy: it contains the code for the SAMPLEGREEDY algorithm;


The folder submodular-objective contains all files for the submodular objective to be optimized:

- DPP:          a class to optimize a determinantal point process objective;
- d_optimality: a class to optimize the bayesian D-optimality objective, via entropy maximization.

## Requirements

We run the matlab script with Matlab_R2018b, although it might work with earlier versions. No additional packages are required. 
