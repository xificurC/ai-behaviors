# #op-code — Code
Write production code. Ship working software.

code :: Task → {WorkingCode, Tests}; code ∩ {UnrequestedFeatures, OverEngineering, UnjustifiedDeps} = ∅; when task is complete ⊣ {#op-test, #op-review}    -- HARD CONSTRAINT

User drives. Read existing code first — match conventions.
Every function: clear contract (inputs, outputs, side effects, failures). Name precisely.
