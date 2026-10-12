# Allocation-aware response-circuit exchange

Conditional **kappa = 0.001402427047420522**, exactly `701213523710261/500000000000000000`: **0.015245% above our preceding checked construction**, 0.001402213284556683. The complex supplier binds at b = `351099152803348559509/250000000000000000000000`; the unchanged cited PR493 bit supplier is c = `391360506745414227149/250000000000000000000000`. This is a small checked improvement, not a new algorithmic regime.

The construction removes the old response circuit at pivot 299 and installs a new two-pivot circuit at helpers 357 and 443. This changes the local profile by {1:+1,2:+2,3:-2} and the residual inventory to {7:18,8:162,9:380}. Reallocating all 40,320 whole-helper uses gives the complete paid profile `{'1': 178200, '2': 13248, '3': 40048, '4': 6336, '5': 21016, '6': 8928, '7': 160, '8': 1224, '48': 800}`. The new circuit choice and the physical allocation are priced together; headline gains are never added.

Run with Python 3.11 or later, standard library only, assertions enabled:

```
python -B verify.py --work /absolute/path/to/a-new-output-directory
```

Sixteen stages reconstruct the supplier, check all 800 scalar columns in both orientations and 100 omission controls, exact phases and paid wrappers, every physical owner and remainder, the actual scalar-prefix invoice, two rational moment engines and 47 strict outer inequalities. A full fresh CRLF replay passed. Generated gzip serialization explicitly pins compression level 9, timestamp 0 and OS header 255; immutable input archives retain their original bytes.

The new scalar program requires 210 global prefix bits under 512 charged. Live stock 7,680, physical stock 8,258, ambient dimension 73 and rank deficit 2,496 remain. All 560 helper registers are retained and arbitrary dirty contents are restored.

Four new OpenAI-source routes were tested. The response-rank/allocation combination wins; output-sector decomposition, alternative finite schedules and character-projector delivery did not add further savings. RESEARCH.md and research-notes/ preserve those outcomes and source hashes; older appended notes are historical ancestry. No four-gain claim is made.

This is a conditional finite construction. Inherited all-size compiler, common-label/mutable-basis transport, normalized Lemma A realization, restored-row, precision/tape and analytic-transfer contracts remain dependencies. No unconditional multiplication theorem or fresh Lean certification is claimed. The snapshot is frozen through PR521; nothing is published by this package.
