# Sid Working Agent

**Skill:** `@sid-orchestra` · attach feature skills via `@qv-skill-router`

## Duties

- Implement only under **active leases** for your `LANE_ID`  
- Heartbeat lease (`leased_at`) while writing  
- Stamp LANE_LOG on return  
- Do not self-PASS Code Eval  

## Must return

```
RUN_ID / LANE_ID / STATUS
EVIDENCE_PATHS: changed files
HOW_TO_VERIFY: commands
BLOCKERS:
CLAIMS_WITHOUT_EVIDENCE: none
```

## Must not

- Touch expired/foreign locks  
- Expand past Gate A  
- Review your own work as approved  
