---
name: sid-orchestra-loop
description: >
  Sid Orchestra stages with triage, plan critic, canary harness, evals, leases,
  and lane log. Use with @sid-orchestra or Cursor /loop.
---

# Sid Orchestra Loop

## Stages

```
0. WAKE
   └─ Read BLACKBOARD + LANE_LOG + EVALS
   └─ If status=DONE → stop

1. INTAKE (Master)
   └─ Restate goal · Mem0 + Hindsight
   └─ TRIAGE: sequential-only? → Mode=solo (no swarm)
   └─ Else Mode=swarm · mint run_id = sid-YYYYMMDD-HHMM-slug
   └─ Init LANE_LOG header

2. RESEARCH
   └─ 1–3 agents (or Master if solo)
   └─ Understanding Eval PASS/FAIL
   └─ Stamp LANE_LOG

3. GATE A (User)
   └─ Present understanding · WAIT approve
   └─ Reject → Research ≤2

4. PLAN
   └─ Planning → lane cards + deps + locks plan

5. PLAN CRITIC + Plan Eval
   └─ Separate agent grades plan PASS/FAIL
   └─ FAIL → revise plan ≤2 or Gate B to user
   └─ PASS → continue

6. GATE B (if high-risk or stuck FAIL)
   └─ User approve to build

7. BUS SYNC
   └─ Write locks with leased_at + ttl_min=30 + expires_at
   └─ Steal stale locks
   └─ Update BLACKBOARD

8. BUILD WAVE (swarm only; solo=Master/one worker)
   └─ Working(N) + Generation · non-overlapping leases
   └─ Heartbeat leases
   └─ Every return → LANE_LOG stamp

9. CODE REVIEW + Code Eval
   └─ Review ≠ Working
   └─ BLOCKER or Code Eval FAIL → Fix

10. FIX WAVE (≤2)
   └─ Re-review changed files only

11. CANARY HARNESS
   └─ Scoped analyze + one focused test
   └─ FAIL → Fix; do not full-suite

12. FULL HARNESS
   └─ Only if canary PASS
   └─ flutter test / broader smoke

13. REPORT + EVAL NOTE + RETAIN
   └─ Master summary · alignment notes if human graded
   └─ mem0 / hindsight
   └─ status=DONE | BLOCKED | NEXT_TICK
```

## `/loop` arming

```powershell
while ($true) {
  Start-Sleep -Seconds 900
  Write-Output 'AGENT_LOOP_TICK_sid_orchestra {"prompt":"Sid Orchestra tick: read BLACKBOARD + LANE_LOG; continue next stage; enforce leases TTL; run evals as gates; never swarm sequential-only."}'
}
```

Sentinel: `AGENT_LOOP_TICK_sid_orchestra`  
See `~/.cursor/skills-cursor/loop/SKILL.md`.

## Budgets

| Budget | Limit |
|--------|-------|
| Re-swarm / fix rounds | 2 |
| Agents per wave | ≤12 |
| Lock TTL | 30 min |
| Open questions Gate A | ≤5 |
| Writers per path | 1 |
| Plan revise after FAIL | 2 |

## Exit

`DONE` · `BLOCKED` · `NEXT_TICK` · user `stop orchestra`
