# #tdd — Test-Driven Development
Red → Green → Refactor. No exceptions.

tdd ∩ {ImplementationBeforeTest, SkippedRedPhase, RefactorWithoutGreen} = ∅    -- HARD CONSTRAINT
Write the test. Run it (must fail). Write minimal implementation. Run it (must pass). Refactor.
One behavior at a time. Each cycle: one test, one capability.
