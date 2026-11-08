---
name: babysit-pr
description: "Use when I ask to open a PR, take over an open one, or take an issue or task through to a PR. That request is my approval to drive it to a squash-merge: Sol review rounds, CI, review threads, merge."
---

# Babysit a PR

Take the work to a merged commit on the default branch. Sol (Codex), from a different model family, reviews it at most 3 times, with a fix round between reviews. You coordinate: you write the Targets, triage every finding, own CI, merge, and are the only one who talks to me. Pass `--no-merge` to stop before the merge.

Where the work starts decides who implements:
- **Working-tree changes** we made in this session, or an **open PR number**: you are the implementer. You follow [IMPLEMENTER.md](IMPLEMENTER.md) yourself, and a fresh Opus agent does the checks you can't do on your own work (step 5).
- **An issue number or task text**: an Opus implementer subagent writes the code (step 2).

The scripts are in `~/.claude/skills/babysit-pr/scripts/`, and each takes the PR number `<n>` first. The `.md` files beside this one are briefs. Children can't load this folder (Codex can't load Claude skills), so paste their contents into each task with the `{placeholders}` filled.

## 0. Setup

1. Read `.claude/babysit-pr.md` at the repo root. If it is missing, fill the template in [CONFIG.md](CONFIG.md) from the environment, ask me only for what you can't find, write the file, and tell me. Done when every field holds a value or `none`.
2. Call `orchestrator_capabilities` once and confirm the configured reviewer model exists. If it doesn't, tell me and stop. The reviewer is never a Claude model.

## 1. Targets

Write the Targets with [TARGETS.md](TARGETS.md), before any code if none exists yet. Done when every budget has a number and every axis in the relevant domains is either a concrete layout or trigger, or marked `n/a: <reason>`. A mechanical change (dependency bump, docs, config) gets `Targets: none, <reason>`.

The implementer and every reviewer receive the identical Targets.

## 2. Implement and open the PR

- **Issue or task:** start the implementer with the Agent tool: `model: "opus"`, `run_in_background: false`, prompt = IMPLEMENTER.md § Common + § First pass + the issue + Targets + config. Keep its agent ID; fix rounds go back to it with SendMessage.
- **Working tree:** do IMPLEMENTER.md § First pass yourself on the existing changes, including tests for every Targets row.
- **Open PR:** skip to the CI wait below.

Then run `wait-checks.sh <n>` in the background and wait for its notification. It exits 0 when every check on the head commit has finished, and 2 on a timeout; after a timeout, run it once more, then report the pending checks and stop. A failed check: read it with `gh run view <run-id> --job <job-id> --log-failed`. If the cause is in the code, it goes to the implementer and the wait repeats. If the cause is outside the code (runner, network, download), report the failed step and re-run only on my yes.

Done when CI is green and you hold the PR URL, head SHA, stated bound and a Targets table where every row has a measured result or a test that fails when the target is missed. A row without one goes back to the implementer before any review.

## 3. Review

Each review, first or re-review, is a new `delegate_task`:
- `target`: the config's reviewer (`providerInstanceId`, `model`, `options`), `role: "review"`, `isolation: "worktree"`, `mode: "async"`. Wait for its completion notification; never poll.
- `task`: [REVIEWER.md](REVIEWER.md) with round `k` of the cap. On a re-review, add the previous findings, the implementer's PR reply, and your triage (what was downgraded or deferred, so it isn't re-raised).

Done when the review is posted on the PR and you hold its verdict and numbered blockers.

## 4. Triage

Judge each blocker against REVIEWER.md § Severity, the single rule set for both of us:
- **fix**: a concrete failure inside scope.
- **nit**: no concrete failure; record the reason.
- **defer**: real but outside this PR's scope; it goes on the list for me.
- **ask me**: it needs a scope, spec or policy decision. Requirements stay frozen during the loop; a new one is a follow-up unless I say otherwise.

Add every unresolved review thread from people (`open-threads.sh <n>`) as a finding. Ask me before declining one.

No blockers and no open threads left → step 6.

## 5. Fix round

1. Give the implementer IMPLEMENTER.md § Fix round with the triaged findings and the nits worth taking: by SendMessage to the subagent, or work through it yourself.
2. **Redesign gate.** A fix that replaces a data structure, algorithm, rendering path, parser, protocol or file format starts as a design note. Check it against the finding and the TARGETS.md axes, then approve or redirect. When the design note is your own, a fresh Opus agent checks it. Done when it is approved.
3. **Fix-surface check.** With the fixes committed but not pushed, start a fresh Agent (`model: "opus"`, `run_in_background: false`), read-only, with: the diff since the last reviewed SHA, the findings, the fix-surface list, and the TARGETS.md sections that apply. Its job is to break the new code and return only concrete failures, each with a repro. Send those back to the implementer for one pass.
4. Push. Answer each thread with `resolve-thread.sh <n> <id> <replyTo> '<the fix and its commit, or why it is declined>'`. Wait for CI as in step 2.
5. Check the PR reply: every finding has an outcome, and where Sol prescribed a fix and the implementer did something smaller or different, the reply says why. A gap goes back to the implementer.

Done when CI is green on the new head and the reply passes that check. Back to step 3 while reviews used < cap. At the cap, go to step 6; the last round's fixes stay unverified by Sol.

## 6. Merge

Merge when all of these hold:
- the last verdict is APPROVE, or the cap is reached with every last-round blocker fixed and fix-surface checked;
- `wait-checks.sh` shows every check `pass` or `skipping`;
- `open-threads.sh <n>` prints `[]`.

Confirm the last two with `gh pr checks <n>` and `open-threads.sh <n>` right before merging. If the branch is behind or conflicts, rebase onto the default branch, push, and wait for CI again.

```sh
gh pr merge <n> --squash --delete-branch
```

Then check out the local default branch and make it match origin. With `--no-merge`, stop here and report.

## Stop and ask me

- The implementer is blocked or wants to change scope.
- A check fails outside the code (step 2).
- A triage call or a declined thread is mine (step 4).

## Done

Report: the PR link and merge commit; the result of each check; reviews used of the cap; per round, the blocker count and what happened to each; downgrades with reasons; each review thread and how you answered it; the deferred list; and, if the cap was hit, what Sol never re-checked. If you stop before the merge, report the blocker and the next step that needs me.
