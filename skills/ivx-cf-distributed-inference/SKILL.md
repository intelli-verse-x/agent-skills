---
name: ivx-cf-distributed-inference
description: Skill for scaling model inference across multiple GPUs and nodes. Use when throughput is the bottleneck and single-GPU inference is insufficient.
---
# Distributed Inference

## When to Use

- Batch processing at scale (1000s of videos/images)
- Real-time serving with high QPS
- Model parallelism for large models
- Pipeline parallelism for multi-stage inference
- Cost optimization via spot instances

## Patterns

### 1. Data Parallel (Simplest)
Multiple GPUs process independent batches.

```python
# Ray Serve
from ray import serve
from starlette.requests import Request

@serve.deployment(
    num_replicas=4,
    ray_actor_options={"num_gpus": 1},
)
class Text2ImageModel:
    def __init__(self):
        self.pipe = load_pipeline().to("cuda")
    
    async def __call__(self, request: Request):
        batch = await request.json()
        return self.pipe(batch["prompts"]).images
```

### 2. Pipeline Parallel
Split model across GPUs (for models > GPU memory).

```python
from accelerate import load_checkpoint_and_dispatch

model = load_checkpoint_and_dispatch(
    model,
    checkpoint=weights_path,
    device_map="auto",  # Automatically split across GPUs
    max_memory={0: "24GiB", 1: "24GiB"},
)
```

### 3. Tensor Parallel (Megatron/DeepSpeed)
Split tensors across GPUs for large models.

```python
# DeepSpeed inference
ds_config = {
    "tensor_parallel": {"size": 4},
    "dtype": "fp16",
}

model = deepspeed.init_inference(
    model,
    config=ds_config,
)
```

## Orchestration

### Ray Serve (Multi-Model)
```python
@serve.deployment
class PipelineRouter:
    async def __call__(self, request):
        req = await request.json()
        
        if req["model"] == "flux":
            return await self.flux.handle(request)
        elif req["model"] == "wan":
            return await self.wan.handle(request)
```

### K8s + KEDA (Autoscaling)
```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: inference-scaler
spec:
  scaleTargetRef:
    name: inference-deployment
  triggers:
  - type: prometheus
    metadata:
      serverAddress: http://prometheus:9090
      metricName: queue_depth
      query: queue_depth{queue="inference"}
      threshold: "10"
```

## Batching Strategies

### Static Batching
Wait for N requests, process together.
- Pros: Maximum throughput
- Cons: Latency for first request

### Dynamic Batching
Batch up to N or timeout T.
```python
class BatchedInference:
    def __init__(self, model, max_batch=8, timeout=0.01):
        self.model = model
        self.max_batch = max_batch
        self.timeout = timeout
        self.queue = []
    
    async def infer(self, request):
        future = asyncio.Future()
        self.queue.append((request, future))
        
        if len(self.queue) >= self.max_batch:
            await self._process_batch()
        elif not self.timer:
            self.timer = asyncio.create_task(self._timeout())
        
        return await future
```

## Load Balancing

| Strategy | When to Use |
|----------|-------------|
| Round-robin | Uniform latency |
| Least-loaded | Variable request sizes |
| Affinity | Stateful models |
| Priority | Critical vs batch queues |

## Cost Optimization

- Spot instances for batch jobs
- Preemptible workers with checkpointing
- Right-size GPU (A10 not A100 if possible)
- Quantization for throughput
- Model distillation for common tasks

## CF-Specific

- Use Ray Serve for multi-model serving
- KEDA for queue-based autoscaling
- Dynamic batching for video generation
- Separate queues for video/image/audio (different SLAs)
- Spot instances for non-urgent batch processing

## Checklist

- [ ] Scaling strategy chosen (data/pipeline/tensor parallel)
- [ ] Orchestration configured (Ray/K8s)
- [ ] Batching optimized for latency vs throughput
- [ ] Autoscaling tested
- [ ] Spot instances configured for batch
- [ ] Fallback to on-demand if spot unavailable
- [ ] Monitoring dashboards created
