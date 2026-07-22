---
name: ivx-cf-onnx-optimization
description: Skill for converting and optimizing models to ONNX format. Use when deploying models to production for cross-platform inference.
---
# ONNX Optimization

## When to Use

- Deploying models to production
- Cross-platform deployment (CPU, GPU, mobile)
- Optimizing inference latency
- Enabling TensorRT acceleration

## Conversion

### PyTorch → ONNX
```python
import torch.onnx

model.eval()
dummy_input = torch.randn(1, 3, 224, 224)

torch.onnx.export(
    model,
    dummy_input,
    "model.onnx",
    opset_version=17,
    input_names=["input"],
    output_names=["output"],
    dynamic_axes={
        "input": {0: "batch_size"},
        "output": {0: "batch_size"},
    },
)
```

### TensorFlow → ONNX
```bash
python -m tf2onnx.convert --saved-model tf_model --output model.onnx
```

## Optimization

### ONNX Runtime
```python
import onnxruntime as ort

session = ort.InferenceSession(
    "model.onnx",
    providers=["TensorrtExecutionProvider", "CUDAExecutionProvider", "CPUExecutionProvider"]
)

inputs = {session.get_inputs()[0].name: data}
outputs = session.run(None, inputs)
```

### Static Shapes (Better Optimization)
```python
# For fixed batch size, use static shapes
onnx.shape_inference.infer_shapes_path("model.onnx", "model_optimized.onnx")
```

### Quantization
```python
from onnxruntime.quantization import quantize_dynamic, QuantType

quantize_dynamic(
    "model.onnx", 
    "model_quantized.onnx",
    weight_type=QuantType.QInt8,
)
# 4x smaller, 2-4x faster on CPU
```

## Providers

| Provider | Use Case | Speedup |
|----------|----------|---------|
| CPUExecutionProvider | Fallback | Baseline |
| CUDAExecutionProvider | NVIDIA GPU | 10-50x |
| TensorrtExecutionProvider | NVIDIA GPU (production) | 20-100x |
| DirectMLExecutionProvider | Windows GPU | 5-20x |
| CoreMLExecutionProvider | Apple Silicon | 5-15x |
| OpenVINOExecutionProvider | Intel CPU | 3-10x |

## Validation

```python
# Compare ONNX vs PyTorch outputs
pytorch_out = model(torch_input)
onnx_out = session.run(None, {"input": torch_input.numpy()})

np.testing.assert_allclose(
    pytorch_out.detach().numpy(), 
    onnx_out[0],
    rtol=1e-3,
    atol=1e-5,
)
```

## CF-Specific

- Convert diffusion models to ONNX for CPU fallback
- Use TensorRT EP for GPU production inference
- Quantize classification models for cost savings
- Validate outputs match original before deploying
- Profile latency with `onnxruntime_perf_test`

## Checklist

- [ ] Model converted successfully
- [ ] Outputs validated against original
- [ ] Provider selected for target hardware
- [ ] Quantization applied if latency is bottleneck
- [ ] Batch size optimized
- [ ] Memory footprint acceptable
