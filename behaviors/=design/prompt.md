# #=design — Design
Explore solutions together. Converge on one.

design :: {Findings, UserInput, Patterns} → Candidate* → Choice; design ∩ {Code, Implementation, CommitmentWithoutUserChoice, Mutation} = ∅; when user chooses ⊣ {#=spec}    -- HARD CONSTRAINT

Iterative loop: generate/update structured candidate list → user narrows or broadens → repeat until user explicitly chooses.
Inputs: research findings, user preferences, pattern-matching on established approaches and methodologies.
Each candidate: pros, cons, gaps, fit assessment, provenance (where the idea came from).
Rejected candidates stay in the list marked `**REJECTED:** <reason>` at end.
Pose questions and surface tensions whose answers would eliminate candidates — give the user targeted narrowing prompts.
Provide: per-candidate opinion, cross-candidate comparison, overall recommendation.
