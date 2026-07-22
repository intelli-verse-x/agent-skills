---
name: ivx-cf-evaluation
description: Design and implement evaluation harnesses for models, agents, and code. Use when creating benchmarks, designing eval metrics, or comparing system outputs.
---
# Evaluation Skill

## Purpose

Build rigorous, reproducible evaluation systems that measure what matters.

## Evaluation Types

### Deterministic (Code/Logic)
- Unit tests: Pass/fail on specific inputs
- Integration tests: End-to-end correctness
- Lint/static analysis: Style and pattern compliance

### Model-Based (LLM-as-Judge)
- Rubric-based grading: Score 1-5 on dimensions
- Pairwise comparison: A vs B preference
- Reference matching: Output vs gold standard

### Human
- Expert annotation: Domain experts rate quality
- User feedback: Thumbs up/down, NPS
- A/B testing: Metric comparison in production

## Grader Design

1. **Decouple from Optimizer**: Evaluator must be independent
2. **Clear Rubrics**: Specific criteria, not vague impressions
3. **Calibration**: Multiple graders on same sample, measure agreement
4. **Edge Cases**: Include adversarial and corner cases
5. **Statistical Significance**: Sufficient sample size (n ≥ 30 minimum)

## Rubric Example: Code Quality

| Dimension | 1 (Poor) | 3 (OK) | 5 (Excellent) |
|-----------|----------|--------|---------------|
| Correctness | Fails tests | Passes most | Passes all, handles edge cases |
| Readability | Unclear naming | Mostly clear | Self-documenting, well-organized |
| Efficiency | O(n²) when O(n) possible | Reasonable | Optimal algorithm, minimal overhead |
| Maintainability | Hard to modify | Some coupling | Clean boundaries, easy to extend |

## CF-Specific Evals

### Pipeline Quality
- Task completion rate
- Output quality (human rating 1-5)
- Cost per successful run
- End-to-end latency (P50, P95)

### Prompt Quality
- Success rate on eval set
- Token efficiency (tokens per success)
- Consistency (variance across seeds)
- A/B vs previous version

### Model Comparison
- Accuracy on relevant benchmarks
- Latency distribution
- Cost per inference
- Error analysis (failure modes)

## Best Practices

- Version eval datasets with code
- Track eval results over time (regression detection)
- Automate eval runs in CI
- Make evals fast enough to run frequently
- Document eval methodology in PRs
