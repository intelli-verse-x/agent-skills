---
name: ivx-cf-diffusion-pipeline-design
description: Design diffusion model pipelines for image and video generation. Use when configuring diffusion models, designing sampling strategies, or optimizing generation quality.
---
# Diffusion Pipeline Design Skill

## Purpose

Build efficient, high-quality diffusion pipelines for image and video generation.

## Pipeline Components

1. **Text Encoder**: CLIP, T5, custom encoders
2. **UNet/DiT**: Noise prediction network
3. **VAE**: Latent encode/decode
4. **Scheduler**: Noise schedule, sampling steps
5. **Conditioning**: ControlNet, IP-Adapter, etc.

## Configuration

| Parameter | Image | Video | Notes |
|-----------|-------|-------|-------|
| Model | SDXL/FLUX | Latte/CogVideo | Quality vs speed |
| Steps | 20-50 | 20-50 | More = better, slower |
| CFG | 7-12 | 7-12 | Guidance strength |
| Resolution | 1024x1024 | 512x512 or 1024x576 | Native res |
| Scheduler | DPM++ | Euler/DDIM | Task-dependent |

## Optimization

- **Distillation**: LCM, SDXL-Turbo for few-step generation
- **Quantization**: FP16/FP8/INT8 for memory/speed
- **Compilation**: TensorRT, ONNX for inference
- **Batched Sampling**: Process multiple latents together

## CF Integration

```python
from utils.pipeline.model_gateway import ModelGateway

gateway = ModelGateway()
model = gateway.route(
    task="image_generation",
    quality="high",
    priority="speed",
)

output = model.generate(
    prompt=prompt,
    negative_prompt=negative,
    num_inference_steps=30,
    guidance_scale=7.5,
)
```

## Quality Gates

- [ ] FID / CLIP score meets threshold
- [ ] No mode collapse in batch
- [ ] Consistency across seeds
- [ ] Latency within budget
