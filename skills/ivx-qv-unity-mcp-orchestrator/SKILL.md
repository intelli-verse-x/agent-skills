---
name: ivx-qv-unity-mcp-orchestrator
description: Orchestrate Unity Editor via MCP tools — GameObjects, scripts, scenes, tests, cameras.
version: "2.0"
---

## When to Use
"scene", "prefab", "hierarchy", "gameobject", "component", "inspector", "play mode", "Unity editor", "MCP"

## Workflow
```
1. set_active_instance("quiz-verse@<hash>")
2. read_console() → baseline errors
3. Resource-first: read mcpforunity://editor/state before tools
4. Operate (tools below)
5. Postflight: console clean + prefab wiring + UI interactable
```

## Tool Quick-Ref
| Category | Tools | Use For |
|----------|-------|---------|
| Scene | `manage_scene`, `find_gameobjects` | Hierarchy, finding objects |
| Objects | `manage_gameobject`, `manage_components` | CRUD on GameObjects |
| Scripts | `create_script`, `script_apply_edits` | C# code (auto-compiles) |
| Assets | `manage_asset`, `manage_prefabs` | Asset/prefab operations |
| Editor | `manage_editor`, `read_console` | Play/pause/stop, console |
| Camera | `manage_camera` | Screenshots, Cinemachine |
| Batch | `batch_execute` | 10-100x faster parallel ops |
| Tests | `run_tests`, `get_test_job` | Unity Test Framework |

## Critical Rules
1. **After script edits** → wait for `is_compiling == false` → then `read_console`
2. **Batch everything** → use `batch_execute` for 2+ operations
3. **Screenshots** → `manage_camera(action="screenshot", include_image=True)` to see results
4. **Never call `refresh_unity`** after `create_script`/`script_apply_edits` (they auto-refresh)

## Error Recovery
| Symptom | Fix |
|---------|-----|
| Tools return "busy" | Wait for compilation: check `editor_state` |
| "stale_file" error | Re-fetch SHA with `get_sha`, retry |
| Connection lost | Wait ~5s (domain reload), reconnect |
| Commands fail | Wrong instance → `set_active_instance` |

## Context Files (load only if needed)
- MCP workflow: `.agents/workflows/unity-mcp.md`
