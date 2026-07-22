---
name: ivx-qv-security
description: Audit authentication, token handling, PII protection, and anti-cheat in QuizVerse.
version: "1.0"
---

## When to Use
"security", "auth", "token", "credential", "hack", "cheat", "PII", "encryption"

## Audit Checklist
```
1. Secrets → no hardcoded keys, tokens, or URLs in source
2. Auth → device + custom + Cognito flow validated
3. PII → SecureLogger.MaskEmail() for all user data
4. Network → HTTPS only, certificate pinning on mobile
5. Economy → server-authoritative (Nakama wallet), no client trust
6. Anti-cheat → validate scores server-side, rate-limit RPCs
```

## Guardrails
- `SecureLogger.MaskEmail()` for PII in logs
- HTTPS everywhere (no HTTP)
- Server-authoritative rewards/scores (never trust client)
- No `.Result` on Task → use `GetResultSafe()`

## Context Files (load only if needed)
- Workflow: `.agents/workflows/security.md`
- Persona: `.agents/personas/security-architect.md`
- Auth API: `docs/context/micro/AUTH_INTERFACE.md` (1.4 KB)
