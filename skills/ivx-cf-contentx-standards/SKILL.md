---
name: ivx-cf-contentx-standards
description: >-
  DEPRECATED layout skill. STATUS: NOT EXECUTED — do NOT create src/contentx/.
  Prefer docs/STRUCTURE.md and .cursor/rules/orchestrator.mdc for real paths.
  Legacy naming notes only; do not use for new file placement.
---

# ContentX Engineering Standards

> **STATUS: DRAFT / NOT EXECUTED (2026-07-15).**  
> The live repo uses **repo-root packages** (`api/`, `pipelines/`, `utils/`, `configs/`).  
> There is **no** `src/contentx/`. Read `docs/STRUCTURE.md` before placing files.  
> Do **not** migrate code into `src/contentx/` unless a human explicitly runs `@migrate`.

## Quick Reference (LIVE — use these)

| Standard | Rule |
|----------|------|
| **Source root** | Repo root packages — **not** `src/contentx/` |
| **Configs** | `configs/` (not singular `config/`) |
| **Secrets** | Root `.env` / `.env.example` (not `.env.d/` today) |
| **Outputs** | `.working_dir/`, `out/` (gitignored) |
| **K8s in-repo** | `infra/` (human-only) |

---

> ### ⛔ HARD STOP — ignore everything below as historical draft
>
> Everything from **Legacy aspirational table** through **Migration Phases** is a
> **NOT-EXECUTED** draft. Agents must **not** create `src/contentx/`, move
> packages into it, or follow the migration checklist. Path truth is
> `docs/STRUCTURE.md` + the LIVE table above. Stop here unless a human runs `@migrate`.

---

## Legacy aspirational table (DO NOT FOLLOW for placement)

| Standard | Rule (historical draft) |
|----------|------|
| **Product name** | ContentX (not ViMax) |
| **Package** | `contentx` (not `vimax`) |
| **Source root** | ~~`src/contentx/`~~ **INVALID on disk** |
| **Env prefix** | `CONTENTX_` |
| **Temp files** | `.tmp/` only |
| **Outputs** | `out/` only |
| **Logs** | `logs/` only |
| **Secrets** | ~~`.env.d/`~~ use root `.env` |
| **Configs** | ~~`config/`~~ use `configs/` |

## Directory Architecture

```
content-factory/
├── .cursor/           # AI IDE config (git-tracked)
├── .env.d/            # Secrets (gitignored)
├── .tmp/              # Temp files (gitignored)
├── config/            # Runtime configs
├── deploy/            # Docker, K8s, Terraform
├── docs/              # Documentation
├── logs/              # App logs (gitignored)
├── out/               # Output artifacts (gitignored)
├── scripts/           # Operational scripts
├── src/contentx/      # Source code
│   ├── domain/        # No external deps
│   ├── application/   # Use cases
│   ├── interface/     # API, CLI, MCP
│   ├── infrastructure/# External impl
│   └── pipelines/     # Domain-specific
├── tests/             # All tests
└── pyproject.toml
```

### Dependency Rule
```
domain <- application <- interface
  ^                       ^
  +---- infrastructure ---+
```

## Naming Conventions

| Category | Format | Example |
|----------|--------|---------|
| Python modules | `snake_case.py` | `pipeline_runner.py` |
| Python packages | `snake_case/` | `video_generation/` |
| Classes | `PascalCase` | `PipelineRunner` |
| Functions | `snake_case` | `run_pipeline()` |
| Constants | `UPPER_SNAKE_CASE` | `MAX_RETRY_COUNT` |
| Private | `_leading_underscore` | `_validate_config()` |
| Test files | `test_{module}.py` | `test_pipeline_runner.py` |
| Config files | `kebab-case.yaml` | `model-catalog.yaml` |
| Shell scripts | `kebab-case.sh` | `quick-deploy-api.sh` |

## File Management Rules

### Temporary Files `.tmp/`
- ALL temp/scratch/cache files MUST go here
- Default lifetime: 24 hours
- Use `TempManager` helper:
  ```python
  from contentx.infrastructure.common.temp_manager import TempManager

  with TempManager.temp_file(prefix="render", suffix=".mp4") as tmp:
      video.render(to=tmp)
  ```

### Output Artifacts `out/`
- ALL generated content MUST go here
- Date-bucketed: `out/runs/2026/07/06/{run_id}/`
- Lifecycle: staging -> runs -> archive -> glacier

### Environment `.env.d/`
- Root `.env` is FORBIDDEN
- Hierarchy: process env > `.env.local` > `.env.{env}` > `config/`
- Pydantic settings with validation:
  ```python
  class Settings(BaseSettings):
      model_config = SettingsConfigDict(
          env_prefix="CONTENTX_",
          extra="forbid",
      )
  ```

## Code Quality

### Import Order
```python
# 1. Standard library
import os

# 2. Third-party
import redis

# 3. First-party (contentx)
from contentx.domain.models import Pipeline
```

### Type Hints
- Mandatory on all function signatures
- Use `|` union syntax (Python 3.12+)

### Pre-Commit Checks
- `ruff check .` passes
- ~~`mypy src/contentx` passes~~ → typecheck live packages if configured (no `src/contentx/`)
- `pytest` passes
- No root clutter

## Git Commits
```
type(scope): subject

body

footer
```

| Type | Use |
|------|-----|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Restructuring |
| `perf` | Performance |
| `docs` | Documentation |
| `test` | Tests |
| `chore` | Tooling |
| `security` | Security fix |

## Validation Checklist

~~Before any commit:~~ **STRICKEN — do not enforce. Historical draft only.**

- [ ] ~~No new files in root (except allowed)~~
- [ ] ~~All Python in `src/contentx/`~~ → use repo-root packages (`api/`, `pipelines/`, …)
- [ ] ~~All env configs in `.env.d/`~~ → use root `.env`
- [ ] ~~All temp files in `.tmp/`~~
- [ ] ~~All outputs in `out/`~~ → also `.working_dir/`
- [ ] ~~All logs in `logs/`~~
- [ ] ~~Imports use `from contentx...`~~ → use live package imports
- [ ] `ruff check .` passes *(still fine)*
- [ ] ~~`mypy src/contentx` passes~~ → typecheck live packages if configured
- [ ] `pytest` passes *(still fine)*

## Migration Phases

**STRICKEN — NOT EXECUTED. Do not run these steps.** Creating `src/contentx/` is forbidden unless a human explicitly runs `@migrate`.

| # | Action | Status |
|---|--------|--------|
| 1 | ~~Create `src/contentx/` package~~ | **DO NOT** |
| 2 | ~~Move `utils/` -> `src/contentx/infrastructure/`~~ | **DO NOT** |
| 3 | ~~Move `api/` -> `src/contentx/interface/api/`~~ | **DO NOT** |
| 4 | ~~Move `pipelines/` -> `src/contentx/pipelines/`~~ | **DO NOT** |
| 5 | ~~Create `.tmp/`, `out/`, `logs/`~~ | historical |
| 6 | ~~Create `config/`, `.env.d/`~~ | use `configs/` + root `.env` |
| 7 | ~~Move root scripts -> `scripts/`~~ | historical |
| 8 | ~~Centralize tests -> `tests/`~~ | already live as `tests/` |
| 9 | ~~Update `pyproject.toml`~~ | historical |
| 10 | ~~Add pre-commit hooks~~ | historical |
| 11 | ~~Add Firecrawl validation~~ | see live Firecrawl tools/skills |
| 12 | ~~Verify `docker compose up --build`~~ | historical |
