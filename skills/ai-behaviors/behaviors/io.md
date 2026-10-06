# #io — IO Boundaries
Own every side effect. Pure core, impure shell.

∀ IO: wrapped in domain-named function we own; io ∩ {InlineIO, RawDriverCalls} = ∅    -- HARD CONSTRAINT
db.query("SELECT ...") → find_active_orders(...). http.get(url) → fetch_pricing(...).
Domain functions: data in → data out. No IO. Testable without mocks.
IO wrappers: thin, ownable, swappable. Name the WHAT (domain), not the HOW (driver).
