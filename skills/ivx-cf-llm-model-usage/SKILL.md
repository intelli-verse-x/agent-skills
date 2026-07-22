---
name: ivx-cf-llm-model-usage
description: >-
  Pick and change Content Factory LLM / image / video / music models safely.
  Use whenever the user asks which model a pipeline uses, which file to edit for
  chat/image/video defaults, SiliconFlow vs self-hosted, LiteLLM routing,
  vision judges, FLUX, Wan 2.2, ACE-Step, Qwen3-30B, DeepSeek V4 Pro, dead
  providers (OpenRouter/PiAPI/Kling), invalid model IDs, PREFER_SELFHOSTED,
  or anything in docs/LLM_MODEL_USAGE.md / configs/llm_models.yaml /
  configs/model_catalog.yaml / configs/pipelines/*.yaml. Prefer this skill over
  guessing provider SDKs or inventing nicknames that are not in the catalog.
---

# CF LLM Model Usage

Agents keep shipping bad model IDs and resurrecting dead providers. This skill
exists so you change the **right file** with the **real catalog id**.

## When this skill wins

- “Which model does viral_shorts use for frames?”
- “Switch long-form ideation to DeepSeek”
- “Why is vision still on Gemini?”
- “Add a new chat nickname to the catalog”
- Any edit under `configs/llm_models.yaml`, `configs/model_catalog.yaml`,
  or a pipeline’s `llm:` / image / video keys

## Hard rules (why they matter)

1. **Route chat through LiteLLM** (`model_provider="openai"` + proxy URL).
   Raw OpenAI/Anthropic SDKs bypass budget tags and break cluster routing.
2. **Never invent API ids.** Nicknames must resolve via
   `configs/model_catalog.yaml` or `${LLM_*}` env vars in
   `configs/llm_models.yaml`. A past smoke run failed on
   `qwen3-30b-siliconflow` — that class of typo is expensive.
3. **Dead providers stay off** unless `ALLOW_DEAD_PROVIDERS=true`:
   OpenRouter, Gemini direct, PiAPI, Kling, Stability.
   **KieAI is separate:** `ENABLE_KIEAI=true` (or key present) enables Veo + Nano Banana
   without reopening PiAPI/OpenRouter.
   Live stack: KieAI Veo (native audio) + SiliconFlow FLUX/Wan + self-hosted + RunPod Wan + ElevenLabs.
   See `docs/PROVIDERS.md`.
4. **Default mode today:** `PREFER_SELFHOSTED=false` → cloud (KieAI Veo when keyed; else SiliconFlow).
   Self-hosted wins only when that flag / warm GPU path is intentional.
5. **One pipeline override ≠ global default.** Edit
   `configs/pipelines/<name>.yaml` for one pipeline; edit
   `configs/llm_models.yaml` + `.env` for fleet defaults.

## Decision tree

```
Need to know "what runs today"?
  → Read docs/LLM_MODEL_USAGE.md (cheat sheet + per-pipeline tables)
  → Confirm live ids in configs/model_catalog.yaml + configs/llm_models.yaml

Change fleet default chat / image / video role?
  → configs/llm_models.yaml + matching .env keys (never commit secrets)

Change one pipeline’s chat model?
  → configs/pipelines/<name>.yaml → llm.primary (or step-specific key)

Add / rename a nickname?
  → configs/model_catalog.yaml first, then reference the nickname elsewhere

Vision soft-accept judge?
  → configs/llm_config.py → create_vision_chat_model()
  → Prefer Qwen3-VL-8B on SiliconFlow (not Gemini gateway)

World / Fortnite motion?
  → HY-World on RunPod — not Wan 2.2
```

## One-line cheat sheet (keep in sync with the doc)

| Family | Write / plan | Pictures | Motion | Judge | Music |
|--------|--------------|----------|--------|-------|-------|
| Ads / comic / blog / learning | Qwen3-30B / DeepSeek (SF) | FLUX.2 Pro | Veo→Wan / — | VL (SF) | — / ACE-Step |
| Viral shorts | Gemini Pro (**KieAI**) | FLUX.2 Pro + NB | Veo Fast (**KieAI**) / Wan FB | Gemini Flash (**KieAI**) | Veo in-model / TTS |
| Long-form / script2video | DeepSeek V4 Pro (SF) | FLUX.2 Pro | Veo Fast (KieAI) → Wan SF | VL-8B (SF) | ACE-Step / TTS |
| Song / MV | Qwen3-30B (SF) | FLUX.2 Flex | Wan (opt.) | — | ACE-Step |
| World scene | Qwen3-30B (SF) | FLUX.2 Flex | **HY-World** | — | — |
| QuizVerse premium preview | GPT / Claude council | screenshots | Ken Burns | — | ACE-Step |

**Mix:** SiliconFlow = default · KieAI = Gemini chat/vision/Veo/NanoBanana · Self-hosted when warm.

Plain names → config ids: see `docs/LLM_MODEL_USAGE.md` legend and
`references/file-map.md` in this skill.

## Workflow

1. **Recall the ask** — which pipeline, which modality (chat / image / video /
   music / vision), global vs one pipeline.
2. **Read** `docs/LLM_MODEL_USAGE.md` for the pipeline table.
3. **Verify** the id exists in `configs/model_catalog.yaml` (or is a
   `${LLM_*}` expansion already defined).
4. **Edit the smallest surface** from the decision tree.
5. **Done-when**
   - [ ] No dead-provider ids introduced
   - [ ] Nickname resolves in catalog or env
   - [ ] Pipeline YAML still uses `${…}` / catalog names, not raw secrets
   - [ ] If you changed defaults, `docs/LLM_MODEL_USAGE.md` still matches
         (update the doc in the same change when tables drift)

## Anti-patterns

| Don’t | Do instead |
|-------|------------|
| Hardcode `openai/gpt-…` in pipeline Python | Config + LiteLLM |
| Re-enable OpenRouter “just for one call” | SiliconFlow / self-hosted / explicit escape flag |
| Copy a marketing nickname into the API | Resolve via `model_catalog.yaml` |
| Use Wan for Fortnite world flythroughs | HY-World path |
| Change every pipeline YAML for a fleet default | `llm_models.yaml` + env |

## Related

- Path / new pipeline: `contentx-pipeline-dev`
- Cost: `cost-optimization`
- Providers truth: `docs/PROVIDERS.md`
- Full tables: `docs/LLM_MODEL_USAGE.md`
- File pointers: `references/file-map.md`
