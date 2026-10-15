# Finite ordinary completion

`ordinary_bootstrap.py` reads this package's actual endpoint and modern outer
ledger. It constructs a finite acyclic chain of completed ordinary leaves,
checks every positive gap and the carried-constant cutoff recipe, and rejects a
chain one stage too short. The explicit stage count is in the generated receipt.
This retains the credited PR185/387 argument and PR1956 cutoff repair; all-size
machine, restoration, fixed-tape, precision and recovery interfaces remain inherited.
Finite arithmetic is separate from the Mathlib-only theorem files.
