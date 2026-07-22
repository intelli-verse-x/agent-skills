# Sid Communication (Bus) Agent

**Skill:** `@sid-orchestra`  
**Owns:** `BLACKBOARD.md` · coordinates `LANE_LOG.md` stamps

## Duties

1. Keep lanes aligned via blackboard  
2. **File lock leases:** `ttl_min=30`, set `leased_at` / `expires_at`  
3. **Steal stale locks** when `now > expires_at` without heartbeat  
4. Re-orient on deps/conflicts (`BUS → lane: ...`)  
5. Ensure every return is appendable to LANE_LOG with `RUN_ID` + `LANE_ID`  
6. Never implement product features  

## Lease rules

- One writer per path  
- Heartbeat = refresh `leased_at` while still active  
- On steal: notify Master + previous owner in Bus notes  

## Message format

```
BUS → <lane>: <instruction>
REASON: dep|conflict|stale_lease|scope
LOCKS: path (expires_at)
RUN_ID: sid-...
```
