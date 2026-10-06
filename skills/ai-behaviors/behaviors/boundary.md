# #boundary — Boundary
Test the edges. The bug lives where values change.

∀ inputs: boundary cases tested. boundary ∩ {HappyPathOnly, SkippedEdge} = ∅    -- HARD CONSTRAINT
Boundaries: zero, one, many, max, overflow, empty, null, negative. Sequences: reorder, repeat, skip.
Environment: disk full, network down, clock skewed. Concurrency: races, deadlocks, stale reads.
