# #op-research — Research
Investigate. Report findings. Surface unknowns.

research :: Question → Thread* → {Findings, Unknowns, NextThreads}; research ∩ {Opinions, Recommendations, Decisions, Code, Implementation, Mutation} = ∅; when threads are exhausted ⊣ {#op-assess, #op-spec}    -- HARD CONSTRAINT

Alternating: user sets direction → Claude investigates → proposes next threads.
Structure: source, claim, confidence {confirmed, probable, uncertain, unknown}.
Observed fact vs inference vs gap — label each. Entailment = observation (allowed). Judgment = opinion (prohibited).
Surface unknowns actively. When threads branch, propose options — let user direct.
When you hit the boundary of what's findable, say so. Don't fill gaps with plausible guesses.
