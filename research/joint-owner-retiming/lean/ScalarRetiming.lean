import Mathlib.Algebra.Module.Pi
import Mathlib.Data.List.Basic
import Mathlib.Tactic.Abel

/-!
Sufficient exact retiming rules for scalar register programs.
The state module may itself be a full, correlated address array. Nothing tensors a
sum identity, assumes clean helpers, or erases the prices of physical frame changes.
-/
namespace IntegerKappaScalarRetiming

def run {S : Type*} : List (S → S) → S → S
  | [], x => x
  | f :: fs, x => run fs (f x)

def Commutes {S : Type*} (f g : S → S) : Prop := ∀ x, f (g x) = g (f x)

theorem run_append {S : Type*} (a b : List (S → S)) (x : S) :
    run (a ++ b) x = run b (run a x) := by
  induction a generalizing x with
  | nil => rfl
  | cons f fs ih => exact ih (f x)

theorem commutes_symm {S : Type*} {f g : S → S} (h : Commutes f g) :
    Commutes g f := fun x => (h x).symm

theorem run_commutes {S : Type*} (a : List (S → S)) (g : S → S)
    (h : ∀ f ∈ a, Commutes f g) : Commutes (run a) g := by
  intro x
  induction a generalizing x with
  | nil => rfl
  | cons f fs ih =>
      change run fs (f (g x)) = g (run fs (f x))
      rw [h f (by simp) x]
      exact ih (fun k hk => h k (by simp [hk])) (f x)

/-- A block can cross another block when every crossed pair commutes.
Opaque barriers can simply be kept outside the two blocks. -/
theorem retiming_blocks {S : Type*} (a b : List (S → S))
    (h : ∀ f ∈ a, ∀ g ∈ b, Commutes f g) (x : S) :
    run (a ++ b) x = run (b ++ a) x := by
  rw [run_append, run_append]
  have hh : ∀ g ∈ b, Commutes g (run a) := by
    intro g hg
    exact commutes_symm (run_commutes a g (fun f hf => h f hf g hg))
  exact run_commutes b (run a) hh x

/-- The same replacement is sound inside an arbitrary dirty-state program. -/
theorem retiming_in_context {S : Type*} (pre a b post : List (S → S))
    (h : ∀ f ∈ a, ∀ g ∈ b, Commutes f g) (x : S) :
    run (pre ++ (a ++ b) ++ post) x = run (pre ++ (b ++ a) ++ post) x := by
  simp only [run_append]
  exact congrArg (run post) (by
    simpa only [run_append] using retiming_blocks a b h (run pre x))

/-- Semantic equality of a changed block is sufficient for any continuation. -/
theorem block_replacement {S : Type*} (pre a b post : List (S → S))
    (h : ∀ x, run a x = run b x) (x : S) :
    run (pre ++ a ++ post) x = run (pre ++ b ++ post) x := by
  simp only [run_append]
  rw [h]

section Scalar
variable {ι R M : Type*} [DecidableEq ι] [Semiring R]
  [AddCommMonoid M] [Module R M]

/-- The actual logical scalar ADD, with no restriction on the initial registers. -/
def addGate (d s : ι) (c : R) (x : ι → M) : ι → M :=
  Function.update x d (x d + c • x s)

theorem addGate_same (d s : ι) (c : R) (x : ι → M) :
    addGate d s c x d = x d + c • x s := by
  simp [addGate]

theorem addGate_other (d s i : ι) (c : R) (x : ι → M) (hi : i ≠ d) :
    addGate d s c x i = x i := by
  simp [addGate, hi]

/-- No write-after-write edge is needed for two ADDs to the same destination,
provided neither source is the destination. -/
theorem addGate_same_target_commute (d s t : ι) (a b : R)
    (hs : s ≠ d) (ht : t ≠ d) :
    Commutes (addGate (M := M) d s a) (addGate d t b) := by
  intro x
  funext i
  by_cases hi : i = d
  · subst i
    simp [addGate, hs, ht, add_assoc, add_left_comm, add_comm]
  · simp [addGate, hi]

/-- Disjoint writes commute as long as neither reads the other's destination. -/
theorem addGate_distinct_target_commute (d s e t : ι) (a b : R)
    (hde : d ≠ e) (hse : s ≠ e) (htd : t ≠ d) :
    Commutes (addGate (M := M) d s a) (addGate e t b) := by
  intro x
  funext i
  by_cases hd : i = d
  · subst i
    simp [addGate, hde, hse, htd]
  · by_cases he : i = e
    · subst i
      simp [addGate, hde, Ne.symm hde, hse, htd]
    · simp [addGate, hd, he]

/-- This single read/write-hazard check permits equal destinations. -/
theorem addGate_commute_of_no_cross_hazards (d s e t : ι) (a b : R)
    (hse : s ≠ e) (htd : t ≠ d) :
    Commutes (addGate (M := M) d s a) (addGate e t b) := by
  by_cases hde : d = e
  · subst e
    exact addGate_same_target_commute d s t a b hse htd
  · exact addGate_distinct_target_commute d s e t a b hde hse htd

/-- Repeated literal ADDs may be fused, retaining their coefficient only once. -/
theorem addGate_fuse (d s : ι) (a b : R) (hs : s ≠ d) (x : ι → M) :
    addGate d s b (addGate d s a x) = addGate d s (a + b) x := by
  funext i
  by_cases hi : i = d
  · subst i
    simp [addGate, hs, add_smul, add_assoc]
  · simp [addGate, hi]

end Scalar

section Forwarding
variable {ι R M : Type*} [DecidableEq ι] [Ring R]
  [AddCommGroup M] [Module R M]

/-- Forward a read across a write by paying the exact compensating ADD.
This identity holds for arbitrary dirty registers over any module; it does not
certify that the new physical frames or the third ADD are free. -/
theorem addGate_forwarding (t q s : ι) (a b : R)
    (htq : t ≠ q) (hts : t ≠ s) (hqs : q ≠ s) (x : ι → M) :
    addGate q s b (addGate t q a x) =
      addGate t s (-(a*b)) (addGate t q a (addGate q s b x)) := by
  funext i
  by_cases hit : i = t
  · subst i
    simp [addGate, htq, Ne.symm htq, Ne.symm hts, Ne.symm hqs,
      smul_add, mul_smul, neg_smul]
    abel
  · by_cases hiq : i = q
    · subst i
      simp [addGate, htq, Ne.symm htq, Ne.symm hts, Ne.symm hqs]
    · simp [addGate, hit, hiq]

end Forwarding
end IntegerKappaScalarRetiming
