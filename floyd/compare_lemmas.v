Require Import floyd.base.
Require Import floyd.client_lemmas.
Require Import floyd.assert_lemmas.

Local Open Scope logic.

Lemma typed_true_nullptr:
 forall v t t',
   typed_true tint (force_val (sem_cmp Ceq (tptr t) (tptr t') true2 v (Vint Int.zero))) ->
   v=nullval.
Proof.
 intros.
 destruct v; inv H.
 pose proof (Int.eq_spec i Int.zero).
 destruct (Int.eq i Int.zero); inv H1. 
 reflexivity.
Qed.

Lemma typed_true_nullptr':
  forall t t' v,
    typed_true tint (eval_binop Oeq (tptr t) (tptr t') v nullval) -> v=nullval.
Proof.
 intros. unfold eval_binop, typed_true in H.
 destruct v; inv H; auto.
 pose proof (Int.eq_spec i Int.zero).
 destruct (Int.eq i Int.zero); inv H1. 
 reflexivity.
Qed.

Lemma typed_true_Oeq_nullval:
 forall v t t',
   local (`(typed_true tint) (`(eval_binop Oeq (tptr t) (tptr t')) v `nullval)) |--
   local (`(eq nullval) v).
Proof.
intros.
 intro rho; unfold local, lift1; unfold_lift.
 apply prop_derives; intro.
 destruct (v rho); inv H.
 pose proof (Int.eq_spec i Int.zero).
 destruct (Int.eq i Int.zero); inv H1.
 reflexivity.
Qed.

Definition  binary_operation_to_comparison (op: binary_operation) :=
 match op with
 | Oeq => Some eq
 | One => Some Zne
 | Olt => Some Z.lt
 | Ole => Some Z.le
 | Ogt => Some Z.gt
 | Oge => Some Z.ge
 | _ => None
 end.

Lemma typed_true_binop_int:
  forall op op' e1 e2 Espec Delta P Q R c Post,
   binary_operation_to_comparison op = Some op' ->
   typeof e1 = tint ->
   typeof e2 = tint ->
   (PROPx P (LOCALx (tc_environ Delta :: Q) (SEPx R))) |-- local (tc_expr Delta e1) ->
   (PROPx P (LOCALx (tc_environ Delta :: Q) (SEPx R))) |-- local (tc_expr Delta e2) ->
  @semax Espec Delta (PROPx P (LOCALx 
      (`op' (`force_signed_int (eval_expr e1)) (`force_signed_int (eval_expr e2))
          :: Q) (SEPx R))) c Post ->
  @semax Espec Delta (PROPx P (LOCALx 
      (`(typed_true
          (typeof (Ebinop op e1 e2 tint)))
          (eval_expr (Ebinop op e1 e2 tint)) :: Q) (SEPx R))) c Post.
Proof.
intros.
eapply semax_pre; [clear H4 | apply H4].
eapply derives_trans with
 (local (tc_expr Delta e1) && (local (tc_expr Delta e2)
   && PROPx P (LOCALx (tc_environ Delta :: `(typed_true (typeof (Ebinop op e1 e2 tint)))(eval_expr (Ebinop op e1 e2 tint)) :: Q) (SEPx R)))).
rewrite <- andp_assoc.
apply andp_right; auto.
do 2 rewrite <- insert_local.
rewrite <- andp_assoc.
rewrite (andp_comm (local _)).
rewrite andp_assoc.
apply andp_left2.
rewrite insert_local.
apply andp_right; auto.
clear H2 H3.
do 2 rewrite insert_local.
unfold PROPx, LOCALx; intro rho; simpl; apply andp_derives; auto.
apply andp_derives; auto.
unfold local, lift1.
apply prop_derives.
unfold_lift.
intros [? [? [? [? ?]]]].
split; auto.
clear H6.
unfold tc_expr in H2,H3.
apply expr_lemmas.typecheck_expr_sound in H2; auto.
apply expr_lemmas.typecheck_expr_sound in H3; auto.
rewrite H0 in *; rewrite H1 in *.
clear H0 H1 H4.
destruct (eval_expr e1 rho); inv H2.
destruct (eval_expr e2 rho); inv H3.
unfold force_signed_int, force_int.
unfold typed_true, eval_binop in H5.
destruct op; inv H; simpl in H5.
pose proof (Int.eq_spec i i0); destruct (Int.eq i i0); inv H5; auto.
pose proof (Int.eq_spec i i0); destruct (Int.eq i i0); inv H5; auto.
intro; apply H.
rewrite <- (Int.repr_signed i).
rewrite <- (Int.repr_signed i0).
f_equal; auto.
unfold Int.lt in H5.
destruct (zlt (Int.signed i) (Int.signed i0)); inv H5; auto.
unfold Int.lt in H5.
destruct (zlt (Int.signed i0) (Int.signed i)); inv H5; omega.
unfold Int.lt in H5.
destruct (zlt (Int.signed i0) (Int.signed i)); inv H5; omega.
unfold Int.lt in H5.
destruct (zlt (Int.signed i) (Int.signed i0)); inv H5; omega.
Qed.

Definition  binary_operation_to_opp_comparison (op: binary_operation) :=
 match op with
 | Oeq => Some Zne
 | One => Some eq
 | Olt => Some Z.ge
 | Ole => Some Z.gt
 | Ogt => Some Z.le
 | Oge => Some Z.lt
 | _ => None
 end.

Lemma typed_false_binop_int:
  forall op op' e1 e2 Espec Delta P Q R c Post,
   binary_operation_to_opp_comparison op = Some op' ->
   typeof e1 = tint ->
   typeof e2 = tint ->
   (PROPx P (LOCALx (tc_environ Delta :: Q) (SEPx R))) |-- local (tc_expr Delta e1) ->
   (PROPx P (LOCALx (tc_environ Delta :: Q) (SEPx R))) |-- local (tc_expr Delta e2) ->
  @semax Espec Delta (PROPx P (LOCALx 
      (`op' (`force_signed_int (eval_expr e1)) (`force_signed_int (eval_expr e2))
          :: Q) (SEPx R))) c Post ->
  @semax Espec Delta (PROPx P (LOCALx 
      (`(typed_false
          (typeof (Ebinop op e1 e2 tint)))
          (eval_expr (Ebinop op e1 e2 tint)) :: Q) (SEPx R))) c Post.
Proof.
intros.
eapply semax_pre; [clear H4 | apply H4].
eapply derives_trans with
 (local (tc_expr Delta e1) && (local (tc_expr Delta e2)
   && PROPx P (LOCALx (tc_environ Delta :: `(typed_false (typeof (Ebinop op e1 e2 tint)))(eval_expr (Ebinop op e1 e2 tint)) :: Q) (SEPx R)))).
rewrite <- andp_assoc.
apply andp_right; auto.
do 2 rewrite <- insert_local.
rewrite <- andp_assoc.
rewrite (andp_comm (local _)).
rewrite andp_assoc.
apply andp_left2.
rewrite insert_local.
apply andp_right; auto.
clear H2 H3.
do 2 rewrite insert_local.
unfold PROPx, LOCALx; intro rho; simpl; apply andp_derives; auto.
apply andp_derives; auto.
unfold local, lift1.
apply prop_derives.
unfold_lift.
intros [? [? [? [? ?]]]].
split; auto.
clear H6.
unfold tc_expr in H2,H3.
apply expr_lemmas.typecheck_expr_sound in H2; auto.
apply expr_lemmas.typecheck_expr_sound in H3; auto.
rewrite H0 in *; rewrite H1 in *.
clear H0 H1 H4.
destruct (eval_expr e1 rho); inv H2.
destruct (eval_expr e2 rho); inv H3.
unfold force_signed_int, force_int.
unfold typed_true, eval_binop in H5.
destruct op; inv H; simpl in H5.
pose proof (Int.eq_spec i i0); destruct (Int.eq i i0); inv H5; auto.
intro; apply H.
rewrite <- (Int.repr_signed i).
rewrite <- (Int.repr_signed i0).
f_equal; auto.
pose proof (Int.eq_spec i i0); destruct (Int.eq i i0); inv H5; auto.
unfold Int.lt in H5.
destruct (zlt (Int.signed i) (Int.signed i0)); inv H5; auto.
unfold Int.lt in H5.
destruct (zlt (Int.signed i0) (Int.signed i)); inv H5; omega.
unfold Int.lt in H5.
destruct (zlt (Int.signed i0) (Int.signed i)); inv H5; omega.
unfold Int.lt in H5.
destruct (zlt (Int.signed i) (Int.signed i0)); inv H5; omega.
Qed.

Lemma typed_false_One_nullval:
 forall v t t',
   local (`(typed_false tint) (`(eval_binop One (tptr t) (tptr t')) v `nullval)) |--
    local (`(eq nullval) v).
Proof.
intros. 
 intro rho; unfold local, lift1; unfold_lift.
 apply prop_derives; intro.
 destruct (v rho); inv H.
 pose proof (Int.eq_spec i Int.zero).
 destruct (Int.eq i Int.zero); inv H1. 
 reflexivity.
Qed. 

Lemma typed_true_One_nullval:
 forall v t t',
   local (`(typed_true tint) (`(eval_binop One (tptr t) (tptr t')) v `nullval)) |--
   local (`(ptr_neq nullval) v).
Proof.
intros.
 intro rho; unfold local, lift1; unfold_lift.
 apply prop_derives; intro.
 unfold ptr_neq, ptr_eq; simpl; intro.
 destruct (v rho); try contradiction.
 pose proof (Int.eq_spec Int.zero i). destruct H0. rewrite H0 in H1.
 subst. inv H.
Qed.


Lemma typed_false_Oeq_nullval:
 forall v t t',
   local (`(typed_false tint) (`(eval_binop Oeq (tptr t) (tptr t')) v `nullval)) |--
   local (`(ptr_neq nullval) v).
Proof.
intros. subst.
 unfold_lift; intro rho.  unfold local, lift1; apply prop_derives; intro.
 intro. apply ptr_eq_e in H0. rewrite <- H0 in H.
 inv H.
Qed.

Lemma local_entail_at: 
  forall n S T (H: local S |-- local T)
    P Q R,
    nth_error Q n = Some S ->
    PROPx P (LOCALx Q (SEPx R)) |-- 
    PROPx P (LOCALx (replace_nth n Q T) (SEPx R)).
Proof.
 intros.
 unfold PROPx, LOCALx; simpl; intro rho;  apply andp_derives; auto.
 apply andp_derives; auto.
 unfold local, lift1.
 specialize (H rho). unfold local,lift1 in H.
 revert Q H0; induction n; destruct Q; simpl; intros; inv H0.
 unfold_lift; repeat rewrite prop_and.
 apply andp_derives; auto.
  unfold_lift; repeat rewrite prop_and.
 apply andp_derives; auto.
Qed.

Lemma local_entail_at_semax_0:
  forall Espec Delta P Q1 Q1' Q R c Post,
   local Q1 |-- local Q1' ->
   @semax Espec Delta (PROPx P (LOCALx (Q1'::Q) (SEPx R))) c Post  ->
   @semax Espec Delta (PROPx P (LOCALx (Q1::Q) (SEPx R))) c Post.
Proof.
intros.
eapply semax_pre0.
eapply (local_entail_at 0).
apply H. reflexivity.
auto.
Qed.

Ltac simplify_typed_comparison :=
match goal with
| |- semax _ (PROPx _ (LOCALx (`(typed_true _) ?A :: _) _)) _ _ =>
 (eapply typed_true_binop_int;
   [reflexivity | reflexivity | reflexivity 
   | try solve [go_lower; apply prop_right; auto ] 
   | try solve [go_lower; apply prop_right; auto ] 
   | ])
 ||
  (let a := fresh "a" in set (a:=A); simpl in a; unfold a; clear a;
   eapply local_entail_at_semax_0; [  
    first [ apply typed_true_Oeq_nullval
           | apply typed_true_One_nullval
           ]
    |  ])
| |- semax _ (PROPx _ (LOCALx (`(typed_false _) ?A :: _) _)) _ _ =>
 (eapply typed_false_binop_int;
   [reflexivity | reflexivity | reflexivity 
   | try solve [go_lower; apply prop_right; auto ] 
   | try solve [go_lower; apply prop_right; auto ] 
   | ])
 ||
  let a := fresh "a" in set (a:=A); simpl in a; unfold a; clear a;
   eapply local_entail_at_semax_0; [  
    first [ apply typed_false_Oeq_nullval
           | apply typed_false_One_nullval
           ]
    |  ]
| |- _ => idtac
end.

(*
Goal forall i, force_signed_int (Vint i) = Int.signed i.
intros.
simpl.
Abort.
*)
