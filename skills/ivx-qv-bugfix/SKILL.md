---
name: ivx-qv-bugfix
description: Investigate and fix bugs, crashes, null references, and runtime errors in QuizVerse.
version: "1.0"
---

## When to Use
"fix", "bug", "broken", "crash", "error", "not working", "null reference", "exception"

## Investigation Protocol
```
1. Reproduce → get exact error message + stack trace
2. read_console(types=["error"], count=20, include_stacktrace=True)
3. Locate → grep for class/method from stack trace
4. Root cause → trace data flow: UI → Manager → Service → Backend
5. Fix → minimum viable change at the correct layer
6. Verify → console clean + manual test
```

## Common Patterns (QuizVerse-Specific)

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| NullRef in `OnEnable` | Singleton not yet initialized | Add `if (Instance == null) return;` guard |
| NullRef on `_text.text` | SerializeField not wired | Check Inspector, drag reference |
| CSV data empty | Language code mismatch (`en` vs `English`) | Check `SceneLocalizationManager` code |
| Photon disconnect on answer | RPC sent after room left | Guard with `PhotonNetwork.InRoom` |
| Button not clickable | Invisible Image with raycastTarget | Check overlay interceptors in hierarchy |
| Screen behind another | Sibling order wrong | `transform.SetAsLastSibling()` on show |

## Context Files (load only if needed)
- Bug tracker: `docs/tracking/BUGS.md`
- Workflow steps: `.agents/workflows/bugfixing.md`
- Known corrections: `.agents/context/quizverse-context.md` §Corrections
