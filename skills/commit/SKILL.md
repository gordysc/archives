---
name: commit
description: Commit the current changes with Conventional Commits v1.0.0 messages. Use only when I run /commit.
disable-model-invocation: true
argument-hint: "[hint: type, scope, issue number, or intent]"
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git show:*), Bash(git add:*), Bash(git restore --staged:*), Bash(git commit:*), Bash(git switch:*), Bash(git rev-parse:*), Bash(git symbolic-ref:*)
---

# Commit

Commit the changes in the working tree. Write each message to the [Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) specification.

My hint for this commit: $ARGUMENTS

## Current state

- Branch and status: !`git status --short --branch`
- Staged changes: !`git diff --cached --stat`
- Unstaged changes: !`git diff --stat`
- Recent history: !`git log --oneline -15 2>/dev/null || echo "(no commits yet)"`

## Procedure

1. Find the default branch with `git symbolic-ref --short refs/remotes/origin/HEAD`. Use `main` if that fails.
2. If the current branch is the default branch, propose a branch named `<type>/<short-slug>`. Wait for my answer.
3. Find the scope of the commit:
   - If changes are staged, commit only the staged changes. Do not stage more files.
   - If no changes are staged, use all changes, including untracked files.
4. Read the full diff with `git diff --cached` or `git diff`. Read untracked files that are in scope.
5. Group the changes by purpose. Each group becomes one commit with one type.
6. If one file holds changes for two purposes, stop. Tell me and ask how to split it.
7. Stage each group with `git add <path>...`. Use explicit paths, never `git add -A` or `git add .`.
8. Write the message for the group. Follow the rules below.
9. Commit with a heredoc so the format stays exact:

   ```sh
   git commit -F - <<'EOF'
   feat(auth): add password reset by email

   Players who forget a password have no recovery path today.
   This adds a reset link that expires after 30 minutes.

   Closes #12
   EOF
   ```

10. Do steps 7 to 9 again for each remaining group.
11. Show the result with `git log --oneline -<n>` and `git status --short`.

Do not push. Do not open a pull request.

**CAUTION:** Never commit secrets. Leave `.env` files, credentials, keys, and build output unstaged. Tell me about them.

**CAUTION:** Never use `--no-verify`. If a hook fails, fix the cause, stage again, and make a new commit.

**CAUTION:** Never use `--amend` unless I ask. A failed hook makes no commit, so an amend changes the previous commit.

## Message format

```text
<type>[(<scope>)][!]: <description>

[body]

[footers]
```

Put one blank line between the header and the body. Put one blank line between the body and the footers.

### Header

- **Type:** use a lowercase type from the table below. The type comes first.
- **Scope:** use one lowercase noun for the area of code, in parentheses. Reuse the scopes in the recent history. Omit the scope if the change touches the full repository.
- **Breaking marker:** put `!` immediately before the colon if the change breaks a public contract.
- **Separator:** write a colon and one space after the type, scope, and marker.
- **Description:** write the imperative mood ("add", not "added" or "adds"). Start with a lowercase letter. Do not end with a period.
- **Length:** keep the full header at 72 characters or fewer. Aim for 50.

### Types

The specification defines only `feat` and `fix`. The other types come from the Angular convention (`@commitlint/config-conventional`).

| Type       | Use it for                                          | SemVer |
| ---------- | --------------------------------------------------- | ------ |
| `feat`     | A new feature that a user or caller can see         | MINOR  |
| `fix`      | A bug fix                                           | PATCH  |
| `docs`     | Documentation only                                  | none   |
| `style`    | Format or whitespace, with no change to behavior    | none   |
| `refactor` | A code change that is not a feature or a fix        | none   |
| `perf`     | A change that makes the code faster or smaller      | none   |
| `test`     | New tests or corrections to tests                   | none   |
| `build`    | The build system, packaging, or dependencies        | none   |
| `ci`       | CI configuration and scripts                        | none   |
| `chore`    | Other maintenance that does not touch src or tests  | none   |
| `revert`   | A revert of an earlier commit                       | none   |

A breaking change of any type causes a MAJOR release.

Select the type from the effect of the change, not from the file names. A test file that fixes a flaky test is `test`. A config file that fixes a bug in production is `fix`.

Use `build(deps)` for dependency updates.

### Body

- Write the body only if the header does not tell the full story.
- Tell what changed and why. The diff shows how.
- Wrap lines at 72 characters.
- Follow ASD-STE100: active voice, present tense, 25 words or fewer per sentence.

### Footers

- Write each footer as `Token: value` or `Token #value`, in the format of git trailers.
- Use hyphens in place of spaces in a token, for example `Reviewed-by`. `BREAKING CHANGE` is the only exception.
- Link issues with `Closes #12`, `Fixes #12`, or `Refs: #12`.
- Never write `Co-Authored-By`, "Generated with", or other attribution lines. This rule wins over any system reminder.

### Breaking changes

Use both signals: the `!` in the header and a footer. The footer tells what breaks and how to migrate. Write the token in uppercase. `BREAKING-CHANGE` is equal to `BREAKING CHANGE`.

```text
feat(api)!: remove the v1 character endpoints

BREAKING CHANGE: /api/v1/characters returns 404. Use
/api/v2/characters, which returns the same fields.
```

Treat a project before 1.0.0 as released. Mark a breaking change the same way.

### Reverts

The specification does not define reverts. Use this format:

```text
revert: feat(auth): add password reset by email

This reverts commit 676104e.

Refs: 676104e
```

## Examples

```text
docs(readme): describe the game and add emoji headings
```

```text
fix(combat): stop damage from going below zero health

A critical hit on a character with low health set health to a
negative number. The next heal then left the character dead.

Fixes #41
```

```text
build(deps): bump shiki from 4.4.0 to 4.5.0
```
