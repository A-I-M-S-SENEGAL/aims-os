---
title: Cartographie cours → outils
description: Pour chacun des 45 cours du curriculum AIMS 2025-2026, le métapaquet AIMS OS qui le couvre et les outils-clés à connaître.
---

Pour chacun des 45 cours du curriculum 2025-2026, le métapaquet AIMS OS
qui le couvre et les outils-clés à connaître. Ordre alphabétique.

| Cours | Métapaquet | Outils-clés |
|---|---|---|
| Algebraic Topology and Applications | `aims-os-math` | SymPy, scikit-tda (pipx), Maxima |
| Applied PDEs (Modelling) | `aims-os-math` | SciPy, numpy, matplotlib, FFTW |
| Auditing Computer Forensics and Investigation | `aims-os-security` | sleuthkit, foremost, binwalk |
| Bio-Mathematics | `aims-os-math` | biopython, R + tidyverse |
| Case Study from Industries in Big Data | `aims-os-bigdata` | dask, distributed, DBeaver |
| Classical Mechanics | `aims-os-math` | SymPy, GeoGebra, gnuplot |
| Climate Dynamic | `aims-os-bigdata` | xarray, netCDF4, Cartopy |
| Communication English/French | (système) | LibreOffice + dicos FR/EN |
| Computational Finance with R | `aims-os-math` | R + tidyverse + rmarkdown, RStudio |
| Computer Network | `aims-os-security` | nmap, tcpdump, scapy, wireshark |
| Computer Security 1: Network Security | `aims-os-security` | nmap, wireshark, john, hashcat |
| Computer Security: Case studies from industries | `aims-os-security` | toute la stack security |
| Computer Vision | `aims-os-bigdata` | python3-opencv, scikit-image |
| Computing with Python | `aims-os-math` | python3, ipython3, black, mypy, ruff |
| Data Collections | `aims-os-math` | pandas, requests, beautifulsoup4 |
| Data Mining and Big Data Analytics | `aims-os-bigdata` | dask, sklearn, PyArrow/Polars/DuckDB (pipx) |
| Data Preprocessing | `aims-os-math` + `aims-os-bigdata` | pandas, scikit-learn, dask |
| Database | `aims-os-bigdata` | postgresql-client, mariadb-client, redis-tools, DBeaver, psycopg2, pymongo |
| Deep Learning and Neural Networks | (install-on-demand) | `mamba install -c conda-forge pytorch jax tensorflow` |
| Differential Calculus | `aims-os-math` | SymPy, Maxima, GeoGebra |
| Differential Geometry | `aims-os-math` | SymPy, Maxima, GeoGebra |
| Entrepreneurship | (système) | LibreOffice, navigateurs |
| Ethical Hacking | `aims-os-security` | nmap, wireshark, john, hashcat, aircrack-ng |
| Generative AI | `aims-os-bigdata` + on-demand | NLTK ; `pipx install transformers` |
| Graph Theory and Application | `aims-os-math` | networkx, igraph |
| High Dimensional Data Analysis | `aims-os-math` + `aims-os-bigdata` | scikit-learn, dask, statsmodels |
| Linear Algebra and Applications | `aims-os-math` | NumPy, SciPy, R, OpenBLAS / LAPACK |
| Machine Learning (Supervised and Unsupervised) | `aims-os-bigdata` | scikit-learn, dask, mlflow (pipx) |
| Mathematical Logic | `aims-os-math` | SymPy, Maxima |
| Mathematical Methods for Climate | `aims-os-bigdata` + `aims-os-math` | xarray, netCDF4, SciPy |
| Mathematical Model for Network Security | `aims-os-security` + `aims-os-math` | cryptography, SymPy |
| Mathematical Problem Solving | `aims-os-math` | toute la base SymPy / SciPy / NumPy |
| Measure and Integration | `aims-os-math` | SymPy, scipy.integrate |
| Natural Language Processing | `aims-os-bigdata` + on-demand | NLTK ; `pipx install spacy gensim transformers` |
| Numerical Optimization | `aims-os-math` | SciPy.optimize, cvxpy (pipx), Octave optim |
| Physical Problem Solving | `aims-os-math` | SciPy, SymPy, Octave |
| Post Quantum Cryptography | `aims-os-security` | python3-cryptography, pycryptodome |
| Probability and Statistics | `aims-os-math` | NumPy, SciPy.stats, R, statsmodels |
| Quantum Mechanics and Computing | `aims-os-security` + on-demand | python3-cryptography ; `pipx install qiskit` |
| Soft Skills | (système) | LibreOffice, navigateurs |
| Statistical Mechanics | `aims-os-math` | NumPy, SciPy, Octave |
| Theoretical aspects of PDEs | `aims-os-math` | SymPy, SciPy |
| Topology and Functional Analysis | `aims-os-math` | SymPy |
| Topology Data Analysis | `aims-os-math` + on-demand | scikit-tda / gudhi via pipx |
| Web and Android Development | `aims-os-desktop` | Node 22 LTS, npm, Bun, Deno, OpenJDK 21, Gradle, Kotlin, adb |

## "install-on-demand" — pourquoi ?

Certains outils évoluent trop vite pour le cycle de release Debian
(PyTorch, TensorFlow, JAX, Qiskit, spaCy, gensim, Transformers).
AIMS OS ne les épingle volontairement pas à une version Debian
souvent vieille de 6-12 mois ; les étudiants installent la version
upstream actuelle avec `pipx` ou `mamba`.

`pipx` et Miniforge (`mamba`) sont tous deux installés par défaut
dans `aims-os-math` / `aims-os-core`.
