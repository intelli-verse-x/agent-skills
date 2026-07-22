---
name: hermes-tweet
description: Install and operate Hermes Tweet, the native Hermes Agent X/Twitter plugin for endpoint discovery, read-only calls, and explicitly gated action-only workflows.
---

# Hermes Tweet

Use this skill when a Hermes Agent session needs X/Twitter research, social listening, account reads, trend checks, monitor setup, extraction jobs, giveaway draws, media changes, or controlled posting through the native Hermes Tweet plugin.

Source: <https://github.com/Xquik-dev/hermes-tweet>

## Install

Prefer the native Hermes plugin installer:

```bash
hermes plugins install Xquik-dev/hermes-tweet --enable
hermes plugins list
hermes tools list
```

If Git install is unavailable, install the PyPI package into the Hermes Agent virtual environment:

```bash
uv pip install --python ~/.hermes/hermes-agent/venv/bin/python hermes-tweet
hermes plugins enable hermes-tweet
hermes tools list
```

## Configuration

- `tweet_explore` works without network access or an API key.
- `tweet_read` requires `XQUIK_API_KEY`.
- `tweet_action` requires `XQUIK_API_KEY` and `HERMES_TWEET_ENABLE_ACTIONS=true`.
- Keep `HERMES_TWEET_ENABLE_ACTIONS=false` for public research, public monitoring, support triage, and unattended sessions that do not require private or action-only routes.
- Enable actions only when the user explicitly asks to post, reply, send DMs, follow, run private reads, manage webhooks, manage monitors, run extraction jobs, draw giveaways, or change media.

If `XQUIK_API_KEY` is added to `~/.hermes/.env` while Hermes is running, use `/reload` in the active CLI session before calling `tweet_read`.

## Operating Procedure

1. Run `tweet_explore` first to find the exact endpoint and required arguments.
2. Use `tweet_read` for catalog-listed read-only public routes.
3. Use `tweet_action` only after confirming the request is private, write-like, or otherwise action-only, and action gating is enabled.
4. Never route private or write-like endpoints through `tweet_read`.
5. Keep action gating disabled for cron and gateway jobs unless the workflow requires private reads or action-only operations.

## Smoke Test

```bash
hermes -z "Use tweet_explore, then read /api/v1/account. Do not call tweet_action." --toolsets hermes-tweet
```

Expected behavior:

- Without `XQUIK_API_KEY`, Hermes exposes only `tweet_explore`.
- With `XQUIK_API_KEY`, `tweet_read` can call `/api/v1/account`.
- `tweet_action` stays unavailable or disabled unless `HERMES_TWEET_ENABLE_ACTIONS=true`.

## References

- Repository guide: <https://github.com/Xquik-dev/hermes-tweet#readme>
- PyPI package: <https://pypi.org/project/hermes-tweet/>
- Hermes plugins guide: <https://hermes-agent.nousresearch.com/docs/user-guide/features/plugins/>
- Build a Hermes plugin: <https://hermes-agent.nousresearch.com/docs/guides/build-a-hermes-plugin/>
