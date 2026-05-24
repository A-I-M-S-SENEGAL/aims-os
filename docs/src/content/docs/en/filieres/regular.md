---
title: Regular track — Mathematical Sciences
description: The scientific baseline of AIMS OS, shipped to the whole cohort (Regular + Coop).
---

The Regular track is the common foundation for the whole AIMS cohort.
The `aims-os-math` metapackage gathers the tools you need for the
pure math, modelling, scientific computing, HPC and thesis-writing
courses.

## Metapackage: `aims-os-math`

Installed by default on the ISO. On an existing Debian:

```bash
sudo apt install aims-os-math
```

## What's inside

### Scientific Python
NumPy, SciPy, SymPy, pandas, matplotlib, seaborn, scikit-learn,
statsmodels, networkx, mpi4py (HPC), biopython (bio modelling),
scikit-image, igraph, rpy2 (R from Python), pytables (HDF5),
pygments, reportlab.

### Jupyter
jupyter-notebook, jupyter-server, ipywidgets, nbconvert. The
JupyterLab UI itself is not packaged by Debian. Install on demand
with `pipx install jupyterlab` or `mamba install -c conda-forge
jupyterlab`.

### Computer algebra and numerical computing
Maxima + wxMaxima, GNU Octave with the symbolic / statistics /
optim / control / signal modules.

SageMath is not in Trixie. The recommended path:

```bash
mamba install -c conda-forge sagemath
```

(Miniforge already ships in `/opt/miniforge3` via `aims-os-core`.)

### R
r-base, r-recommended, tidyverse, ggplot2, dplyr, knitr, rmarkdown.

### LaTeX
TeX Live full, with the French, English, other-languages (covers
African languages: wolof, swahili, amharic, hausa, twi) and arabic
language packs. TeXstudio + biber + latexmk + dvipng for the thesis
toolchain.

### Geometry and plotting
GeoGebra, gnuplot.

### C / C++ / Fortran
gdb, valgrind, OpenBLAS, LAPACK, FFTW, HDF5, GMP, MPFR — the whole
chain for compiling numerical code.

### Python code quality
black (formatter), python3-mypy (type checker). ruff (fast Rust
linter) is installed separately via pipx at ISO build time.

## Courses covered

`aims-os-math` directly covers:

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

See the [full course mapping](/en/courses/mapping/) for
the precise breakdown.

## And the Coop tracks?

The `aims-os-bigdata` and `aims-os-security` packages explicitly
depend on `aims-os-math`. If you are in Coop Big Data or Coop
Security, installing your track package pulls the whole Regular base
automatically.
