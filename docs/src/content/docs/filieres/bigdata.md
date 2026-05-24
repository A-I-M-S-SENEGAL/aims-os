---
title: Filière Coop — Big Data Analytics
description: Couche Big Data / NLP / Computer Vision / Climate / Databases pour la filière Coop Data Analytics.
---

La filière Coop Big Data ajoute par-dessus la base Regular les outils
nécessaires pour le Data Mining, la NLP, la Computer Vision, les
sciences climat et l'ingénierie de données.

## Métapaquet : `aims-os-bigdata`

Sur Debian existant :

```bash
sudo apt install aims-os-bigdata
```

(Pulls automatiquement `aims-os-math` si pas déjà là.)

## Ce qui est ajouté

### Big Data
`python3-dask` + `python3-distributed` — pandas/numpy parallèle.

PyArrow, Polars et DuckDB ne sont pas dans Trixie main. Installation
à la demande :

```bash
pipx install pyarrow polars duckdb
# ou
mamba install -c conda-forge pyarrow polars duckdb
```

### NLP
`python3-nltk`. spaCy, gensim et HuggingFace Transformers ne sont pas
packagés en version courante par Debian — installez à la demande :

```bash
pipx install spacy gensim transformers
# ou
mamba install -c conda-forge spacy gensim transformers
```

### Computer Vision
`python3-opencv` (cv2). `python3-skimage` est dans aims-os-math pour
la partie scientifique.

### Sciences climat
`python3-xarray`, `python3-netcdf4`, `python3-cartopy` — arrays
labellisés, lecture NetCDF, projections cartographiques sur
matplotlib.

### Clients bases de données
- `postgresql-client` + `python3-psycopg2`
- `mariadb-client`
- `redis-tools`
- `python3-pymongo`

Pas de serveurs : les labs AIMS pointent sur des hosts DB externes.

## Cours couverts

- Case Study from Industries in Big Data
- Data Mining and Big Data Analytics
- Database
- Climate Dynamic, Mathematical Methods for Climate
- Computer Vision
- Generative AI (les libs sont là, les modèles via Transformers)
- Machine Learning (supervisé + non supervisé)
- Natural Language Processing

Voir la [cartographie complète](/courses/mapping/) pour le détail.

## Et l'IA générative ?

PyTorch, TensorFlow, JAX, Keras ne sont **pas** pré-installés. Ces
frameworks évoluent trop vite pour le cycle de release Debian.
Installez à la demande :

```bash
pipx install torch jax tensorflow keras
# ou (recommandé pour CUDA/GPU)
mamba create -n ai python=3.13 pytorch jax tensorflow jupyterlab
mamba activate ai
```
