# Output-partitioned coordinate sectors: sufficient construction and bounded gates

No new kappa gain is claimed by this lane. The accepted baseline remains the
rank-sector word with 99 pivots until another lane supplies a checked improvement.
All constructions here retain arbitrary dirty registers and their inverse cleanup.

## Actual OpenAI source

Inspected `lean/OAI/LinearAlgebra/MatrixMultiplication/AuxiliarySeparation/Tensor/DirectSum.lean`
in the downloaded OpenAI math corpus, namespace
`OAI.MatrixMultiplication.AuxiliarySeparation`.
Theorems `sumTensor_restrict` and `sumTensor_assoc` explicitly assemble independent
restriction maps on disjoint blocks and reassociate their coordinate labels.
This was source inspection, not a new Lean compilation or certification. The
application below is a separately derived finite reversible-linear construction;
the source theorem does not itself certify these circuit files.

## Sufficient output-partitioned construction

Suppose the desired coordinate rows are partitioned into groups W_j. Choose
pairwise disjoint register sets S_j whose clean row matrices T_j have independent
rows, with W_j contained in rowSpan(T_j). Assume every register in S_j can climb
monotonically into a common frame F_j, and every subsequent observer admits F_j.
Extend the coefficient rows expressing W_j in T_j to a square invertible matrix
M_j. Applying M_j on the actual registers is invertible even with arbitrary
initial dirt. Its selected outputs are exactly the requested clean coordinate
forms. Retain every complement register; reverse M_j in cleanup. Independent
sectors compose by block diagonal direct sum. No discarded clean-zero row may
be treated as a zero physical register.

For the tested checkpoint all retired rows start at rank three. A sector with n
registers, t output rows and common rank d contributes n calls of rank d-3,
t calls of rank 8-d, and n-t calls of rank 9-d before the unchanged final output
steps. Unselected retired rows contribute rank six. All terms, including zero
rank omissions, are charged. This gives a concrete sufficient circuit recipe,
not a necessary condition presented as a solution.

## Bounded output-sector screen

`output_sectors.cpp` enumerates all nonempty subsets of the twelve retired rows,
keeps independent subsets of size at most eight, tests the four coordinate
outputs for span containment, and enumerates disjoint register/output partitions.
It computes the exact binary-frame join. Discovery row ranks are modulo 1000003;
no modular discovery result is a rational certificate. No candidate was promoted.
Across all fourteen blocks there were 1280 admitted sector options and 645 search
nodes per block. Best entropy equaled the existing eight-row rank-four sector;
no strict improvement was found. `OUTPUT-SECTORS.json` records the finite gate.
This is not a theorem excluding arbitrary circuits or other checkpoints.

## Complement-preserving decoders

Eight decoder completions and fourteen single-block mixtures were constructed.
All passed the constructor's clean-word identities and exact frame/response
relations with dyadic scalars. A short kernel rediscovery returned only 92
pivots; that was a weaker search result, not a forced loss. The frozen 99-pivot
selection remains legal and yields the baseline profile on the checked examples.
For fixed T and desired output rows S, every completion U has the same observed
rows S*T^{-1}; replacing unobserved complement rows cannot change this observable
linear map. This explains why complement preservation alone gives no gain here.

`COMPLEMENT-SCREEN.json` and `MIXED-COMPLEMENT-SCREEN.json` preserve the short-run
92-pivot discovery output rather than overwriting it. Those records must be read
with this correction; they do not establish the maximum admissible pivot count.

Sixteen independently selected eight-row bases were also rebuilt and screened
with the matched thirty-trial discovery budget. Every candidate retained exactly
99 pivots, widths {7:18,8:161,9:381}, and local profile
{1:2474,2:182,3:516,4:88,5:242,6:124,7:1,8:17}.
All admitted scalar coefficients were dyadic and all scales signed powers of two.
These results are in `BASIS-SCREEN.json`. Full scalar/physical replays were not
spent on non-improving candidates.

## Reusing untouched rows for later M-packet copies

A separate sufficient reuse route would zero a clean retired row through legal
same-frame elementary additions, retain its arbitrary dirt, then use it as the
later M-packet destination. The changed dirty-response matrix and reverse cleanup
must still be replayed. This is different from the older own-tetrad reuse attempt.

The actual checkpoint has 56 later extra copies, all at rank-five frames.
None admits the retired register's whole rank-four block frame. Twenty slots
admit at least one unchanged rank-three retired row (twelve slots admit two,
eight admit one). Exact rational span solving then tested whether each such row
could be zeroed using current rows already at that same rank-five frame plus
eligible untouched spares. There were no relations. This rejects that explicit
zero-then-copy recipe at this checkpoint; it does not reject other compensation
circuits, changed packet bases, or earlier coalescing.
`COALESCE-GEOMETRY.json` and `COALESCE-EXACT-GATE.json` retain these gates.
