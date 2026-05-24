---
title: Coop track — Big Data Analytics
description: Big Data / NLP / Computer Vision / Climate / Databases layer for the Coop Data Analytics track.
---

The Coop Big Data track adds on top of the Regular baseline the tools
needed for Data Mining, NLP, Computer Vision, climate sciences and
data engineering.

## Metapackage: `aims-os-bigdata`

On an existing Debian:

```bash
sudo apt install aims-os-bigdata
```

(Pulls `aims-os-math` automatically if not already there.)

## What's added

### Big Data
`python3-dask` + `python3-distributed` — parallel pandas / numpy.

PyArrow, Polars and DuckDB are not in Trixie main. Install on demand:

```bash
pipx install pyarrow polars duckdb
# or
mamba install -c conda-forge pyarrow polars duckdb
```

### NLP
`python3-nltk`. spaCy, gensim and HuggingFace Transformers are not
packaged in current versions by Debian — install on demand:

```bash
pipx install spacy gensim transformers
# or
mamba install -c conda-forge spacy gensim transformers
```

### Computer Vision
`python3-opencv` (cv2). `python3-skimage` is in aims-os-math for the
scientific side.

### Climate sciences
`python3-xarray`, `python3-netcdf4`, `python3-cartopy` — labelled
arrays, NetCDF reading, cartographic projections on matplotlib.

### Database clients
- `postgresql-client` + `python3-psycopg2`
- `mariadb-client`
- `redis-tools`
- `python3-pymongo`

No daemons: AIMS labs point at external DB hosts.

## Courses covered

- Case Study from Industries in Big Data
- Data Mining and Big Data Analytics
- Database
- Climate Dynamic, Mathematical Methods for Climate
- Computer Vision
- Generative AI (the libs are here, the models via Transformers)
- Machine Learning (supervised + unsupervised)
- Natural Language Processing

See the [full mapping](/en/courses/mapping/) for the breakdown.

## And generative AI?

PyTorch, TensorFlow, JAX, Keras are **not** pre-installed. These
frameworks move faster than the Debian release cycle. Install on demand:

```bash
pipx install torch jax tensorflow keras
# or (recommended for CUDA/GPU)
mamba create -n ai python=3.13 pytorch jax tensorflow jupyterlab
mamba activate ai
```
