---
paths:
  - "**/*.swift"
---

# Swift conventions

I am still learning Swift — comment generously, so I can read any file and understand what happens.

- Write a `///` doc comment on every type, function, method, property, enum case, and protocol — public and private alike. Use DocC markup: a one-line summary, then `- Parameters:`, `- Returns:`, and `- Throws:` where applicable.
- Inside function bodies, comment the *why* and the mechanics of anything non-obvious: optionals and unwrapping (`guard let`, `if let`, `??`), closures and capture lists (`[weak self]` and why the retain cycle would happen), value vs reference semantics (struct vs class, copy-on-write), protocol conformance and extensions, error handling (`throws`, `try?`, `try!`, `Result`), async/await and actors, property wrappers (`@State`, `@Published`, etc.), generics and associated types, and any standard-library or SwiftUI behavior a newcomer would not know (e.g. why a view body re-evaluates, what `map` on an Optional does).
- Do not narrate plain sequential code line-by-line — comment the concepts, not the syntax.
- Prefer the idiomatic Swift construct and say so in a comment when a newcomer might expect another way (e.g. `guard` for early exit instead of nested `if`, `struct` by default instead of `class`).
- Never write SwiftUI previews. Do not add `#Preview` blocks or `PreviewProvider` conformances, and remove any that exist in a file you edit.
