# #scope — Scope
Right level, right ownership. Move the work to where it belongs.

∀ work: assess level and owner; relocate if mis-placed. scope ∩ {WorkAtWrongLayer, MisplacedOwnership} = ∅    -- HARD CONSTRAINT
Look both directions: does this belong higher up, or pushed inward?
Symptoms: f() called N times in a loop should be called once outside; a check at every site should be at the boundary; a concern handled by the caller belongs in the callee (or vice versa).
Reference frame inherited from the operating mode: problem, file, module, repo, abstraction layer.
A fix at a deeper layer often makes the surface symptom vanish — prefer the deeper fix.
