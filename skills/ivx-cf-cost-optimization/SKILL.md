---
name: ivx-cf-cost-optimization
description: Optimize AI inference and infrastructure costs while maintaining quality. Use when analyzing spend, reducing model costs, or designing cost-efficient architectures.
---
# Cost Optimization Skill

## Purpose

Reduce costs without unacceptable quality degradation.

## Cost Drivers

| Category | Typical % | Levers |
|----------|----------|--------|
| LLM API | 40-60% | Model selection, caching, batching |
| GPU compute | 20-35% | Quantization, right-sizing, spot |
| Storage | 5-15% | Lifecycle policies, compression |
| Bandwidth | 5-10% | CDN, compression, region affinity |

## LLM Cost Optimization

1. **Model Selection**: Use smaller/faster models where adequate
   - Simple tasks: Qwen3-8B instead of GPT-4
   - Complex reasoning: Use reasoning model only when needed
2. **Prompt Compression**: Shorter prompts = fewer tokens
3. **Caching**: Cache identical prompts (Redis)
4. **Batching**: Batch requests to same model
5. **Self-hosted**: Use vLLM/Qwen3-30B for high-volume endpoints

## GPU Optimization

1. **Quantization**: FP16 → FP8/INT8 for inference
2. **Continuous Batching**: vLLM-style for higher throughput
3. **Right-sizing**: Match GPU to model size
4. **Spot Instances**: For fault-tolerant batch workloads
5. **Auto-scaling**: Scale to zero when idle (KEDA)

## CF-Specific

- Use `model_gateway.route()` for cost-aware routing
- Prefer self-hosted when `PREFER_SELFHOSTED=true`
- Batch similar pipeline runs (same model, similar prompts)
- Use `warm_video_stack()` + `cool_gpu_service()` lifecycle
- Track cost per pipeline kind in metrics
- Set LiteLLM budget guardrails per team

## Cost-Quality Tradeoff

| Quality Target | Strategy |
|---------------|----------|
| Max quality | Best model, full precision, no compromises |
| Balanced | Appropriate model, FP16, smart caching |
| Cost-sensitive | Smaller model, quantization, heavy caching |
| Draft mode | Fastest model, verify with slower model |
