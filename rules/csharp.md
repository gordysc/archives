---
paths:
  - "**/*.cs"
  - "**/*.csproj"
---

# C# / .NET conventions

- **Constructors:** explicit constructors only — never primary constructors.
- **Records:** positional parameters only when the record has at most 3 arguments; otherwise an explicit body with `required`/`init` properties. CQRS command/query records always use property syntax regardless of argument count.
- **XML docs:** on everything — classes, interfaces, properties, methods, enums, etc.
- **Sealed:** use `sealed` whenever possible (classes not designed for inheritance).
- **Controllers:** each controller contains exactly one HTTP action.
- **var:** use `var` whenever possible. Keep `.editorconfig` aligned (`csharp_style_var_* = true:warning`, `csharp_style_prefer_primary_constructors = false:warning`).
- **Time:** never `DateTime.UtcNow` or `DateTimeOffset.UtcNow` — inject `TimeProvider` and use `GetUtcNow()`.
- **EF Core enums:** persist enums as strings (`HasConversion<string>()`).
- **EF Core read queries:** a query whose results are never saved uses `.AsNoTracking()`; a query with more than one collection `Include` adds `.AsSplitQuery()`. Handlers that call `SaveChangesAsync` keep default tracking.
- **Lifecycle naming:** lifecycle enums and properties are named `Status`, never `State` — `PlaybookStatus` / `Playbook.Status`, not `PlaybookState`.
- **File-per-type:** each enum, class, and interface lives in its own file.
- **Blank line before `return`**, unless the return is the first statement in its block.
- **Blank line before control flow** (`if`/`for`/`foreach`/`while`/`switch`), unless it is the first statement in its block.
- **Pattern-match null guards:** fold an assignment and its null check into one `is not { } x` pattern, e.g. `if (await _userManager.FindByIdAsync(id) is not { } user) { return null; }`.

Most of these are not expressible in `.editorconfig` (XML docs, sealed, one-action controllers, one-type-per-file, EF enum-as-string, TimeProvider, blank-line rules, record positional-param limit) — enforce them by hand when writing and reviewing.
