import Mathlib.Data.Nat.Log
import Mathlib.Tactic
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring

/-- Every actual rank-at-most-64 floor child has the required contraction. -/
theorem k5_floor_child_contract (e r : ℕ) (hr : r ≤ 64) :
    89 * (r * (e/89)) ≤ 64 * e := by
  calc
    89 * (r * (e/89)) = r * ((e/89)*89) := by ring
    _ ≤ r*e := Nat.mul_le_mul_left r (Nat.div_mul_le_self e 89)
    _ ≤ 64*e := Nat.mul_le_mul_right e hr

/-- A sufficient power bound for every (possibly heterogeneous) width path. -/
theorem k5_path_power_bound (w : ℕ → ℕ)
    (hstep : ∀ n, 89 * w (n+1) ≤ 64 * w n) (n : ℕ) :
    89^n * w n ≤ 64^n * w 0 := by
  induction n with
  | zero => simp
  | succ n ih =>
    calc
      89^(n+1) * w (n+1) = 89^n * (89*w (n+1)) := by ring
      _ ≤ 89^n * (64*w n) := Nat.mul_le_mul_left _ (hstep n)
      _ = 64 * (89^n*w n) := by ring
      _ ≤ 64 * (64^n*w 0) := Nat.mul_le_mul_left _ ih
      _ = 64^(n+1)*w 0 := by ring

/-- Nineteen levels achieve nine complete halvings, including all floors. -/
theorem k5_nineteen_step_contract (w : ℕ → ℕ)
    (hstep : ∀ n, 89 * w (n+1) ≤ 64 * w n) (k : ℕ) :
    512 * w (k+19) ≤ w k := by
  have h := k5_path_power_bound (fun n => w (k+n))
    (fun n => by simpa [Nat.add_assoc] using hstep (k+n)) 19
  simp only [Nat.add_zero] at h
  have hratio : 512 * 64^19 ≤ (89 : ℕ)^19 := by norm_num
  have hc : 89^19 * (512*w (k+19)) ≤ 89^19*w k := by
    calc
      89^19 * (512*w (k+19)) = 512*(89^19*w (k+19)) := by ring
      _ ≤ 512*(64^19*w k) := Nat.mul_le_mul_left _ h
      _ = (512*64^19)*w k := by ring
      _ ≤ 89^19*w k := Nat.mul_le_mul_right _ hratio
  exact Nat.le_of_mul_le_mul_left hc (by norm_num)

/-- Iterate the exact grouped contraction without replacing it by degree three. -/
theorem k5_grouped_power_bound (w : ℕ → ℕ)
    (hstep : ∀ n, 89 * w (n+1) ≤ 64 * w n) (q : ℕ) :
    512^q * w (19*q) ≤ w 0 := by
  induction q with
  | zero => simp
  | succ q ih =>
    calc
      512^(q+1)*w (19*(q+1)) = 512^q*(512*w (19*q+19)) := by ring
      _ ≤ 512^q*w (19*q) := Nat.mul_le_mul_left _ (k5_nineteen_step_contract w hstep (19*q))
      _ ≤ w 0 := ih

/-- A binary width bound yields a finite stopping depth for every branch. -/
theorem k5_grouped_stops (w : ℕ → ℕ) (L : ℕ) (h0 : w 0 < 2^L)
    (hstep : ∀ n, 89 * w (n+1) ≤ 64 * w n) :
    w (19*((L+8)/9)) = 0 := by
  let q := (L+8)/9
  have hceil : L ≤ 9*q := by dsimp [q]; omega
  have hp : 2^L ≤ (512 : ℕ)^q := by
    calc
      2^L ≤ (2 : ℕ)^(9*q) := Nat.pow_le_pow_right (by decide) hceil
      _ = (512 : ℕ)^q := by rw [pow_mul]; norm_num
  have h := k5_grouped_power_bound w hstep q
  by_contra hz
  have hw : 1 ≤ w (19*q) := Nat.one_le_iff_ne_zero.mpr hz
  have hm := Nat.mul_le_mul_left (512^q) hw
  simp only [mul_one] at hm
  omega

/-- The grouped reserve fits the unchanged row ceiling above an explicit cutoff. -/
theorem k5_grouped_row_bound (L stock payload : ℕ)
    (hL : 128 ≤ L) (hs : stock ≤ 3960) (hp : payload ≤ 512) :
    stock*(19*((L+8)/9)) + (9909+252+2*payload)*L < 20161*L := by
  have hm : stock*(19*((L+8)/9)) ≤ 3960*(19*((L+8)/9)) :=
    Nat.mul_le_mul_right _ hs
  have hb : (9909+252+2*payload)*L ≤ (9909+252+2*512)*L :=
    Nat.mul_le_mul_right L (by omega)
  omega

/-- Sufficient grouped-depth and compiler-row assembly for the exact 64/89 ratio. -/
theorem k5_grouped_recursion_and_row (w : ℕ → ℕ) (L stock payload : ℕ)
    (hL : 128 ≤ L) (hs : stock ≤ 3960) (hp : payload ≤ 512)
    (h0 : w 0 < 2^L) (hstep : ∀ n, 89 * w (n+1) ≤ 64 * w n) :
    w (19*((L+8)/9)) = 0 ∧
      stock*(19*((L+8)/9)) + (9909+252+2*payload)*L < 20161*L := by
  exact ⟨k5_grouped_stops w L h0 hstep, k5_grouped_row_bound L stock payload hL hs hp⟩

