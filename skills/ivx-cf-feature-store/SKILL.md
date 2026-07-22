---
name: ivx-cf-feature-store
description: Skill for designing and using feature stores in ML pipelines. Use when sharing features across models, ensuring consistency between training and serving.
---
# Feature Store

## When to Use

- Sharing features across multiple models
- Ensuring training/serving consistency
- Real-time and batch feature serving
- Feature versioning and lineage

## Architecture

```
Raw Data ──► Feature Engineering ──► Feature Store ──► Training / Serving
                      │
                      ▼
                Feature Registry
```

## Tools

| Tool | Type | Best For |
|------|------|----------|
| Feast | Open source | Batch + streaming, multiple backends |
| Tecton | Managed | Enterprise, real-time features |
| SageMaker Feature Store | AWS native | AWS-only workloads |
| Databricks Feature Store | Databricks | Databricks ecosystem |

## Feast Pattern

### Define Features
```python
from feast import Entity, Feature, FeatureView, ValueType
from feast.types import Float, Int64

# Entity
video = Entity(
    name="video_id",
    value_type=ValueType.STRING,
    description="Video ID",
)

# Feature View
video_features = FeatureView(
    name="video_metadata",
    entities=["video_id"],
    ttl=timedelta(days=1),
    features=[
        Feature(name="duration", dtype=Int64),
        Feature(name="resolution", dtype=Int64),
        Feature(name="frame_count", dtype=Int64),
    ],
    batch_source=video_source,
)
```

### Materialize
```python
from feast import FeatureStore

store = FeatureStore(repo_path=".")

# Materialize latest features (batch)
store.materialize(
    start_date=datetime(2024, 7, 1),
    end_date=datetime.now(),
)

# Get features for training
training_df = store.get_historical_features(
    entity_df=pd.DataFrame({"video_id": video_ids, "event_timestamp": timestamps}),
    features=["video_metadata:duration", "video_metadata:resolution"],
).to_df()
```

### Online Serving
```python
# Get current features for prediction (low latency)
features = store.get_online_features(
    features=["video_metadata:duration", "video_metadata:resolution"],
    entity_rows=[{"video_id": "abc123"}],
).to_dict()
# 5ms latency, used in production
```

## Feature Engineering

### Online vs Offline
| Feature Type | Example | Serving |
|-------------|---------|---------|
| Raw attribute | Video duration | Offline + Online |
| Aggregated | Avg watch time | Offline + Online (precomputed) |
| Real-time | Current viewers | Online only |
| Derived | Embedding | Offline + Online |

### Consistency
- Same transformation code for training and serving
- Unit tests for feature transforms
- Shadow serving to validate

## CF-Specific

- Store video metadata features (duration, resolution, tags)
- User preference features for personalization
- Content embedding features (text, image, audio)
- Pipeline performance features (latency, cost)
- Version features with model versions

## Anti-Patterns

- ❌ Training and serving code paths different
- ❌ No feature versioning
- ❌ Storing PII in feature store
- ❌ No TTL on features
- ❌ No monitoring for drift
