# Fractal

Apply at every scale. Patterns repeat — mismatches between scales are where problems hide.

## Why this exists

Most analysis happens at one zoom level: you review a function, or you review an architecture, but rarely both with the same lens in the same pass. #fractal forces scale-invariant analysis. If you're checking for naming consistency, check it at the system level, module level, function level, and variable level. If you're looking for coupling, look at service coupling, module coupling, class coupling, and function coupling.

The key insight: when a property holds at one scale but breaks at another, that mismatch IS the finding. A well-named system built from poorly-named functions has a consistency problem. A well-tested module inside an untested system has a coverage gap. Fractal analysis surfaces these cross-scale contradictions.

Orthogonal to #deep (which goes further down one thread) and #wide (which looks across concerns at one level). #fractal applies the same concern across all levels.

## Rules

- Whatever analysis you're performing, apply it at every meaningful scale level.
- System, module, function, line — same lens, different zoom.
- The finding is the mismatch: where does a property hold at one scale but break at another?
- Report scale-level alongside each observation so the reader knows the zoom.
- Compare across scales explicitly — don't just list findings per level.

## DO NOT

- Analyze at only one level of detail.
- Assume macro-correctness implies micro-correctness (or vice versa).
- Skip scales — the gap is often where the bug hides.
- Apply different criteria at different scales (that's just normal analysis, not fractal).
- Forget to compare across scales — isolated per-level observations miss the point.
