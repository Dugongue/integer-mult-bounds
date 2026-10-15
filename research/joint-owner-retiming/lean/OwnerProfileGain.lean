import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring

/-!
Sufficient power-cost certificates for the new literal owner reassignment.
The exact changed histogram is +28 C1 -30 C5 +C26 +2 C48.
These theorems prove the cost implication, not physical realizability or an
integer multiplication theorem. The finite owner checker supplies realizability.
-/
namespace IntegerKappaOwnerProfileGain

/-- A sufficient algebraic compaction certificate: the total mass is preserved,
and the proposed large-bin cost has a quadratic upper bound in the old price.
This can be reused with different rank inventories and any pricing function. -/
theorem quadratic_compaction_strict (a n S N x y : ℝ) (ha : 0 < a)
    (hx : x < a) (hmass : N * a = S + n)
    (hupper : a ^ 2 * y ≤ S * x ^ 2) (hthreshold : 0 < S * x - n * a) :
    n + y < N * x := by
  have hprod := mul_neg_of_neg_of_pos (sub_neg.mpr hx) hthreshold
  have hid : (x-a) * (S*x-n*a) = S*x^2 - N*a^2*x+n*a^2 := by
    calc
      (x-a) * (S*x-n*a) = S*x^2-(S+n)*a*x+n*a^2 := by ring
      _ = S*x^2-N*a^2*x+n*a^2 := by rw [← hmass]; ring
  rw [hid] at hprod
  have hscaled : a ^ 2 * (n + y - N*x) < 0 := by nlinarith
  by_contra hn
  have hnonneg := mul_nonneg (le_of_lt (sq_pos_of_pos ha)) (show 0 ≤ n+y-N*x by linarith)
  linarith

theorem rpow_linear_upper (a r p : ℝ) (ha : 0 < a) (har : a ≤ r)
    (hp : p ≤ 1) : r ^ p ≤ (r / a) * a ^ p := by
  have hr : 0 < r := lt_of_lt_of_le ha har
  have h := Real.rpow_le_rpow_of_nonpos ha har (sub_nonpos.mpr hp)
  rw [Real.rpow_sub_one (ne_of_gt hr), Real.rpow_sub_one (ne_of_gt ha)] at h
  have h' := (div_le_div_iff₀ hr ha).mp h
  calc
    r ^ p ≤ (r * a ^ p) / a := (le_div_iff₀ ha).mpr (by nlinarith [h'])
    _ = (r / a) * a ^ p := by ring

theorem owner_exchange_strict (p : ℝ) (hp : p < 1)
    (hx : (70 / 61 : ℝ) < (5 : ℝ) ^ p) :
    28 + (26 : ℝ) ^ p + 2 * (48 : ℝ) ^ p < 30 * (5 : ℝ) ^ p := by
  have h26 := rpow_linear_upper 25 26 p (by norm_num) (by norm_num) hp.le
  have h48 := rpow_linear_upper 25 48 p (by norm_num) (by norm_num) hp.le
  have h25 : (25 : ℝ) ^ p = ((5 : ℝ) ^ p) ^ 2 := by
    rw [show (25 : ℝ) = 5 * 5 by norm_num, Real.mul_rpow (by norm_num) (by norm_num), pow_two]
  rw [h25] at h26 h48
  have h5 : (5 : ℝ) ^ p < 5 := by
    simpa only [Real.rpow_one] using
      (Real.rpow_lt_rpow_of_exponent_lt (by norm_num : (1 : ℝ) < 5) hp)
  have hfac : (((5 : ℝ) ^ p) - 5) * ((122 / 25 : ℝ) * (5 : ℝ) ^ p - 28 / 5) < 0 :=
    mul_neg_of_neg_of_pos (by linarith) (by linarith)
  norm_num at h26 h48
  nlinarith [hfac]

theorem owner_exchange_half_to_one (p : ℝ) (hp0 : (1 / 2 : ℝ) ≤ p) (hp1 : p < 1) :
    28 + (26 : ℝ) ^ p + 2 * (48 : ℝ) ^ p < 30 * (5 : ℝ) ^ p := by
  apply owner_exchange_strict p hp1
  have hx : 0 ≤ (5 : ℝ) ^ p := Real.rpow_nonneg (by norm_num) p
  have hs : (5 : ℝ) ≤ ((5 : ℝ) ^ p) ^ 2 := by
    calc
      (5 : ℝ) = (5 : ℝ) ^ (1 : ℝ) := by rw [Real.rpow_one]
      _ ≤ (5 : ℝ) ^ (p * 2) := Real.rpow_le_rpow_of_exponent_le (by norm_num) (by linarith)
      _ = ((5 : ℝ) ^ p) ^ 2 := by rw [Real.rpow_mul (by norm_num)]; norm_num
  by_contra hn
  have hbound : (5 : ℝ) ^ p ≤ (70 / 61 : ℝ) := le_of_not_gt hn
  have hprod : 0 ≤ (2 - (5 : ℝ) ^ p) * (2 + (5 : ℝ) ^ p) :=
    mul_nonneg (by linarith) (by linarith)
  nlinarith

theorem moment_profile_transfer (p oldMoment newMoment : ℝ)
    (hp0 : (1 / 2 : ℝ) ≤ p) (hp1 : p < 1)
    (hprofile : newMoment = oldMoment + 28 + (26 : ℝ) ^ p +
      2 * (48 : ℝ) ^ p - 30 * (5 : ℝ) ^ p) : newMoment < oldMoment := by
  have h := owner_exchange_half_to_one p hp0 hp1
  linarith

theorem strict_acceptance_transfer (p oldMoment newMoment cap : ℝ)
    (hp0 : (1 / 2 : ℝ) ≤ p) (hp1 : p < 1)
    (hprofile : newMoment = oldMoment + 28 + (26 : ℝ) ^ p +
      2 * (48 : ℝ) ^ p - 30 * (5 : ℝ) ^ p)
    (hold : oldMoment ≤ cap) : newMoment < cap := by
  exact lt_of_lt_of_le (moment_profile_transfer p oldMoment newMoment hp0 hp1 hprofile) hold

/-- Covers the positive common normalization in the actual recursion moment. -/
theorem normalized_moment_transfer (p oldMoment newMoment scale : ℝ)
    (hp0 : (1 / 2 : ℝ) ≤ p) (hp1 : p < 1) (hscale : 0 < scale)
    (hprofile : newMoment = oldMoment + scale *
      (28 + (26 : ℝ) ^ p + 2 * (48 : ℝ) ^ p - 30 * (5 : ℝ) ^ p)) :
    newMoment < oldMoment := by
  have h := owner_exchange_half_to_one p hp0 hp1
  have hn : 28 + (26 : ℝ) ^ p + 2 * (48 : ℝ) ^ p - 30 * (5 : ℝ) ^ p < 0 := by linarith
  have hs := mul_neg_of_pos_of_neg hscale hn
  linarith

end IntegerKappaOwnerProfileGain

#print axioms IntegerKappaOwnerProfileGain.quadratic_compaction_strict
#print axioms IntegerKappaOwnerProfileGain.rpow_linear_upper
#print axioms IntegerKappaOwnerProfileGain.owner_exchange_strict
#print axioms IntegerKappaOwnerProfileGain.owner_exchange_half_to_one
#print axioms IntegerKappaOwnerProfileGain.moment_profile_transfer
#print axioms IntegerKappaOwnerProfileGain.strict_acceptance_transfer
#print axioms IntegerKappaOwnerProfileGain.normalized_moment_transfer
