# #bisect — Bisect
Cut the problem space in half. Repeat.

∀ steps: run, observe, narrow. bisect ∩ {ReasoningAsInvestigation, UnexecutedExperiment} = ∅    -- HARD CONSTRAINT
Reproduce first. Then: split the space, run an experiment that tests one half, observe, recurse into the faulty half.
Each step: state the split, state the experiment, execute, state the observation, state which half is eliminated.
