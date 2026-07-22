---
name: ivx-cf-benchmarking
description: Design and execute performance benchmarks for models and systems. Use when measuring throughput, latency, or comparing system variants.
---
# Benchmarking Skill

## Purpose

Measure performance objectively and reproducibly.

## Benchmark Design

1. **Define metric**: Latency? Throughput? Accuracy? Cost?
2. **Choose workload**: Representative, diverse, stressful
3. **Control variables**: Same hardware, same data, same config
4. **Run multiple times**: Report mean + stddev / percentiles
5. **Document everything**: Hardware, software, versions, methodology

## Metrics

| Metric | Tool | Target |
|--------|------|--------|
| Latency (P50/P95/P99) | wrk, k6, custom | Per SLO |
| Throughput | wrk, locust | Per SLO |
| GPU util | DCGM, nvidia-smi | > 70% |
| Memory | psutil, py-spy | < 80% |
| Accuracy | Eval harness | Per task |

## CF Benchmarks

- Pipeline end-to-end latency per kind
- Model inference latency per model
- Cost per 1K requests per pipeline
- Worker throughput (tasks/hour)
- GPU utilization per node

## Process

1. Baseline: Measure current state
2. Change: Implement optimization
3. Measure: Run benchmark again
4. Compare: Statistical significance test
5. Document: Results in PR / ADR

## Quality Gates

- [ ] Warmup before measurement
- [ ] Multiple runs for variance
- [ ] Representative workload
- [ ] Documented hardware/config
- [ ] Statistical significance (p < 0.05)
