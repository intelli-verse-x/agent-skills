---
name: ivx-cf-security-review
description: Audit code and architecture for security vulnerabilities. Use when reviewing code for security issues, designing auth systems, or responding to security incidents.
---
# Security Review Skill

## Purpose

Identify and mitigate security risks before they reach production.

## Review Areas

### Authentication & Authorization
- [ ] Proper auth on all endpoints
- [ ] Role-based access control (RBAC)
- [ ] Principle of least privilege
- [ ] Session management (tokens, expiry)

### Input Validation
- [ ] Pydantic validation on all inputs
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (output encoding)
- [ ] File upload validation (type, size, scan)

### Data Protection
- [ ] Encryption at rest (AES-256)
- [ ] Encryption in transit (TLS 1.3)
- [ ] PII handling (masking, deletion)
- [ ] Secret management (K8s secrets, vault)

### Infrastructure
- [ ] Container security (non-root, read-only)
- [ ] Network policies
- [ ] Resource limits
- [ ] Pod security policies

### LLM-Specific
- [ ] Prompt injection prevention
- [ ] Output filtering (PII, harmful content)
- [ ] Rate limiting on LLM endpoints
- [ ] Budget controls (cost spikes)

## Threat Modeling

For each component, ask:
1. What assets are we protecting?
2. Who are the threat actors?
3. What are the attack vectors?
4. What are the mitigations?
5. What are the residual risks?

## CF-Specific Checks

- LiteLLM proxy used for all LLM calls (no direct SDK)
- API keys in K8s secrets, not env vars or code
- `character_identity` doesn't leak cross-brand data
- Task store access properly scoped
- Output paths not traversable (path injection)

## Severity

- **Critical**: RCE, SQL injection, auth bypass, data breach
- **High**: XSS, CSRF, privilege escalation, secret exposure
- **Medium**: Information disclosure, weak crypto, DoS
- **Low**: Missing headers, verbose errors, weak policies
