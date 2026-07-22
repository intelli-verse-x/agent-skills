---
name: ivx-cf-data-versioning
description: Skill for managing dataset versioning and lineage in ML workflows. Use when tracking dataset changes, reproducing experiments, or sharing data artifacts.
---
# Data Versioning

## When to Use

- Tracking dataset changes over time
- Reproducing experiments with exact data
- Collaborating on shared datasets
- Auditing data lineage

## Tools

- **DVC**: Git-like data versioning
- **LakeFS**: Git-like data lake
- **Pachyderm**: Data pipelines with versioning
- **Delta Lake**: Time travel for data
- **S3 + bucket policies**: Simple versioning

## DVC Pattern

### Setup
```bash
# Initialize
dvc init

# Add a dataset
dvc add data/images/

# Track with Git
git add data/images.dvc .gitignore
git commit -m "Add image dataset v1"

# Push to remote storage
dvc remote add -d s3-storage s3://my-bucket/dvc
dvc push
```

### Reproducing
```bash
# Checkout specific version
git checkout v1.0
dvc checkout

# Dataset is now exactly as in v1.0
```

### Pipelines
```yaml
# dvc.yaml
stages:
  preprocess:
    cmd: python scripts/preprocess.py
    deps:
      - scripts/preprocess.py
      - data/raw/
    outs:
      - data/processed/
  
  train:
    cmd: python scripts/train.py
    deps:
      - scripts/train.py
      - data/processed/
    outs:
      - models/final.pt
    params:
      - training.lr
      - training.epochs
```

## Dataset Lineage

Track:
- Raw data source (URL, API, file path)
- Preprocessing steps (code version)
- Splits (train/val/test ratios)
- Augmentations applied
- Derived datasets (embeddings, features)

```python
# dataset_metadata.yaml
name: video-generation-training-v2
source: s3://cf-datasets/raw/videos-2024/
version: 2.1.3
created: 2024-07-07
splits:
  train: 0.8
  val: 0.1
  test: 0.1
preprocessing:
  script: scripts/preprocess_v2.py
  commit: abc123
  steps:
    - resize: [1024, 1024]
    - normalize: imagenet
augmentations:
  - horizontal_flip
  - random_crop
```

## Reproducibility Checklist

- [ ] Dataset version pinned in experiment config
- [ ] Preprocessing code in version control
- [ ] Random seeds fixed
- [ ] Environment documented (Docker image, requirements)
- [ ] Data splits consistent across experiments
- [ ] Augmentation parameters logged

## CF-Specific

- Version prompt datasets (prompt collections, testing sets)
- Version training data for each model iteration
- Track data drift between versions
- Document dataset size and distribution
- Link dataset version to model version in MLflow
