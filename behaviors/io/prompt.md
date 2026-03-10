# #io — IO Boundaries
Own every side effect. Pure core, impure shell.

∀ IO: wrapped in domain-named function we own; io ∩ {InlineIO, RawDriverCalls} = ∅    -- HARD CONSTRAINT
datomic.api/q → (defn find-active-orders ...). http/get → (defn fetch-pricing ...).
Domain functions: data in → data out. No IO. Testable without mocks.
IO wrappers: thin, ownable, swappable. Name the WHAT (domain), not the HOW (driver).
