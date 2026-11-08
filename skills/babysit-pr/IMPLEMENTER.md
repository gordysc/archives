# Implementer brief

Paste § Common plus the section for the round. Fill `{issue}`, `{targets}` and `{config}`.

## Common

You implement `{issue}` in this repository. Project config:

{config}

- Branch from the up-to-date default branch as `<type>/<issue>-<slug>`; on a fix round, stay on the PR branch.
- Commit with Conventional Commits, one purpose per commit, staging explicit paths. Set work aside with WIP commits; the git stash stack is shared.
- Load the language skill named in the config before writing code.
- Run heavy commands with the config's polite prefix, and benchmarks under its lock.
- The coordinator merges. You never merge, open issues, or touch other PRs.

## First pass

Targets:

{targets}

1. Put the Targets in the PR body. Turn every budget × layout and every trigger into a test or bench that fails when the target is missed.
2. Design for the worst case now. For performance, choose a structure with a stated bound (worst case or amortized, whichever the Targets say) and write the bound in the PR body. For state, enforce each invariant at one **choke point** every input path passes through, so an unlisted trigger is still covered.
3. Use other tools' own output (JSON parsed as JSON, the tool's own resolution, the real API) instead of reimplementing their parsers or rules. When a feature depends on predicting another tool's behaviour, narrow the feature and say so.
4. Make the tests **bite**: for each core invariant, plant a bug in a scratch copy and confirm a test fails. Report which test caught which plant.
5. Run the full check, push, write the body with the `pr` skill, and open the PR with `Closes #<issue>`. The coordinator watches CI and sends you any failures.

Final reply: PR URL, head SHA, the bound, a Targets table (row, measured result or test name, pass/miss), the bites, and any scope left out with the reason.

## Fix round

Findings to fix (already triaged by the coordinator):

{findings}

1. **Fix the class, not the instance.** For each finding, name the invariant it breaks, list every path that can break it, and fix it at a choke point, with one test that drives every path through it. Fix a single instance only when that one path is genuinely the only way in.
2. Where the reviewer prescribed a fix and you choose something smaller or different, give the reason in your reply.
3. **Redesign gate.** If a fix replaces a data structure, algorithm, rendering path, parser, protocol or file format, stop before coding and return a design note: the structure, its bound, its invariants, the inputs that now matter (from the TARGETS axes), and which existing tests stop covering it. Code after the coordinator approves.
4. **Fix surface.** List the new state, paths, inputs and failure modes your fix adds, attack each one with the matching TARGETS axes, and add tests for them.
5. Run the fast check, commit, and report back without pushing. The coordinator runs a fresh check on your fix diff and sends back any failures; fix those, then push.
6. Reply on the PR: per finding, the outcome and commit, or the reason it was declined; then the fix surface and how you tested it. The coordinator watches CI and sends you any failures.

Final reply: head SHA, the per-finding outcomes, and the fix surface.
