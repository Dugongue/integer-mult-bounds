# Finite staged capacity and explicit boundary stock

The source examined was OpenAI MatrixMultiplication/Recovery/FiniteSchedule. Its lotTick and stageActive_iff_unique_lot identify each active lot at each stage; sum_tick_minima and finite_schedule_yield retain exact boundary deficits instead of assuming a steady-state average. FieldConstruction/ScheduledYield connects these capacities to actual physical order. These sources were read only. They motivate a capacity-first screening discipline; no matrix multiplication theorem was directly instantiated as an owner-packing certificate.

For the retained uniform K-pair architecture with T = 8, the proposed full geometry has m = 16K + 9, L = 2K + 1 calls per replica, W = 240KT data families, 240T(K-1) pending rank-8 children, and 480T children of each rank 16j for 1 <= j < K. These are the literal stock and boundary counts; no large-T limit is taken. Every local call is paid L*T times, every positive unused remainder is paid, and the resulting deficit is independently recomputed from mW minus total child rank.

We also screened a sufficient auxiliary-stock accounting model: each new whole-owner family contributes m live dimensions, hosts only disjoint residual axes, and pays all unused axes as padding. Any padding above the halving cap is split and both pieces are charged. This is an aggregate necessary gate, not a completed chronological witness; it cannot certify an algorithm by itself.

The bounded native integer optimizer gave these unfavorable full-profile nominal roots for the current rank-sector source:

- K = 5: b about 0.00139605817, deficit 3264.
- K = 6: b about 0.00136873226, deficit 4032.
- K = 3 without extra owners: no aggregate feasible inventory.
- K = 3 with every auxiliary owner and padding child charged: live stock 7188 instead of 5760, b about 0.00135393032, deficit 1728.

All lose to the existing literal K = 4 controller, whose supplier root is about 0.00140418225. No new architecture gain, universal optimality theorem, or new kappa is asserted. We stopped this family after these early gates and retained the scripts and optimizer outputs to prevent repeated work. A changed local provider must be priced anew; the screen does not exclude another architecture or a nonuniform constructive controller.
