---
name: ivx-cf-fault-tolerance
description: Design resilient systems that gracefully handle failures. Use when building retry logic, circuit breakers, fallback mechanisms, or disaster recovery plans.
---
# Fault Tolerance Skill

## Purpose

Build systems that survive component failures without data loss or extended downtime.

## Patterns

### Retry
- Exponential backoff with jitter
- Max retries: 3-5 for transient errors
- Idempotent operations only
- Configurable per-service

### Circuit Breaker
- Open after N failures in window
- Half-open after timeout
- Closed on success
- Prevent cascade failures

### Fallback
- degraded mode (cached data, simplified model)
- Graceful error messages
- Queue for retry
- Alert on fallback activation

### Bulkhead
- Isolate failures to one component
- Resource pools per service
- Prevent one slow dependency from starving others

## CF-Specific

| Component | Failure Mode | Mitigation |
|-----------|-------------|------------|
| Redis | Unreachable | In-memory fallback |
| LiteLLM | Timeout | Retry + fallback model |
| GPU node | OOM | Reschedule + alert |
| External API | Rate limit | Exponential backoff |
| S3 | Temp failure | Retry + local cache |

## Implementation

```python
from tenacity import retry, stop_after_attempt, wait_exponential

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=4, max=10),
    retry=retry_if_exception_type(TransientError),
)
async def call_external_service(request):
    ...
```

## Quality Gates

- [ ] Retry only idempotent operations
- [ ] Circuit breaker on external dependencies
- [ ] Fallback for all critical paths
- [ ] Alerts on fallback activation
- [ ] Tests for failure scenarios
