---
title: Filière Regular — Sciences Mathématiques
description: La couche scientifique de base d'AIMS OS, livrée à toute la promotion (Regular + Coop).
---

La filière Regular forme le tronc commun de toute la promotion AIMS.
Le métapaquet `aims-os-math` rassemble les outils dont vous avez besoin
pour les cours de mathématiques pures, modélisation, calcul scientifique,
HPC et rédaction de mémoire.

## Métapaquet : `aims-os-math`

Installé par défaut sur l'ISO. Sur Debian existant :

```bash
sudo apt install aims-os-math
```

## Ce qui est dedans

### Python scientifique
NumPy, SciPy, SymPy, pandas, matplotlib, seaborn, scikit-learn,
statsmodels, networkx, mpi4py (HPC), biopython (modélisation bio),
scikit-image, igraph, rpy2 (R depuis Python), pytables (HDF5),
pygments, reportlab.

### Jupyter
jupyter-notebook, jupyter-server, ipywidgets, nbconvert. La UI
JupyterLab elle-même n'est pas packagée par Debian — installez à la
demande avec `pipx install jupyterlab` ou `mamba install -c
conda-forge jupyterlab`.

### Calcul formel et numérique
Maxima + wxMaxima, GNU Octave avec les modules symbolic / statistics /
optim / control / signal.

SageMath n'est pas dans Trixie. Le chemin recommandé :

```bash
mamba install -c conda-forge sagemath
```

(Miniforge est déjà installé dans `/opt/miniforge3` par
`aims-os-core`.)

### R
r-base, r-recommended, tidyverse, ggplot2, dplyr, knitr, rmarkdown.

### LaTeX
TeX Live full, avec les language packs français, anglais, autres
(couvre les langues africaines : wolof, swahili, amharic, hausa,
twi) et arabe. TeXstudio + biber + latexmk + dvipng pour la chaîne
mémoire.

### Géométrie & plotting
GeoGebra, gnuplot.

### C / C++ / Fortran
gdb, valgrind, OpenBLAS, LAPACK, FFTW, HDF5, GMP, MPFR — toute la
chaîne pour compiler du code numérique.

### Qualité de code Python
black (formatter), python3-mypy (type checker). ruff (linter rapide
en Rust) est installé séparément via pipx au build de l'ISO.

## Cours couverts

`aims-os-math` couvre directement les cours suivants du curriculum :

- Algebraic Topology and Applications
- Applied PDEs (Modelling)
- Bio-Mathematics
- Classical Mechanics
- Computational Finance with R
- Computing with Python
- Data Collections, Data Preprocessing
- Differential Calculus, Differential Geometry
- Graph Theory and Application
- High Dimensional Data Analysis
- Linear Algebra and Applications
- Mathematical Logic, Mathematical Methods for Climate
- Mathematical Problem Solving
- Measure and Integration
- Numerical Optimization
- Physical Problem Solving, Probability and Statistics
- Statistical Mechanics, Theoretical aspects of PDEs
- Topology and Functional Analysis, Topology Data Analysis

Voir la [cartographie complète des cours](/courses/mapping/) pour le
mapping précis.

## Et les filières Coop ?

Les paquets `aims-os-bigdata` et `aims-os-security` dépendent
explicitement de `aims-os-math`. Si vous êtes en Coop Big Data ou
Coop Security, installer votre paquet filière pulls automatiquement
toute la base Regular.
