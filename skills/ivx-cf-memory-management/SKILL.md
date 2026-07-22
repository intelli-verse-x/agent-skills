---
name: ivx-cf-memory-management
description: Optimize memory usage in Python applications and GPU workloads. Use when debugging memory leaks, reducing memory footprint, or designing memory-efficient pipelines.
---
# Memory Management Skill

## Purpose

Keep memory usage predictable and within limits.

## Python Techniques

1. **Generators**: Stream data instead of loading all
2. **Context Managers**: Ensure cleanup (`with` statements)
3. **Weak References**: Avoid reference cycles
4. **Object Pools**: Reuse expensive objects
5. **Profiling**: `tracemalloc`, `memory_profiler`

## GPU Techniques

1. **Gradient Checkpointing**: Trade compute for memory
2. **Mixed Precision**: FP16/FP8 reduces memory 2x
3. **Batch Size**: Tune for memory limit
4. **Clear Cache**: `torch.cuda.empty_cache()` between tasks
5. **Model Sharding**: Split across GPUs

## CF-Specific

- Don't store large blobs in `task["result"]`
- Use `output_path/` for large assets
- Stream video/audio when possible
- Clear GPU memory between pipeline kinds
- Monitor worker memory in K8s

## Targets

| Component | Limit | Alert |
|-----------|-------|-------|
| Worker pod | 80% of request | At 70% |
| GPU VRAM | 90% of capacity | At 85% |
| Redis | 80% of maxmemory | At 75% |

## Quality Gates

- [ ] No memory leaks (stable over 24h)
- [ ] Large objects streamed, not loaded
- [ ] GPU memory cleared between unrelated tasks
- [ ] Memory usage within K8s limits
