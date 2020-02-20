section \<open> Tactic Support for SI type expressions. \<close>

theory SI_Proof
  imports SI_Quantities
begin

named_theorems si_transfer

definition magnQuant :: "'a['u::si_type] \<Rightarrow> 'a" ("\<lbrakk>_\<rbrakk>\<^sub>Q") where
[si_def]: "magnQuant x = magn (fromQ x)"

lemma unit_eq_iff_magn_eq [si_transfer]:
  "x = y \<longleftrightarrow> \<lbrakk>x\<rbrakk>\<^sub>Q = \<lbrakk>y\<rbrakk>\<^sub>Q"
  by (auto simp add: magnQuant_def, transfer, simp)

lemma unit_equiv_iff [si_transfer]:
  fixes x :: "'a['u\<^sub>1::si_type]" and y :: "'a['u\<^sub>2::si_type]"
  shows "x \<cong>\<^sub>Q y \<longleftrightarrow> \<lbrakk>x\<rbrakk>\<^sub>Q = \<lbrakk>y\<rbrakk>\<^sub>Q \<and> SI('u\<^sub>1) = SI('u\<^sub>2)"
proof -
  have "\<forall>t ta. (ta::'a['u\<^sub>2]) = t \<or> magn (fromQ ta) \<noteq> magn (fromQ t)"
    by (simp add: magnQuant_def unit_eq_iff_magn_eq)
  then show ?thesis
    by (metis (full_types) qequiv.rep_eq coerceQuant_eq_iff2 eq_ magnQuant_def)
qed

lemma unit_le_iff_magn_le [si_transfer]:
  "x \<le> y \<longleftrightarrow> \<lbrakk>x\<rbrakk>\<^sub>Q \<le> \<lbrakk>y\<rbrakk>\<^sub>Q"
  by (auto simp add: magnQuant_def; (transfer, simp))

lemma magnQuant_zero [si_eq]: "\<lbrakk>0\<rbrakk>\<^sub>Q = 0"
  by (simp add: magnQuant_def, transfer, simp)

lemma magnQuant_one [si_eq]: "\<lbrakk>1\<rbrakk>\<^sub>Q = 1"
  by (simp add: magnQuant_def, transfer, simp)

lemma magnQuant_plus [si_eq]: "\<lbrakk>x + y\<rbrakk>\<^sub>Q = \<lbrakk>x\<rbrakk>\<^sub>Q + \<lbrakk>y\<rbrakk>\<^sub>Q"
  by (simp add: magnQuant_def, transfer, simp)

lemma magnQuant_minus [si_eq]: "\<lbrakk>x - y\<rbrakk>\<^sub>Q = \<lbrakk>x\<rbrakk>\<^sub>Q - \<lbrakk>y\<rbrakk>\<^sub>Q"
  by (simp add: magnQuant_def, transfer, simp)

lemma magnQuant_uminus [si_eq]: "\<lbrakk>- x\<rbrakk>\<^sub>Q = - \<lbrakk>x\<rbrakk>\<^sub>Q"
  by (simp add: magnQuant_def, transfer, simp)

lemma magnQuant_scaleQ [si_eq]: "\<lbrakk>x *\<^sub>Q y\<rbrakk>\<^sub>Q = x * \<lbrakk>y\<rbrakk>\<^sub>Q"
  by (simp add: magnQuant_def, transfer, simp)

lemma magnQuant_qtimes [si_eq]: "\<lbrakk>x \<^bold>\<cdot> y\<rbrakk>\<^sub>Q = \<lbrakk>x\<rbrakk>\<^sub>Q \<cdot> \<lbrakk>y\<rbrakk>\<^sub>Q"
  by (simp add: magnQuant_def, transfer, simp)

lemma magnQuant_qinverse [si_eq]: "\<lbrakk>x\<^sup>-\<^sup>\<one>\<rbrakk>\<^sub>Q = inverse \<lbrakk>x\<rbrakk>\<^sub>Q"
  by (simp add: magnQuant_def, transfer, simp)

lemma magnQuant_qdivivide [si_eq]: "\<lbrakk>(x::('a::field)[_]) \<^bold>/ y\<rbrakk>\<^sub>Q = \<lbrakk>x\<rbrakk>\<^sub>Q / \<lbrakk>y\<rbrakk>\<^sub>Q"
  by (simp add: magnQuant_def, transfer, simp add: field_class.field_divide_inverse)

lemma magnQuant_numeral [si_eq]: "\<lbrakk>numeral n\<rbrakk>\<^sub>Q = numeral n"
  apply (induct n, simp_all add: si_def)
  apply (metis magnQuant_def magnQuant_one)
  apply (metis magnQuant_def magnQuant_plus numeral_code(2))
  apply (metis magnQuant_def magnQuant_one magnQuant_plus numeral_code(3))
  done

lemma magnQuant_mk [si_eq]: "\<lbrakk>UNIT('u::si_type)\<rbrakk>\<^sub>Q = 1"
  by (simp add: magnQuant_def, transfer, simp)

text \<open> The following tactic breaks an SI conjecture down to numeric and unit properties \<close>

method si_simp uses add =
  (simp add: add si_transfer si_eq)

text \<open> The next tactic additionally compiles the semantics of the underlying units \<close>

method si_calc uses add = 
  (si_simp add: add; simp add: si_def add)

(*
lemmas [si_eq] = si_sem_Length_def si_sem_Mass_def si_sem_Time_def 
                   si_sem_Current_def si_sem_Temperature_def si_sem_Amount_def
                   si_sem_Intensity_def si_sem_NoDimension_def
                   si_sem_UnitTimes_def si_sem_UnitInv_def
                   inverse_Unit_ext_def times_Unit_ext_def one_Unit_ext_def

lemmas [si_def] =  si_sem_Length_def si_sem_Mass_def si_sem_Time_def 
                   si_sem_Current_def si_sem_Temperature_def si_sem_Amount_def
                   si_sem_Intensity_def si_sem_NoDimension_def

                   si_sem_UnitTimes_def si_sem_UnitInv_def
                   times_Unit_ext_def one_Unit_ext_def
*)

lemma "SI(N \<cdot> \<Theta> \<cdot> N) = SI(\<Theta> \<cdot> N\<^sup>2)" by (simp add: si_eq si_def)

lemma "(meter \<^bold>\<cdot> second\<^sup>-\<^sup>\<one>) \<^bold>\<cdot> second \<cong>\<^sub>Q meter"
  by (si_calc)

end