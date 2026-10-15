# Mathlib-only proof APIs

There are35 theorems and two supporting definitions in the checked export list.
All four source files import only Mathlib. No personal Lean module is required.

- `OwnerProfileGain.lean`: universal large-bin power bound, generic quadratic
  compaction certificate, actual owner-delta proof for every1/2<=p<1, raw and
  positively normalized moment transfer, and strict acceptance transfer.
- `ScalarRetiming.lean`: arbitrary-state list/block replacement, same-target and
  independent ADD commutation, repeated ADD fusion and exact compensated
  forwarding over any module, including full correlated dirty address arrays.
- `SemanticWordSubstitution.lean`: signed generator and weighted-polynomial
  substitutions under actual operator equalities; explicit physical frame
  conjugation conditions. It does not tensor an arbitrary sum identity.
- `GroupedDepth.lean`: universal heterogeneous64/89 path contraction,19-level
  grouping, finite stopping and sufficient row-reserve bounds. It does not assert
  that a new compiler or an improvedK5 supplier has been constructed.

Use Lean4.33.0 and the exact Mathlib revision in `EXPORTS.json`. In a standalone
checkout of this folder, `lake update` and `lake exe cache get` prepare those
dependencies; then `lake env lean OwnerProfileGain.lean` checks one file.
For the full independent audit, run:

```
python -I -B verify_lean.py --lean /path/to/lean --mathlib /path/to/mathlib \
  --packages /path/to/lake/packages --out /external/fresh-audit
```

The checker verifies the actual Mathlib Git revision and tracked-source
cleanliness, constructs its library path from Mathlib and dependency builds,
checks every listed export in fresh Lean subprocesses, and allows only
`propext`, `Classical.choice`, and `Quot.sound`. `KERNEL.json` is actual fresh
evidence, separate from the Python finite supplier replay. These proofs do not
discharge the inherited all-size machine, fixed-tape, precision or outer premises.
