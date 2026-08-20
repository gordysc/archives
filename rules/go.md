---
paths:
  - "**/*.go"
---

# Go conventions

I am still learning Go — comment generously, so I can read any file and understand what happens.

- Write a doc comment on every function, type, method, and package — exported and unexported alike (idiomatic `// Name ...` form).
- Inside function bodies, comment the *why* and the mechanics of anything non-obvious: goroutines and channels, `defer` semantics, error-wrapping decisions, interface satisfaction, pointer vs value receivers, struct embedding, context usage, and any standard-library behavior a newcomer would not know (e.g. what `errors.Is` matches, why a body must be closed).
- Do not narrate plain sequential code line-by-line — comment the concepts, not the syntax.
