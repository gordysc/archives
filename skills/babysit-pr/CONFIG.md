# babysit-pr config template

Write this to `.claude/babysit-pr.md` at the repo root. Fill each field from the environment first (Makefile, justfile, package.json, pyproject.toml, Cargo.toml, go.mod, `.github/workflows/`, README, CLAUDE.md / AGENTS.md); ask only for what isn't there. `none` is a valid value.

```markdown
# babysit-pr config

## Commands
- Full check (first pass, before the PR opens): `make ci`
- Fast check (fix rounds; CI is the full gate): `<targeted test command with a filter>` + `<format/lint check>`
- Polite prefix for heavy commands: `nice -n 19` (shared desktop) | none
- Benchmarks: `<command>`; lock: `flock <path>` | none
- Reading CI: `gh pr checks <n>`
- CI rules: e.g. self-hosted Linux runners only; never add hosted runners

## Agents
- Implementer: opus
- Reviewer: providerInstanceId `codex`, model `gpt-6.1-sol`, options `{reasoningEffort: "high"}`
- Review cap: 3

## Standards
- Language skill for implementer and fix-surface checker: e.g. `beautiful-rust:rust-best-practices` | none
- Commit style: Conventional Commits
- Merge: squash

## Spec rules
Project rules that override "more correct" choices, e.g. "results match Excel exactly, including float summation order".

## Out of scope
Deferred issues and their reasons.

## Project lessons
Gotchas the next run would otherwise rediscover: framework quirks, test hooks, environment traps. Add one line whenever a review round surfaces one.
```
