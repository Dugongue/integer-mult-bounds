import Mathlib.GroupTheory.FreeGroup.Basic
import Mathlib.Algebra.BigOperators.Group.List.Basic
import Mathlib.Algebra.Ring.Basic

/-! Exact semantic substitution for a quotient-aware word auditor.
Generator assumptions are equalities in the actual operator group, including phase.
A symplectic table, Fourier rank, or unframed circuit label alone does not establish them.
-/
namespace IntegerKappaSemanticWords

/-- Replace generators by arbitrary signed words whose actual operators agree. -/
theorem substitution_preserves_eval {ι κ G : Type*} [Group G]
    (σ : ι → G) (τ : κ → G) (normal : ι → FreeGroup κ)
    (h : ∀ i, σ i = FreeGroup.lift τ (normal i)) (w : FreeGroup ι) :
    FreeGroup.lift σ w = FreeGroup.lift τ (FreeGroup.lift normal w) := by
  exact (FreeGroup.lift_unique
    ((FreeGroup.lift τ).comp (FreeGroup.lift normal))
    (fun i => by simpa using (h i).symm) (x := w)).symm

/-- Equal actual generator assignments evaluate every signed word identically. -/
theorem generator_equality_preserves_eval {ι G : Type*} [Group G]
    (σ τ : ι → G) (h : ∀ i, σ i = τ i) (w : FreeGroup ι) :
    FreeGroup.lift σ w = FreeGroup.lift τ w := by
  have hh : σ = τ := funext h
  rw [hh]

/-- Independent generator relabeling is sound when actual operators match. -/
theorem relabel_preserves_eval {ι κ G : Type*} [Group G]
    (σ : ι → G) (τ : κ → G) (label : ι → κ)
    (h : ∀ i, σ i = τ (label i)) (w : FreeGroup ι) :
    FreeGroup.lift σ w = FreeGroup.lift τ (FreeGroup.map label w) := by
  simpa [FreeGroup.map_eq_lift, Function.comp_def] using
    substitution_preserves_eval σ τ (fun i => FreeGroup.of (label i))
      (fun i => by simpa using h i) w

/-- A finite sparse polynomial may have arbitrary noncommuting coefficients. -/
def weightedEval {ι R : Type*} [Semiring R]
    (σ : ι → Rˣ) (terms : List (R × FreeGroup ι)) : R :=
  (terms.map fun t => t.1 * (FreeGroup.lift σ t.2 : R)).sum

/-- Normalize word indices while preserving every literal coefficient. -/
def normalizeTerms {ι κ R : Type*} (normal : ι → FreeGroup κ)
    (terms : List (R × FreeGroup ι)) : List (R × FreeGroup κ) :=
  terms.map fun t => (t.1, FreeGroup.lift normal t.2)

/-- Semantic signed-word substitution preserves the complete sparse polynomial. -/
theorem weighted_substitution_preserves_eval {ι κ R : Type*} [Semiring R]
    (σ : ι → Rˣ) (τ : κ → Rˣ) (normal : ι → FreeGroup κ)
    (h : ∀ i, σ i = FreeGroup.lift τ (normal i))
    (terms : List (R × FreeGroup ι)) :
    weightedEval σ terms = weightedEval τ (normalizeTerms normal terms) := by
  unfold weightedEval normalizeTerms
  simp only [List.map_map]
  congr 1
  apply List.map_congr_left
  intro t ht
  simp only [Function.comp_apply]
  rw [substitution_preserves_eval σ τ normal h t.2]

/-- A zero returned by an exact normalized polynomial checker is sufficient. -/
theorem normalized_zero_implies_original_zero {ι κ R : Type*} [Semiring R]
    (σ : ι → Rˣ) (τ : κ → Rˣ) (normal : ι → FreeGroup κ)
    (h : ∀ i, σ i = FreeGroup.lift τ (normal i))
    (terms : List (R × FreeGroup ι))
    (hz : weightedEval τ (normalizeTerms normal terms) = 0) :
    weightedEval σ terms = 0 := by
  rw [weighted_substitution_preserves_eval σ τ normal h terms, hz]

/-- An exact normalized endpoint identity transfers without assuming freeness. -/
theorem normalized_equality_implies_original_equality {ι κ R : Type*} [Semiring R]
    (σ : ι → Rˣ) (τ : κ → Rˣ) (normal : ι → FreeGroup κ)
    (h : ∀ i, σ i = FreeGroup.lift τ (normal i))
    (left right : List (R × FreeGroup ι))
    (heq : weightedEval τ (normalizeTerms normal left) =
      weightedEval τ (normalizeTerms normal right)) :
    weightedEval σ left = weightedEval σ right := by
  rw [weighted_substitution_preserves_eval σ τ normal h left,
    weighted_substitution_preserves_eval σ τ normal h right, heq]

/-- Identical input/output frames preserve and reflect exact logical equality. -/
theorem same_frames_equality_iff {G : Type*} [Group G] (L R A B : G) :
    L⁻¹ * A * R = L⁻¹ * B * R ↔ A = B := by
  constructor
  · intro h
    have hh := congrArg (fun X => L * X * R⁻¹) h
    simpa [mul_assoc] using hh
  · intro h
    rw [h]

/-- Different frames require this exact conjugated operator, including its phase. -/
theorem changed_frames_equality_iff {G : Type*} [Group G]
    (L R L' R' A A' : G) :
    L'⁻¹ * A' * R' = L⁻¹ * A * R ↔
      A' = L' * L⁻¹ * A * R * R'⁻¹ := by
  constructor
  · intro h
    have hh := congrArg (fun X => L' * X * R'⁻¹) h
    simpa [mul_assoc] using hh
  · intro h
    rw [h]
    simp [mul_assoc]

end IntegerKappaSemanticWords
