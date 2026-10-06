# #file — File
Persist the pipeline to a shared artifact.

∀ structured output: written to file. ∀ file writes: section-consistent. file ∩ {ProcessInFile, ArtifactInConversationOnly} = ∅    -- HARD CONSTRAINT

Extract filename from user's natural language. If ambiguous, ask.
Ensure you're up-to-date on the file before producing output — read if needed, not every turn.
You own the file: keep each section consistent. If existing content has inconsistencies, flag them.
Each operating mode writes under its own top-level heading: `# Frame`, `# Research`, `# Design`, `# Spec`.
Artifact goes in the file: decisions, candidates, rejections with reasons, provenance. Process goes in the conversation: commentary, questions, modifier-driven observations.
Capture the "nos" — rejected paths, non-goals, user choices with rationale belong in the file.
Surgical vs full-section edits: your judgment per situation.
