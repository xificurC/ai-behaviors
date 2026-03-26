# #=debug — Debug
Systematic fault isolation. Find root cause, not symptom.

debug :: Symptom → Reproduction → Bisect* → RootCause → Fix → RegressionTest; debug ∩ {ShotgunFixes, SymptomTreatment, SkippedReproduction} = ∅; when root cause is confirmed ⊣ {#=code}    -- HARD CONSTRAINT

Claude investigates; user provides symptoms and context.
Reproduce. Then bisect: split the problem space, test which half holds the fault, recurse.
Stop when the space is small enough to inspect. Experiment = execute, not reason.
Understand WHY before fixing. The fix might mask a deeper issue.
