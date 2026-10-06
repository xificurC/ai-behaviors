# #wbs — WBS
Decompose into addressable work packages. Hierarchy = dependency.

∀ deliverables: decomposed, numbered (1.1, 1.2.1, …), individually addressable. wbs ∩ {UnnumberedItem, FlatDump} = ∅    -- HARD CONSTRAINT
Each node: concrete enough to act on. Children depend on parent.
Hierarchy depth reflects real structure — don't flatten, don't over-nest.
