---
name: ivx-cf-chaos-engineering
description: Skill for designing and running chaos experiments to improve system resilience. Use when validating fault tolerance, testing recovery procedures, or proving system robustness.
---
# Chaos Engineering

## When to Use

- Validating fault tolerance designs
- Testing recovery procedures
- Finding unknown failure modes
- Proving system robustness
- Training incident response

## Principles

1. Start in dev/staging, never production first
2. Minimize blast radius (one service/resource at a time)
3. Have abort criteria (auto-stop if error rate spikes)
4. Track metrics during experiments
5. Document findings and fix issues

## Tools

| Tool | Type | Best For |
|------|------|----------|
| Chaos Monkey | Original | EC2 instances |
| Chaos Mesh | Kubernetes | K8s-native |
| Gremlin | SaaS | Enterprise |
| Litmus | Open source | K8s workflows |

## Experiment Types

### Infrastructure Failure
```bash
# Simulate node failure (Chaos Mesh)
chaosctl create node-failure \
  --selector node-type=gpu \
  --duration 5m
```

### Network Latency
```bash
# Add 100ms latency to Redis
chaosctl create network-latency \
  --target redis-service \
  --latency 100ms \
  --duration 10m
```

### Resource Exhaustion
```bash
# CPU stress on API pods
chaosctl create cpu-stress \
  --selector app=api \
  --load 80 \
  --duration 10m
```

### Dependency Failure
```bash
# Simulate LiteLLM proxy down
chaosctl create pod-failure \
  --selector app=lite-llm \
  --duration 5m
```

## Experiment Protocol

### 1. Hypothesis
"When Redis becomes unavailable, the system will fall back to database reads with < 500ms latency increase."

### 2. Safety Checks
- [ ] Experiment in staging
- [ ] Abort if error rate > 5%
- [ ] Abort if latency p95 > 2x baseline
- [ ] On-call aware
- [ ] Easy rollback (one command)

### 3. Execute
```bash
# Run experiment with auto-abort
chaosctl run experiment.yaml --auto-abort --notify-slack
```

### 4. Observe
- Error rates
- Latency distributions
- Fallback behavior
- User-visible impact
- Recovery time

### 5. Document
```markdown
## Chaos Experiment: Redis Failure

**Date**: 2024-07-07
**Hypothesis**: System falls back to DB with <500ms latency increase
**Actual**: Latency increased 800ms, 2% error rate
**Finding**: Fallback timeout was 1s, causing cascading delays
**Fix**: Reduced timeout to 200ms, implemented circuit breaker
**Status**: Fixed, will re-verify next week
```

## CF-Specific

- Test GPU node preemption (spot instances)
- Test Redis failover (session/cache loss)
- Test LiteLLM proxy failure (graceful degradation)
- Test pipeline worker crash (recovery)
- Test S3 outage (local cache fallback)
- Test database failover (read replica promotion)

## Game Days

Monthly scheduled events:
1. Choose a scenario (Redis down, GPU OOM, etc.)
2. Run chaos experiment
3. Measure response
4. Identify gaps
5. Fix and improve
6. Document learnings

## Anti-Patterns

- ❌ No abort criteria
- ❌ Testing in production first
- ❌ Not notifying team
- ❌ No metrics during experiment
- ❌ Not fixing findings
- ❌ No documentation
- ❌ Not training on-call
