---
name: ivx-cf-gpu-optimization
description: Optimize GPU kernels, memory usage, and inference throughput for ML workloads. Use when profiling GPU code, optimizing CUDA kernels, or designing GPU-efficient models.
---
# GPU Optimization Skill

## Purpose

Maximize GPU utilization and minimize inference latency.

## Techniques

1. **Quantization**: FP32 → FP16/FP8/INT8 (2-4x speedup)
2. **Kernel Fusion**: Combine operations to reduce memory traffic
3. **Continuous Batching**: vLLM-style batching for LLMs
4. **Speculative Decoding**: Draft model + verification
5. **KV Cache Optimization**: PagedAttention, prefix caching
6. **Tensor Parallelism**: Multi-GPU for large models
7. **Pipeline Parallelism**: Overlap compute and communication

## Profiling

- **PyTorch Profiler**: Kernel-level timing
- **Nsight Systems**: End-to-end trace
- **DCGM**: GPU-level metrics (utilization, memory, bandwidth)

## Targets

| Metric | Target |
|--------|--------|
| GPU utilization | > 70% |
| Memory bandwidth | > 60% of theoretical |
| Tensor core usage | > 50% |
| Inference latency | Within SLO budget |

## CF-Specific

- Use vLLM for self-hosted LLM serving
- Warm GPU pools for cold start elimination
- MIG for sharing H100s across services
- Spot instances for batch workloads
- Monitor with DCGM + Prometheus
