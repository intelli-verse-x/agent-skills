---
name: ivx-cf-experiment-tracking
description: Track and manage machine learning experiments. Use when running model training, comparing hyperparameters, or managing experiment artifacts.
---
# Experiment Tracking Skill

## Purpose

Track ML experiments systematically for reproducibility and comparison.

## Experiment Structure

```markdown
## Experiment: [Name]

### Hypothesis
[What we expect to happen]

### Method
- Model: [architecture, checkpoint]
- Dataset: [name, preprocessing, splits]
- Hyperparameters: [list with values]
- Hardware: [GPU type, count]

### Metrics
- Primary: [metric, target]
- Secondary: [list]

### Results
[Tables, charts, observations]

### Conclusion
[Supported / Not supported / Inconclusive]

### Next Steps
[Follow-up experiments]
```

## Tracking

| Tool | Use Case |
|------|----------|
| Weights & Biases | Experiment logs, metrics, artifacts |
| MLflow | Model registry, parameter tracking |
| Custom | JSON/CSV logs, S3 artifacts |

## CF-Specific

- Log all pipeline runs with parameters
- Track cost per experiment
- Version prompts with results
- Compare model outputs side-by-side
- Store artifacts in S3 with metadata

## Quality Gates

- [ ] All hyperparameters logged
- [ ] Random seeds fixed
- [ ] Baseline comparison included
- [ ] Statistical significance checked
- [ ] Artifacts versioned and accessible
