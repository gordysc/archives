# Targets

The coordinator writes the Targets before review 1 and gives the identical text to the implementer and every reviewer. Each row becomes a test or bench that fails when its target is missed, so a miss is caught by CI instead of by a review round.

## Format

```markdown
## Targets for #<issue>

### Bound
The structure's cost per operation and memory, stated as worst case or amortized. Say which one this work must meet.

### Budgets
| Case | Budget | Measured by |
| --- | --- | --- |
| <operation> on <layout> | ≤16 ms per frame / ≤N ms / ≤N MiB | <bench or test name> |

### Worst-case layouts
Named, concrete inputs: sizes, shapes, values. "Large data" is not a layout; "100k rows of running totals over B$1:Bn" is.

### State triggers
For each state machine: every event that must end, cancel or update it.

### Spec
The reference this must match (a standard, another product's documented behaviour), cited, with the limits tested at the boundary and one past it.
```

Mark each section `n/a: <reason>` when it doesn't apply. Then go through the axes below for every domain the change touches. Each axis becomes a row, layout or trigger, or `n/a: <reason>`.

## Performance and data structures
- **Scale:** the product's real limit (max rows, max file size), not the demo size.
- **Thresholds:** just below and just above every cutoff: batch sizes, cache limits, fast-path conditions. Look for cliffs.
- **Shape:** contiguous vs scattered; aligned vs misaligned; one large vs many small; many duplicates vs all distinct; disjoint regions with a gap between.
- **History:** build, then modify, then shrink, then rebuild. Memory returns after removal; a cache built for old data stays correct, or is dropped, for new data.
- **Cold vs warm:** the first operation after load, with every cache empty.
- **Bystanders:** an unrelated operation next to a large structure must not pay for that structure.
- **Values:** extreme magnitudes, empty, maximum-length items.
- **Memory:** peak and retained, per-item overhead at scale, and allocation work on a single small update (a whole-structure copy or drop is O(n)).

## Interactive state
- **Triggers:** keys, clicks elsewhere (including chrome, headers and gaps), paste, scroll on both axes, window resize, focus loss, navigation shortcuts, undo/redo, the data changing underneath, accessibility and programmatic actions.
- **Sequences:** combinations, not just single events: resize down then back up, scroll then click, edit then switch then undo. A cancelled state stays cancelled.
- **Virtualized views:** anything attached to an element that unmounts when scrolled away: focus, an open editor, pointer capture, click counts, accessibility nodes.
- **Geometry:** derived state (hover, hit targets, visibility) recomputed when layout changes without pointer movement.
- **Boundaries:** inclusive vs exclusive viewport edges, partly visible items, positions beyond the last item.
- **Ordering:** compute the destination before reconciling other state that might overwrite it.
- **Choke point:** one place that every trigger passes through, plus a test that changes state by a path no hook covers.

## Text and rendering
- **Length:** very long values; per-frame work bounded by what is visible, not by stored length.
- **Characters:** zero-width, combining, soft hyphen, right-to-left and joining scripts, CJK, emoji.
- **Shaping:** kerning against synthesized glyphs (an added ellipsis), a cold font cache, fractional display scales.
- **Numbers:** scientific notation, extremes, negative zero, values narrower than their placeholder.
- **Accessibility:** what assistive tech reads matches the content and its boundaries.

## Files, paths and external tools
- **Round trip:** open → save → reopen gives identical content, including under auto-detection.
- **Never overwrite:** existing destinations, a symlink back to the source, create-new semantics. A failed open can't save over its source, including through a default or fallback name.
- **Formats:** encodings and byte-order marks; a record ending exactly at a sampling boundary.
- **Path bytes:** spaces, `& % = " \`, newlines, non-UTF-8, names at the filesystem's length limit, relative paths.
- **Generated files:** escaping for each context a value lands in; no second substitution over already-inserted text.
- **External tools:** failures propagate; optional tools may be absent; read their structured output with a real parser.
- **Isolation:** tests and CI write nothing outside their sandbox (home directory, shared caches).

## Compatibility
- **Cite the spec** for every limit and semantic, and test at the limit and one past.
- **Look-alike limits:** keep similar rules distinct (nested function calls vs grouping parentheses).
- **Provenance:** state that looks the same but means something different (accepted vs rejected input with identical text) carries that difference through copy, undo and save.

## Tests that bite
A test proves an invariant only if it fails when the invariant breaks. For each core invariant, the implementer plants a bug in a scratch copy (truncate a loop, always take one branch, skip a cleanup) and records which test caught it. A plant no test catches means a missing test.
