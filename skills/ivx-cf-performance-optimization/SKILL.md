---
name: ivx-cf-performance-optimization
description: Optimize code and systems for speed, memory, and cost efficiency. Use when profiling slow code, reducing latency, optimizing GPU usage, or lowering infrastructure costs.
---
# Performance Optimization Skill

## Purpose

Make systems fast, efficient, and cost-effective without sacrificing correctness.

## Optimization Loop

1. **Measure**: Profile to find actual bottlenecks
2. **Hypothesize**: Identify root cause
3. **Implement**: Make targeted change
4. **Validate**: Measure improvement (or lack thereof)
5. **Document**: Record learnings

## Profiling Tools

| Layer | Tool | Metric |
|-------|------|--------|
| Python | cProfile, py-spy | CPU time per function |
| Async | aiomonitor | Event loop blocking |
| DB | EXPLAIN ANALYZE, pg_stat_statements | Query time |
| GPU | Nsight, PyTorch profiler | Kernel time, memory |
| API | wrk, k6, locust | Latency, throughput |

## Common Bottlenecks

### API Latency
- N+1 queries → Batch / JOIN
- Missing indexes → Add covering indexes
- Large payloads → Pagination, field selection
- Sync external calls → Async + caching

### GPU Inference
- Small batches → Continuous batching
- Memory bandwidth → Quantization (FP8/INT8)
- Kernel overhead → TensorRT compilation
- Cold start → Warm pools, pre-loading

### Memory
- Large objects → Streaming, generators
- Memory leaks → Profile allocations
- Redis bloat → Key TTLs, eviction policies
- Task store → Don't store large blobs in `result`

## CF-Specific

- Use `model_gateway.get_pricing_summary()` for cost estimates
- Batch pipeline stages when independent
- Cache prompt registry lookups
- Stream large files, don't load into memory
- Use Redis pipeline for multiple operations
- Profile pipeline runs: `utils/pipeline/run_memory.py`

## Targets

| Metric | Target | Measurement |
|--------|--------|-------------|
| API P95 | < 200ms | Load test |
| Pipeline P95 | < 5 min | Production metrics |
| GPU utilization | > 70% | NVIDIA DCGM |
| Memory growth | 0% over 24h | Memory profiler |
| Cost per 1K req | Documented | Cloud billing |
