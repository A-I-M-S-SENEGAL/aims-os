---
title: Course → tool mapping
description: For each of the 45 courses in the AIMS 2025-2026 curriculum, the AIMS OS metapackage that covers it and the key tools to know.
---

For each of the 45 courses in the AIMS 2025-2026 curriculum, the AIMS
OS metapackage that covers it and the key tools to know. Alphabetical
order.

| Course | Metapackage | Key tools |
|---|---|---|
| Algebraic Topology and Applications | `aims-os-math` | SymPy, scikit-tda (pipx), Maxima |
| Applied PDEs (Modelling) | `aims-os-math` | SciPy, numpy, matplotlib, FFTW |
| Auditing Computer Forensics and Investigation | `aims-os-security` | sleuthkit, foremost, binwalk |
| Bio-Mathematics | `aims-os-math` | biopython, R + tidyverse |
| Case Study from Industries in Big Data | `aims-os-bigdata` | dask, distributed, DBeaver |
| Classical Mechanics | `aims-os-math` | SymPy, GeoGebra, gnuplot |
| Climate Dynamic | `aims-os-bigdata` | xarray, netCDF4, Cartopy |
| Communication English/French | (system) | LibreOffice + FR/EN dictionaries |
| Computational Finance with R | `aims-os-math` | R + tidyverse + rmarkdown, RStudio |
| Computer Network | `aims-os-security` | nmap, tcpdump, scapy, wireshark |
| Computer Security 1: Network Security | `aims-os-security` | nmap, wireshark, john, hashcat |
| Computer Security: Case studies from industries | `aims-os-security` | full security stack |
| Computer Vision | `aims-os-bigdata` | python3-opencv, scikit-image |
| Computing with Python | `aims-os-math` | python3, ipython3, black, mypy, ruff |
| Data Collections | `aims-os-math` | pandas, requests, beautifulsoup4 |
| Data Mining and Big Data Analytics | `aims-os-bigdata` | dask, sklearn, PyArrow/Polars/DuckDB (pipx) |
| Data Preprocessing | `aims-os-math` + `aims-os-bigdata` | pandas, scikit-learn, dask |
| Database | `aims-os-bigdata` | postgresql-client, mariadb-client, redis-tools, DBeaver, psycopg2, pymongo |
| Deep Learning and Neural Networks | (install-on-demand) | `mamba install -c conda-forge pytorch jax tensorflow` |
| Differential Calculus | `aims-os-math` | SymPy, Maxima, GeoGebra |
| Differential Geometry | `aims-os-math` | SymPy, Maxima, GeoGebra |
| Entrepreneurship | (system) | LibreOffice, browsers |
| Ethical Hacking | `aims-os-security` | nmap, wireshark, john, hashcat, aircrack-ng |
| Generative AI | `aims-os-bigdata` + on-demand | NLTK; `pipx install transformers` |
| Graph Theory and Application | `aims-os-math` | networkx, igraph |
| High Dimensional Data Analysis | `aims-os-math` + `aims-os-bigdata` | scikit-learn, dask, statsmodels |
| Linear Algebra and Applications | `aims-os-math` | NumPy, SciPy, R, OpenBLAS / LAPACK |
| Machine Learning (Supervised and Unsupervised) | `aims-os-bigdata` | scikit-learn, dask, mlflow (pipx) |
| Mathematical Logic | `aims-os-math` | SymPy, Maxima |
| Mathematical Methods for Climate | `aims-os-bigdata` + `aims-os-math` | xarray, netCDF4, SciPy |
| Mathematical Model for Network Security | `aims-os-security` + `aims-os-math` | cryptography, SymPy |
| Mathematical Problem Solving | `aims-os-math` | full SymPy / SciPy / NumPy base |
| Measure and Integration | `aims-os-math` | SymPy, scipy.integrate |
| Natural Language Processing | `aims-os-bigdata` + on-demand | NLTK; `pipx install spacy gensim transformers` |
| Numerical Optimization | `aims-os-math` | SciPy.optimize, cvxpy (pipx), Octave optim |
| Physical Problem Solving | `aims-os-math` | SciPy, SymPy, Octave |
| Post Quantum Cryptography | `aims-os-security` | python3-cryptography, pycryptodome |
| Probability and Statistics | `aims-os-math` | NumPy, SciPy.stats, R, statsmodels |
| Quantum Mechanics and Computing | `aims-os-security` + on-demand | python3-cryptography; `pipx install qiskit` |
| Soft Skills | (system) | LibreOffice, browsers |
| Statistical Mechanics | `aims-os-math` | NumPy, SciPy, Octave |
| Theoretical aspects of PDEs | `aims-os-math` | SymPy, SciPy |
| Topology and Functional Analysis | `aims-os-math` | SymPy |
| Topology Data Analysis | `aims-os-math` + on-demand | scikit-tda / gudhi via pipx |
| Web and Android Development | `aims-os-desktop` | Node 22 LTS, npm, Bun, Deno, OpenJDK 21, Gradle, Kotlin, adb |

## "install-on-demand" — why?

Some tools move faster than the Debian release cycle (PyTorch,
TensorFlow, JAX, Qiskit, spaCy, gensim, Transformers). AIMS OS
deliberately doesn't pin them to a Debian version that's often
6-12 months old; students install the current upstream version with
`pipx` or `mamba`.

Both `pipx` and Miniforge (`mamba`) are installed by default in
`aims-os-math` / `aims-os-core`.
