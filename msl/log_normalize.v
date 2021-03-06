Require Import msl.seplog.
(* Require Import msl.alg_seplog. *)
Require Import msl.Extensionality.

Local Open Scope logic.

Hint Resolve @derives_refl.

Lemma andp_is_allp {A}{ND: NatDed A}:
   forall P Q, andp P Q = allp (fun x : bool => if x then P else Q).
Proof.
 intros. apply pred_ext.
 apply allp_right. intro b; destruct b.
 apply andp_left1; apply derives_refl.
 apply andp_left2; apply derives_refl. 
 apply andp_right.
 apply allp_left with true; apply derives_refl.
 apply allp_left with false; apply derives_refl.
Qed.

Lemma orp_is_exp {A}{ND: NatDed A}:
   forall P Q, orp P Q = exp (fun x : bool => if x then P else Q).
Proof.
 intros. apply pred_ext.
 apply orp_left.
 apply exp_right with true; apply derives_refl.
 apply exp_right with false; apply derives_refl.
 apply exp_left; intro b; destruct b.
 apply orp_right1; apply derives_refl.
 apply orp_right2; apply derives_refl.
Qed.

Lemma modus_ponens {A}{ND: NatDed A}: forall P Q: A, derives (andp P (imp P Q)) Q.
Proof.
intros. apply derives_trans with (andp (imp P Q) P). 
  apply andp_right; [apply andp_left2 | apply andp_left1]; apply derives_refl.
 apply imp_andp_adjoint. apply derives_refl.
Qed.

Lemma modus_ponens_wand {A}{ND: NatDed A}{SL: SepLog A}: 
                      forall P Q: A, derives (sepcon P (wand P Q)) Q.
Proof.
intros.
  rewrite sepcon_comm.  apply wand_sepcon_adjoint. auto.
Qed.

Lemma wand_derives {A}{ND: NatDed A}{SL: SepLog A}:
    forall P P' Q Q': A , P' |-- P -> Q |-- Q' ->  P -* Q |-- P' -* Q'.
Proof.
intros.
 apply -> wand_sepcon_adjoint.
 eapply derives_trans; [apply sepcon_derives; [apply derives_refl | apply H] | ].
 eapply derives_trans; [ | apply H0].
 apply <- wand_sepcon_adjoint.
 auto.
Qed.

Lemma exp_andp1  {A}{ND: NatDed A}:  forall B (p: B -> A) q, andp (exp p) q = (exp (fun x => andp (p x) q)).
Proof.
 intros. apply pred_ext.
 apply imp_andp_adjoint.
 apply exp_left; intro x.
 apply imp_andp_adjoint.
 apply exp_right with x.
 apply derives_refl.
 apply exp_left; intro x.
 apply andp_right; [apply andp_left1 | apply andp_left2].
 apply exp_right with x; apply derives_refl.
 apply derives_refl.
Qed.

Lemma distrib_orp_andp {A}{ND: NatDed A}:  
   forall (P Q R : A), andp (orp P Q) R = orp (andp P R) (andp Q R).
Proof.
 intros.
 apply pred_ext.
 apply imp_andp_adjoint.
 apply orp_left.
 apply imp_andp_adjoint. apply orp_right1; apply derives_refl.
 apply imp_andp_adjoint. apply orp_right2; apply derives_refl.
 apply orp_left.
 apply andp_right; [apply andp_left1 | apply andp_left2].
 apply orp_right1; apply derives_refl.
 apply derives_refl.
 apply andp_right. apply orp_right2; apply andp_left1; apply derives_refl.
 apply andp_left2; apply derives_refl.
Qed.

Lemma sepcon_FF {A}{ND: NatDed A}{SL: SepLog A} :
           forall P: A, sepcon P FF = FF.
Proof.
 intros; apply pred_ext.
  rewrite sepcon_comm.
  apply wand_sepcon_adjoint.
 apply prop_left; intro; contradiction.
  apply prop_left; intro; contradiction.
Qed.

Lemma exp_sepcon1{A}{ND: NatDed A}{SL: SepLog A}:  
       forall T (P: T ->  A) Q,  sepcon (exp P) Q = exp (fun x => sepcon (P x) Q).
Proof.
 intros. apply pred_ext.
 apply wand_sepcon_adjoint.
 apply exp_left; intro x.
 apply wand_sepcon_adjoint.
 apply exp_right with x.
 apply derives_refl.
 apply exp_left; intro x.
 apply sepcon_derives.
 apply exp_right with x; apply derives_refl.
 apply derives_refl.
Qed.

Lemma  distrib_orp_sepcon {A}{ND: NatDed A}{SL: SepLog A}: 
      forall (P Q R : A), sepcon (P || Q) R = sepcon P R || sepcon Q R.
Proof.
 intros. apply pred_ext.
 apply wand_sepcon_adjoint.
 apply orp_left.
 apply wand_sepcon_adjoint. apply orp_right1; apply derives_refl.
 apply wand_sepcon_adjoint. apply orp_right2; apply derives_refl.
 apply orp_left; (apply sepcon_derives; [ | apply derives_refl]).
 apply orp_right1; apply derives_refl.
 apply orp_right2; apply derives_refl.
Qed. 

Lemma  distrib_sepcon_andp {A}{ND: NatDed A}{SL: SepLog A}: 
     forall P Q R, sepcon P (andp Q R) |-- andp (sepcon P Q) (sepcon P R).
Proof.
 intros.
 apply andp_right.
 apply sepcon_derives; [ apply derives_refl | ].
 apply andp_left1; apply derives_refl.
 apply sepcon_derives; [ apply derives_refl | ].
  apply andp_left2; apply derives_refl.
Qed.

Lemma later_derives {A}{ND: NatDed A}{IA: Indir A}:
   forall P Q: A, P |-- Q -> later P |-- later Q.
Proof.
  intros.
  apply derives_trans with (TT && later P).
 apply andp_right. apply prop_right; auto. apply derives_refl.
  apply imp_andp_adjoint.
  eapply derives_trans; [ | apply later_K].
  eapply derives_trans; [ | apply now_later].
 apply imp_andp_adjoint.
 apply andp_left2; auto.
Qed.

Lemma later_andp  {A}{ND: NatDed A}{IA: Indir A}:
       forall P Q: A, later (P && Q) = later P && later Q.
Proof.
 intros. repeat rewrite andp_is_allp.
 rewrite later_allp. 
 f_equal. extensionality x.
 destruct x; auto.
Qed.

Lemma later_orp  {A}{ND: NatDed A}{IA: Indir A}:
       forall P Q: A, later (P || Q) = later P || later Q.
Proof.
 intros. repeat rewrite orp_is_exp.
 repeat rewrite (later_exp' _ true).
 f_equal. extensionality x.
 destruct x; auto.
Qed.


Lemma TT_right {A}{NA: NatDed A}: forall P:A, P |-- TT.
Proof. intros; apply prop_right; auto.
Qed.

Hint Resolve @TT_right: norm.

Ltac norm := auto with norm.

Lemma andp_dup {A}{ND: NatDed A}: forall P: A, P && P = P.
Proof. intros. apply pred_ext.
apply andp_left1; apply derives_refl.
apply andp_right; apply derives_refl.
Qed.


Lemma FF_left {A}{NA: NatDed A}: forall P, FF |-- P.
Proof.
intros; apply prop_left. intuition.
Qed.
Hint Resolve @FF_left : norm.

Lemma andp_TT {A}{NA: NatDed A}: forall (P: A), P && TT = P.
Proof with norm.
intros.
apply pred_ext.
apply andp_left1...
apply andp_right...
Qed.

Lemma TT_prop_right {A}{ND: NatDed A}: forall P: Prop,
   P -> @derives A ND TT (prop P).
Proof.
intros. apply prop_right; auto.
Qed.

Lemma sepcon_andp_prop'  {A}{NA: NatDed A}{SA: SepLog A}: 
     forall (P:A)  (Q:Prop) (R: A), (!!Q && P)*R = !!Q&&(P*R).
Proof with norm.
intros.
rewrite sepcon_comm. rewrite sepcon_andp_prop.
rewrite sepcon_comm; auto.
Qed.

Lemma emp_sepcon  {A}{NA: NatDed A}{SA: SepLog A}{CA: ClassicalSep A} : forall (P:A),
   emp * P = P.
Proof with norm.
 intros; rewrite sepcon_comm. apply sepcon_emp.
Qed.

Lemma emp_wand {A}{NA: NatDed A}{SA: SepLog A}{CA: ClassicalSep A}:
   forall P: A, emp -* P = P.
Proof.
intros.
apply pred_ext.
rewrite <- (emp_sepcon (emp -* P)).
apply modus_ponens_wand.
apply wand_sepcon_adjoint.
rewrite sepcon_emp; auto.
Qed.

Lemma TT_andp {A}{NA: NatDed A}: forall P: A,  TT && P = P.
Proof with norm.
  intros. apply pred_ext. apply andp_left2... apply andp_right...
Qed.

Lemma exp_sepcon2 {A}{NA: NatDed A}{SA: SepLog A}: 
   forall T (P: A) (Q: T -> A),  P * exp Q = exp (fun x => P * Q x).
Proof. intros.
 rewrite sepcon_comm. rewrite exp_sepcon1.
 f_equal. extensionality x. apply sepcon_comm.
Qed.

Lemma andp_comm  {A}{NA: NatDed A}:
  forall P Q: A,  P && Q = Q && P.
Proof with norm.
 intros.
   apply pred_ext.
   apply andp_right. apply andp_left2... apply andp_left1...
    apply andp_right. apply andp_left2... apply andp_left1...
Qed.

Lemma andp_assoc {A} {NA: NatDed A} : forall P Q R : A,
  (P && Q) && R = P && (Q && R).
Proof.
  intros; apply pred_ext;   repeat apply andp_right.
  do 2 apply andp_left1; auto.
  apply andp_left1; apply andp_left2; auto.
  apply andp_left2; auto.
  apply andp_left1; auto.
  apply andp_left2; apply andp_left1; auto.
  do 2 apply andp_left2; auto.
Qed.

Lemma exp_andp2  {A}{NA: NatDed A}:
 forall B (p: A) (q: B -> A) , (p && exp q) = exp (fun x => p && q x).
Proof.
 intros. rewrite andp_comm; rewrite exp_andp1.
 f_equal. extensionality x. apply andp_comm.
Qed.

Hint Rewrite @sepcon_emp @emp_sepcon @TT_andp @andp_TT 
             @exp_sepcon1 @exp_sepcon2
               @exp_andp1 @exp_andp2
         @sepcon_andp_prop @sepcon_andp_prop'
        : norm.


Lemma andp_derives {A} {NA: NatDed A}:
  forall P Q P' Q': A, P |-- P' -> Q |-- Q' -> P && Q |-- P' && Q'.
Proof.
intros.
apply andp_right.
apply andp_left1; apply H.
apply andp_left2; apply H0.
Qed.

Lemma imp_derives {A} {NA: NatDed A}:
  forall P P' Q Q' : A,
    P' |-- P ->
    Q |-- Q' -> 
    P --> Q |-- P' --> Q'.
Proof.
intros.
apply imp_andp_adjoint. 
eapply derives_trans; try apply H0; clear H0.
eapply derives_trans; [ apply andp_derives; try apply H | ]; clear H.
apply derives_refl.
rewrite andp_comm. apply modus_ponens.
Qed.

Lemma FF_sepcon {A} {NA: NatDed A}{SA: SepLog A}: forall P: A, FF * P = FF.
Proof.
intros.
rewrite sepcon_comm. apply sepcon_FF.
Qed.

Hint Rewrite @FF_sepcon @sepcon_FF : norm.

Lemma prop_true_andp {A} {NA: NatDed A}:
  forall (P: Prop) (Q: A),  P -> (!! P && Q = Q).
Proof with norm.
intros.
apply pred_ext. apply andp_left2...
apply andp_right... apply prop_right...
Qed.

Ltac immediate := (assumption || reflexivity).

Hint Rewrite @prop_true_andp using (solve [immediate]) : norm.

Lemma true_eq {A} {NA: NatDed A}:  forall P: Prop, P -> (!! P) = (TT: A).
Proof with norm.
intros. apply pred_ext...
apply prop_right...
Qed. 
Hint Rewrite @true_eq using (solve [immediate]) : norm.

Lemma FF_andp {A}{NA: NatDed A}:  forall P: A, FF && P = FF.
Proof with norm.
intros. apply pred_ext...
apply andp_left1...
Qed.

Lemma andp_FF {A}{NA: NatDed A}:  forall P: A, P && FF = FF.
Proof.
intros. rewrite andp_comm. apply FF_andp.
Qed.
Hint Rewrite @FF_andp @andp_FF : norm.

Hint Rewrite @andp_dup : norm.

Lemma sepcon_TT {A} {NA: NatDed A}{SA: SepLog A}{CA: ClassicalSep A}:
   forall (P: A), P |-- (P * TT).
Proof with norm.
intros.
apply @derives_trans with (P * emp).
rewrite sepcon_emp...
apply sepcon_derives...
Qed.
Hint Resolve @sepcon_TT.

Lemma imp_extract_exp_left {B A: Type} {NA: NatDed A}:
    forall    (p : B -> A) (q: A),
  (forall x, p x |-- q) ->
   exp p |-- q.
Proof.
intros.
apply exp_left. auto.
Qed.

Lemma allp_derives: 
       forall {A: Type}  {NA: NatDed A} (B: Type) (P Q: B -> A), 
               (forall x:B, P x |-- Q x) -> (allp P |-- allp Q).
Proof.
intros.
apply allp_right; intro x; apply allp_left with x; auto.
Qed.

Lemma forall_pred_ext  {A}  {NA: NatDed A}: forall B (P Q: B -> A), 
 (ALL x : B, (P x <--> Q x)) |-- (ALL x : B, P x) <--> (ALL x: B, Q x) .
Proof.
intros.
apply andp_right.
 apply @derives_trans with (ALL x:B, P x --> Q x).
 apply allp_derives; intro x; apply andp_left1; auto.
 apply imp_andp_adjoint; apply allp_right; intro x.
 apply @derives_trans with ((P x --> Q x) && P x).
 apply andp_derives; apply allp_left with x; auto.
 rewrite andp_comm. apply modus_ponens.
 apply @derives_trans with (ALL x:B, Q x --> P x).
 apply allp_derives; intro x; apply andp_left2; auto.
 apply imp_andp_adjoint; apply allp_right; intro x.
 apply @derives_trans with ((Q x --> P x) && Q x).
 apply andp_derives; apply allp_left with x; auto.
 rewrite andp_comm. apply modus_ponens.
Qed.

Lemma exists_pred_ext  {A} {NA: NatDed A}: forall B (P Q: B -> A), 
 (ALL x : B, (P x <--> Q x)) |-- (EX x : B, P x) <--> (EX x: B, Q x) .
Proof.
intros.
apply andp_right.
 apply imp_andp_adjoint.
autorewrite with norm.
apply exp_left; intro x. apply exp_right with x.
 apply imp_andp_adjoint.
apply allp_left with x. apply andp_left1; auto.
 apply imp_andp_adjoint.
autorewrite with norm.
apply exp_left; intro x. apply exp_right with x.
 apply imp_andp_adjoint.
apply allp_left with x. apply andp_left2; auto.
Qed.

Lemma imp_pred_ext  {A}  {NA: NatDed A}: forall B B' P Q, 
       (B <--> B') && (B --> (P <--> Q)) 
 |-- (B --> P) <-->  (B' --> Q).
Proof.
intros.
apply andp_right.
apply -> imp_andp_adjoint.
apply -> imp_andp_adjoint.
rewrite andp_comm.
rewrite (andp_comm (B --> B')).
repeat rewrite <- andp_assoc.
do 2 rewrite andp_assoc.
eapply derives_trans; [eapply andp_derives; [apply modus_ponens | apply derives_refl] | ].
apply @derives_trans with ((B && (B --> (P --> Q))) && (B && (B --> P))).
repeat apply andp_right.
apply andp_left1; auto.
apply andp_left2. apply andp_left2. apply andp_left1. apply imp_derives; auto.
apply andp_left1; auto.
apply andp_left1; auto.
apply andp_left2. apply andp_left2. apply andp_left2. auto.
apply @derives_trans with ((P --> Q) && P).
apply andp_derives; apply modus_ponens.
rewrite andp_comm; apply modus_ponens.
apply -> imp_andp_adjoint.
apply -> imp_andp_adjoint.
rewrite andp_comm.
repeat rewrite <- andp_assoc.
do 2 rewrite andp_assoc.
eapply derives_trans; [eapply andp_derives; [apply modus_ponens | apply derives_refl] | ].
apply @derives_trans with ((B' && (B' --> (Q --> P))) && (B' && (B' --> Q))).
repeat apply andp_right.
apply andp_left1; auto.
repeat rewrite <- andp_assoc.
apply andp_left1.
apply -> imp_andp_adjoint.
apply andp_left1.
eapply derives_trans; [eapply andp_derives; [apply modus_ponens | apply derives_refl] | ].
eapply derives_trans; [apply modus_ponens | ].
apply andp_left2; auto.
apply andp_left1; auto.
repeat apply andp_left2. auto.
eapply derives_trans; [eapply andp_derives; apply modus_ponens | ].
rewrite andp_comm; apply modus_ponens.
Qed.

Lemma pull_right {A} {NA: NatDed A}{SA: SepLog A}:
 forall P Q R : A,
   (Q * P * R) = (Q * R * P).
Proof.
intros. repeat rewrite sepcon_assoc. rewrite (sepcon_comm P); auto.
Qed.

Lemma pull_right0 {A} {NA: NatDed A}{SA: SepLog A}:
  forall P Q : A,   (P * Q) = (Q * P).
Proof.
intros. rewrite (sepcon_comm P); auto.
Qed.

Ltac pull_left A := repeat (rewrite <- (pull_right A) || rewrite <- (pull_right0 A)).

Ltac pull_right A := repeat (rewrite (pull_right A) || rewrite (pull_right0 A)).

Lemma derives_extract_prop {A} {NA: NatDed A}:
  forall (P: Prop) (Q R: A), (P -> Q |-- R) ->  !!P && Q |-- R.
Proof.
 intros.
 apply imp_andp_adjoint.
 apply prop_left.
 intros. apply imp_andp_adjoint. rewrite TT_andp. apply H; auto.
Qed.

Lemma derives_extract_prop0 {A}{NA: NatDed A}:
    forall (P: Prop) (R: A), (P -> TT |-- R)  -> !!P |-- R.
Proof.
intros.
apply derives_trans with (!!P && TT).
rewrite andp_TT; auto.
apply derives_extract_prop; auto.
Qed.

Lemma derives_extract_prop' {A} {NA: NatDed A}:
  forall (P: Prop) (Q R: A), (P -> Q |-- R) ->  Q && !!P|-- R.
Proof.
intros. rewrite andp_comm. apply derives_extract_prop; auto.
Qed.

Lemma andp_assoc' {A}{NA: NatDed A}:
  forall P Q R : A, Q && (P && R) = P && (Q && R).
Proof. intros. rewrite andp_comm. rewrite andp_assoc. f_equal. apply andp_comm. 
Qed.

Lemma corable_andp_sepcon2{A}{NA: NatDed A}{SA: SepLog A}{IA: Indir A}{CA: CorableIndir A}:
   forall P Q R : A, corable P ->  (Q && P) * R = P && (Q * R).
Proof.
intros. rewrite andp_comm. apply corable_andp_sepcon1. auto.
Qed.

Lemma corable_sepcon_andp1 {A}{NA: NatDed A}{SA: SepLog A}{IA: Indir A}{CA: CorableIndir A}:
   forall P Q R : A, corable P ->  Q  * (P && R) = P && (Q * R).
Proof.
intros. rewrite sepcon_comm. rewrite corable_andp_sepcon1; auto. rewrite sepcon_comm; auto.
Qed.

Lemma corable_sepcon_andp2 {A}{NA: NatDed A}{SA: SepLog A}{IA: Indir A}{CA: CorableIndir A}:
   forall P Q R : A, corable P ->  Q  * (R && P) = P && (Q * R).
Proof.
intros. rewrite sepcon_comm. rewrite andp_comm. rewrite corable_andp_sepcon1; auto. rewrite sepcon_comm; auto.
Qed.

Hint Resolve @corable_prop : norm.

(* The followings are not in auto-rewrite lib. *)

Lemma sepcon_left_corable: forall {A}{NA: NatDed A}{SA: SepLog A}{IA: Indir A}{CA: CorableIndir A} (P Q: A), corable P -> (P * Q = (P && Q) * TT).
Proof.
  intros.
  pattern P at 1.
  rewrite <- (andp_TT P).
  rewrite !corable_andp_sepcon1 by auto.
  rewrite sepcon_comm.
  reflexivity.
Qed.

Lemma andp_left_corable: forall {A}{NA: NatDed A}{SA: SepLog A}{ClA: ClassicalSep A}{IA: Indir A}{CA: CorableIndir A} (P Q: A), corable P -> P && Q = (P && emp) * Q.
Proof.
  intros.
  pattern P at 1.
  rewrite corable_andp_sepcon1 by auto.
  rewrite sepcon_comm, sepcon_emp.
  reflexivity.
Qed.

Lemma TT_sepcon_TT: forall {A}{NA: NatDed A}{SA: SepLog A}{ClA: ClassicalSep A}, TT * TT = TT.
Proof.
  intros.
  apply pred_ext.
  + apply prop_right; auto.
  + apply sepcon_TT.
Qed.

Lemma corable_sepcon_TT: forall {A}{NA: NatDed A}{SA: SepLog A}{ClA: ClassicalSep A}{IA: Indir A}{CA: CorableIndir A} (P : A), corable P -> P * TT = P.
Proof.
  intros.
  rewrite <- (andp_TT P).
  rewrite corable_andp_sepcon1 by auto.
  rewrite TT_sepcon_TT.
  reflexivity.
Qed.

Lemma derives_left_sepcon_right_corable: forall {A}{NA: NatDed A}{SA: SepLog A}{ClA: ClassicalSep A}{IA: Indir A}{CA: CorableIndir A} (P Q R: A), corable P -> (Q |-- P) -> Q * R |-- P.
Proof.
  intros.
  rewrite <- corable_sepcon_TT by auto.
  apply sepcon_derives; auto.
  apply TT_right.
Qed.

Lemma later_prop_andp_sepcon: forall {A: Type} {A}{NA: NatDed A}{SA: SepLog A}{ClA: ClassicalSep A}{IA: Indir A}{CA: CorableIndir A} (P: Prop) (Q R: A), 
((|> !! P) && Q) * R = (|> !! P) && (Q * R).
Proof.
  intros.
  apply corable_andp_sepcon1.
  apply corable_later.
  apply corable_prop.
Qed.

(* This hint doesn't work well, hence the extra clauses in normalize1 and normalize1_in *)
(*Hint Rewrite @corable_andp_sepcon1 @corable_andp_sepcon2
                    @corable_sepcon_andp1 @corable_sepcon_andp2 using solve [auto with normalize typeclass_instances].
*)

Ltac normalize1 := 
         match goal with
            | |- _ => contradiction
            | |- context [@andp ?A (@LiftNatDed ?T ?B ?C) ?D ?E ?F] =>
                      change (@andp A (@LiftNatDed T B C) D E F) with (D F && E F)
            | |- context [@later ?A  (@LiftNatDed ?T ?B ?C) (@LiftIndir ?X1 ?X2 ?X3 ?X4 ?X5) ?D ?F] =>
                   change (@later A  (@LiftNatDed T B C) (@LiftIndir X1 X2 X3 X4 X5) D F) 
                     with (@later B C X5 (D F))   
            | |- context [@sepcon ?A (@LiftNatDed ?B ?C ?D) 
                                                         (@LiftSepLog ?E ?F ?G ?H) ?J ?K ?L] =>
                   change (@sepcon A (@LiftNatDed B C D) (@LiftSepLog E F G H) J K L)
                      with (@sepcon C D H (J L) (K L))
            | |- context [(?P && ?Q) * ?R] => rewrite (corable_andp_sepcon1 P Q R) by (auto with norm)
            | |- context [?Q * (?P && ?R)] => rewrite (corable_sepcon_andp1 P Q R) by (auto with norm)
            | |- context [(?Q && ?P) * ?R] => rewrite (corable_andp_sepcon2 P Q R) by (auto with norm)
            | |- context [?Q * (?R && ?P)] => rewrite (corable_sepcon_andp2 P Q R) by (auto with norm)
            (* In the next four rules, doing it this way (instead of leaving it to autorewrite)
                preserves the name of the "y" variable *)
            | |- context [andp (exp (fun y => _)) _] => 
                autorewrite with norm; apply imp_extract_exp_left; intro y
            | |- context [andp _ (exp (fun y => _))] => 
                autorewrite with norm; apply imp_extract_exp_left; intro y
            | |- context [sepcon (exp (fun y => _)) _] => 
               autorewrite with norm; apply imp_extract_exp_left; intro y
            | |- context [sepcon _ (exp (fun y => _))] => 
                autorewrite with norm; apply imp_extract_exp_left; intro y
 
           | |-  derives ?A   _ => match A with 
                          | context [ ((!! ?P) && ?Q) && ?R ] => rewrite (andp_assoc (!!P) Q R)
                          | context [ ?Q && (!! ?P && ?R)] =>
                                         match Q with !! _ => fail 2 | _ => rewrite (andp_assoc' (!!P) Q R) end
                         end
            | |- _ => progress  (autorewrite with norm); auto with typeclass_instances
            | |- _ = ?x -> _ => intro; subst x
            | |- ?x = _ -> _ => intro; subst x
            |  |- ?ZZ -> _ => match type of ZZ with 
                                               | Prop => 
                                                    let H := fresh in
                                                       ((assert (H:ZZ) by auto; clear H; intros _) || intro H)
                                               | _ => intros _
                                              end             
            | |- forall _, _ => let x := fresh "x" in (intro x; normalize1; try generalize dependent x)
            | |- exp _ |-- _ => apply imp_extract_exp_left 
            | |- !! _ |-- _ => apply derives_extract_prop0
            | |- !! _ && _ |-- _ => apply derives_extract_prop
            | |- _ && !! _ |-- _ => apply derives_extract_prop'
            | |- _ |-- !! (?x = ?y) && _ => 
                            (rewrite prop_true_andp with (P:= (x=y))
                                            by (unfold y; reflexivity); unfold y in *; clear y) ||
                            (rewrite prop_true_andp with (P:=(x=y))
                                            by (unfold x; reflexivity); unfold x in *; clear x)
            | |- TT |-- !! _ => apply TT_prop_right
            | |- _ => solve [auto with typeclass_instances]
            end.

Ltac normalize1_in Hx := 
             match type of Hx with
                 | context [@andp ?A (@LiftNatDed ?T ?B ?C) ?D ?E ?F] =>
                         change (@andp A (@LiftNatDed T B C) D E F) with (D F && E F)
                 | context [@later ?A  (@LiftNatDed ?T ?B ?C) (@LiftIndir ?X1 ?X2 ?X3 ?X4 ?X5) ?D ?F] =>
                    change (@later A  (@LiftNatDed T B C) (@LiftIndir X1 X2 X3 X4 X5) D F) 
                     with (@later B C X5 (D F))   
                 | context [@sepcon ?A (@LiftNatDed ?B ?C ?D) 
                                                         (@LiftSepLog ?E ?F ?G ?H) ?J ?K ?L] =>
                   change (@sepcon A (@LiftNatDed B C D) (@LiftSepLog E F G H) J K L)
                      with (@sepcon C D H (J L) (K L))
                | context [ !! ?P ] =>      
                                    rewrite (true_eq P) in Hx by auto with typeclass_instances
                | context [ !! ?P && ?Q ] =>  
                                    rewrite (prop_true_andp P Q) in Hx by auto with typeclass_instances  
                | context [(?P && ?Q) * ?R] => rewrite (corable_andp_sepcon1 P Q R) in Hx by (auto with norm)
                | context [?Q * (?P && ?R)] => rewrite (corable_sepcon_andp1 P Q R) in Hx by (auto with norm)
                | context [(?Q && ?P) * ?R] => rewrite (corable_andp_sepcon2 P Q R) in Hx by (auto with norm)
                | context [?Q * (?R && ?P)] => rewrite (corable_sepcon_andp2 P Q R) in Hx by (auto with norm)
                | _ => progress  (autorewrite with norm in Hx); auto with typeclass_instances
                end.

Ltac normalize := repeat (auto with norm; normalize1).

Tactic Notation "normalize" "in" hyp(H) := repeat (normalize1_in H).

Definition mark {A: Type} (i: nat) (j: A) := j.

Lemma swap_mark1 {A} {NA: NatDed A}{SA: SepLog A}:
  forall i j (Pi Pj B : A), (i<j)%nat -> B * mark i Pi * mark j Pj = B * mark j Pj * mark i Pi.
Proof.
intros.
repeat rewrite sepcon_assoc.
f_equal.
apply sepcon_comm.
Qed.

Lemma swap_mark0 {A} {NA: NatDed A}{SA: SepLog A}:
  forall i j (Pi Pj: A),  (i<j)%nat -> mark i Pi * mark j Pj = mark j Pj * mark i Pi.
Proof.
intros.
apply sepcon_comm.
Qed.

Ltac select_left n :=
  repeat match goal with 
 | |- context [(_ * mark ?i _ * mark n _)] => 
      rewrite (swap_mark1 i n); [ | solve [simpl; auto]]
 | |- context [(mark ?i _ * mark n _)] => 
      rewrite (swap_mark0 i n); [ | solve [simpl; auto]]
end.
Ltac select_all n := match n with 
                                | O => idtac 
                                | S ?n' => select_left n; select_all n' 
                              end.
Ltac markem n P := 
   match P with 
   | (?Y * ?Z) => 
        (match goal with H: mark _ Z = Z |- _ => idtac end 
        || assert (mark n Z = Z) by auto); markem (S n) Y
   | ?Z =>  match goal with H: mark _ Z = Z |- _ => idtac end 
                || assert (mark n Z = Z) by auto
  end.

Ltac prove_assoc_commut := 
 clear;
 try (match goal with |- ?F _ -> ?G _ => replace G with F; auto end);
  (repeat rewrite <- sepcon_assoc; 
   match goal with |- ?P = _ => markem O P end; 
   let LEFT := fresh "LEFT" in match goal with |- ?P = _ => set (LEFT := P) end;
  match goal with H: mark ?n _ = _ |- _ =>
     repeat  match goal with H: mark ?n _ = ?P |- _ => rewrite <- H; clear H end;
     select_all n;
     reflexivity
   end).

Lemma test_prove_assoc_commut {T}{NA: NatDed T}{SA: SepLog T} : forall A B C D E : T,
   D * E * A * C * B = A * B * C * D * E.
Proof.
intros.
prove_assoc_commut.
Qed.

(***** subtyping and contractiveness -- should split this into a separate file ******)
Require Import msl.alg_seplog.

Lemma later_fash1 {A} {NA: NatDed A}{IA: Indir A}{RA: RecIndir A}:
   forall P : A, |> # P |-- # |> P.
Proof. intros. rewrite later_fash; auto.
Qed.

Lemma subp_later1 {A}  {NA: NatDed A}{IA: Indir A}{RA: RecIndir A} : forall P Q : A,
   |>(P >=> Q)  |--   |>P >=> |>Q.
Proof.
intros.
rewrite later_fash. rewrite later_imp. auto.
Qed.

Lemma subp_later {A}  {NA: NatDed A}{IA: Indir A}{RA: RecIndir A} : forall P Q : A,
   |>(P >=> Q) = |>P >=> |>Q.
Proof.
intros.
rewrite later_fash. rewrite later_imp. auto.
Qed.

Lemma eqp_later1 {A} {NA: NatDed A}{IA: Indir A}{RA: RecIndir A} : forall P Q : A,
   |>(P <=> Q)  |--   |>P <=> |>Q.
Proof.
intros.
rewrite later_fash.
rewrite later_andp; repeat rewrite later_imp; repeat  rewrite fash_andp. auto.
Qed.

Lemma eqp_later {A}  {NA: NatDed A}{IA: Indir A}{RA: RecIndir A}  : forall P Q: A,
    (|>(P <=> Q) = |>P <=> |>Q).
Proof.
intros.
rewrite later_fash.
rewrite later_andp; repeat rewrite later_imp; repeat  rewrite fash_andp. auto.
Qed.

Lemma subp_refl {A} {NA: NatDed A}{IA: Indir A}{RA: RecIndir A}  : forall G (P : A),
  G |-- P >=> P.
Proof.
intros.
rewrite <- (fash_triv G).
apply @derives_trans with (#TT).
apply fash_TT.
apply fash_derives.
apply imp_andp_adjoint.
apply andp_left2; auto.
Qed.

Lemma subp_trans {A} {NA: NatDed A}{IA: Indir A}{RA: RecIndir A}  : forall G (P Q R: A),
  G |-- P >=> Q ->
  G |-- Q >=> R ->
  G |-- P >=> R.
Proof.
intros.
  apply @derives_trans with ((P >=> Q) && (Q >=> R)).
 apply andp_right; auto.
  clear.
 rewrite <- fash_andp. apply fash_derives.
 apply -> imp_andp_adjoint.
 rewrite andp_comm. rewrite <- andp_assoc.
 eapply derives_trans; [ apply andp_derives | ].
 apply modus_ponens. apply derives_refl. apply modus_ponens.
Qed.

Lemma subp_top {A} {NA: NatDed A}{IA: Indir A}{RA: RecIndir A}  : forall G (P: A),
  G |-- P >=> TT.
Proof.
 intros. apply @derives_trans with (#TT).
 apply fash_TT.
 apply fash_derives. apply imp_andp_adjoint.
 apply andp_left1; auto.
Qed.

Lemma subp_bot {A} {NA: NatDed A}{IA: Indir A}{RA: RecIndir A}  : forall G (P: A),
  G |-- FF >=> P.
Proof.
 intros. apply @derives_trans with (#TT).
 apply fash_TT.
 apply fash_derives. apply imp_andp_adjoint.
 apply andp_left2; apply FF_left.
Qed.

Lemma subp_andp {A} {NA: NatDed A}{IA: Indir A}{RA: RecIndir A}  : forall G {P P' Q Q': A},
  G |-- P >=> P' ->
  G |-- Q >=> Q' ->
  G |-- P && Q >=> (P' && Q').
Proof.
 intros.
 apply @derives_trans with ((P >=> P') && (Q >=> Q')).
 apply andp_right; auto.
 clear.
 rewrite <- fash_andp. apply fash_derives.
 apply -> imp_andp_adjoint.
 apply @derives_trans with ((P && (P --> P')) && (Q && (Q --> Q'))).
 repeat apply andp_right.
 apply andp_left2. apply andp_left1; auto.
 do 2 apply andp_left1; auto.
 repeat apply andp_left2; auto.
 apply andp_left1; apply andp_left2; auto.
 apply andp_derives; apply modus_ponens.
Qed.

Lemma subp_imp {A} {NA: NatDed A}{IA: Indir A}{RA: RecIndir A}  : forall G (P P' Q Q' : A),
  G |-- P' >=> P ->
  G |-- Q >=> Q' ->
  G |-- (P --> Q) >=> (P' --> Q').
Proof.
 intros.
 apply @derives_trans with ((P' >=> P) && (Q >=> Q')).
 apply andp_right; auto.
 clear.
 rewrite <- fash_andp. apply fash_derives.
 apply -> imp_andp_adjoint.
 apply -> imp_andp_adjoint.
 apply @derives_trans with (((P' && (P' --> P)) && (P --> Q)) && (Q --> Q')).
 repeat apply andp_right.
 apply andp_left2.  auto.
 do 3 apply andp_left1; auto.
 apply andp_left1. repeat apply andp_left2; auto.
 apply andp_left1; apply andp_left1. apply andp_left2;  auto.
 eapply derives_trans ; [eapply andp_derives | ].
 eapply derives_trans ; [eapply andp_derives | ].
 apply modus_ponens. apply derives_refl.
 apply modus_ponens. apply derives_refl.
 apply modus_ponens.
Qed.

Lemma subp_orp {A} {NA: NatDed A}{IA: Indir A}{RA: RecIndir A}  : forall G (P P' Q Q' : A),
  G |-- P >=> P' ->
  G |-- Q >=> Q' ->
  G |-- (P || Q) >=> (P' || Q').
Proof.
 intros.
 eapply derives_trans; [ apply andp_right; [apply H | apply H0] | ].
 clear.
 rewrite <- fash_andp. apply fash_derives.
 apply -> imp_andp_adjoint.
rewrite andp_comm. apply imp_andp_adjoint.
apply orp_left; apply -> imp_andp_adjoint; [apply orp_right1 | apply orp_right2].
 rewrite <- andp_assoc. apply andp_left1. apply modus_ponens.
 rewrite (andp_comm (_ --> _)).
 rewrite <- andp_assoc. apply andp_left1. apply modus_ponens.
Qed.

Lemma subp_subp {A} {NA: NatDed A}{IA: Indir A}{RA: RecIndir A}:
  forall G (P Q R S: A), 
   G |-- (R >=> P) ->
   G |-- (Q >=> S) ->
   G |-- (P >=> Q) >=> (R >=> S).
Proof.
 intros.
 intros.
 eapply derives_trans; [ apply andp_right; [apply H | apply H0] | ].
 clear.
 rewrite fash_triv.
 apply -> (@imp_andp_adjoint Triv).
 rewrite andp_assoc.
 apply @derives_trans with ((R >=> P) && (P >=> S)).
 apply andp_derives; auto.
 apply subp_trans with Q. apply andp_left2; auto. apply andp_left1; auto.
  apply subp_trans with P. apply andp_left1; auto. apply andp_left2; auto.
Qed.

Lemma allp_imp2_later_e2 {B}{A}{NA: NatDed A}{IA: Indir A}{RA: RecIndir A}:
   forall (P Q: B -> A) (y: B) ,
      (ALL x:B, |> P x <=> |> Q x) |-- |> Q y >=> |> P y.
Proof. 
  intros. apply allp_left with y. repeat rewrite fash_andp. apply andp_left2; auto.
Qed.

Lemma allp_imp2_later_e1 {B}{A}{NA: NatDed A}{IA: Indir A}{RA: RecIndir A}:
   forall (P Q: B -> A) (y: B) ,
      (ALL x:B, |> P x <=> |> Q x) |-- |> P y >=> |> Q y.
Proof. 
  intros. apply allp_left with y. repeat rewrite fash_andp. apply andp_left1; auto.
Qed.

Lemma prove_HOcontractive1 {A} {NA: NatDed A}{IA: Indir A}{RA: RecIndir A} : forall X F,
  (forall P Q: X -> A,
    (ALL x:X, |>(P x >=> Q x) |--
        ALL x:X, F P x >=> F Q x)) ->
   HOcontractive F.
Proof.
  unfold HOcontractive.
  intros.
  apply allp_right; intro v.
  rewrite fash_andp.
  apply andp_right.
  specialize (H P Q).
  eapply derives_trans; [ | eapply derives_trans ; [ apply H |] ].
  apply allp_derives; intro x.
  apply @later_derives. apply fash_derives. apply andp_left1. auto.
  apply allp_left with v; auto.
  specialize (H Q P).
  eapply derives_trans; [ | eapply derives_trans ; [ apply H |] ].
  apply allp_derives; intro x.
  apply later_derives. apply fash_derives. apply andp_left2. auto.
  apply allp_left with v; auto.
Qed.

Lemma prove_HOcontractive {A} {NA: NatDed A}{IA: Indir A}{RA: RecIndir A} : forall X F,
  (forall (P Q: X -> A) (x: X),
    (ALL x:X, (|> P x <=> |> Q x) |-- F P x >=> F Q x)) ->
   HOcontractive F.
Proof.
  intros.
  unfold HOcontractive.
  intros.
  apply allp_right; intro v.
  rewrite fash_andp.
  apply andp_right.
  eapply derives_trans; [ | apply H].
  apply allp_derives; intro x.
  rewrite eqp_later. auto.
  eapply derives_trans; [ | apply H].
  apply allp_derives; intro x.
  rewrite eqp_later. rewrite andp_comm. auto.
Qed.

Lemma sub_sepcon' {A}{NA: NatDed A}{SL: SepLog A}{IA: Indir A}{RA: RecIndir A}{SRA: SepRec A}:
  forall P P' Q Q': A, (P >=> P') && (Q >=> Q') |-- (P * Q) >=> (P' * Q').
Proof.
intros.
apply subp_i1.
rewrite unfash_sepcon_distrib.
apply sepcon_derives.
apply derives_trans with ((P --> P') && P).
apply andp_derives; auto.
eapply derives_trans; [ | apply unfash_fash ].
apply unfash_derives. apply andp_left1; auto.
rewrite andp_comm; apply modus_ponens.
apply derives_trans with ((Q --> Q') && Q).
apply andp_derives; auto.
eapply derives_trans; [ | apply unfash_fash ].
apply unfash_derives. apply andp_left2; auto.
rewrite andp_comm; apply modus_ponens.
Qed.


Lemma subp_sepcon {A} {NA: NatDed A}{IA: Indir A}{SA: SepLog A}{SI: SepIndir A}{RA: RecIndir A}{SRA: SepRec A} :
    forall G (P P' Q Q' : A),
  G |-- P >=> P' ->
  G |-- Q >=> Q' ->
  G |-- P * Q >=> P' * Q'.
Proof.
 intros.
 eapply derives_trans; [ | apply sub_sepcon'].
 apply andp_right; auto.
Qed.

Ltac sub_unfold := 
   match goal with 
    | |- _ |-- ?A _ >=> ?A _ => unfold A 
    | |- _ |-- ?A _ _ >=> ?A _ _ => unfold A 
    | |- _ |-- ?A _ _ _ >=> ?A _ _ _ => unfold A 
    | |- _ |-- ?A _ _ _ _ >=> ?A _ _ _ _ => unfold A 
    | |- _ |-- ?A _ _ _ _ _ >=> ?A _ _ _ _ _ => unfold A 
    | v: _ |- _ => destruct v
   end.

Hint Extern 2 (_ |-- _ >=> _) => sub_unfold : contractive.

Hint Resolve @prove_HOcontractive 
  @subp_allp @subp_imp @subp_refl @subp_exp @subp_andp @subp_orp @subp_subp 
  @subp_sepcon (* NOTE: This hint fails to work unless fully instantiated, for some reason;
                             so the client must re-do the subp_sepcon hint *)
  @allp_imp2_later_e1 @allp_imp2_later_e2 : contractive.

Lemma  goedel_loeb {A}  {NA: NatDed A}{IA: Indir A}: 
    forall P Q : A ,   Q && later P |-- P ->  Q |-- P.
Proof.
intros.
assert (TT |-- Q --> P).
apply loeb.
rewrite later_imp.
apply imp_andp_adjoint.
eapply derives_trans; [ | apply H].
apply andp_right.
apply andp_left2; auto.
rewrite andp_comm.
apply derives_trans with (|> Q && (|> Q --> |> P)).
apply andp_derives; auto.
apply now_later.
apply modus_ponens.
apply derives_trans with (Q && (Q --> P)).
apply andp_right; auto.
apply derives_trans with TT; auto.
apply TT_right.
apply modus_ponens.
Qed.

(*Lemma Rec_sub {A} {NA: NatDed A}{IA: Indir A}{RA: RecIndir A} : forall G
  (F   : A -> A -> A)
  (HF1 : forall X, contractive (F X))
  (HF2 : forall R P Q, P >=> Q |-- F P R >=> F Q R)
  (HF3 : forall P Q X, |>(P >=> Q) |-- F X P >=> F X Q),
  forall P Q,
    G |-- P >=> Q ->
    G |-- Rec (F P) >=> Rec (F Q).
*)

Lemma HORec_sub {A}  {NA: NatDed A}{IA: Indir A}{RA: RecIndir A} : forall G B
  (F : A -> (B -> A) -> B -> A)
  (HF1 : forall X, HOcontractive (F X))
  (HF2 : forall R a (P Q: A), P >=> Q |-- F P R a >=> F Q R a)
  (HF3 : forall (P Q: B -> A) X, ALL b:B, |>(P b >=> Q b) |-- ALL b:B, F X P b >=> F X Q b),
  forall P Q : A,
    G |-- P >=> Q ->
    G |-- ALL b:B, HORec (F P) b >=> HORec (F Q) b.
Proof.
  intros.
  apply @derives_trans with (P>=>Q); auto.
  clear G H.
  apply goedel_loeb.
  apply allp_right; intro b.
  rewrite HORec_fold_unfold by auto.
  pose proof (HORec_fold_unfold _ _ (HF1 P)). 
  pose proof (HORec_fold_unfold _ _ (HF1 Q)). 
  set (P' := HORec (F P)) in *.
  set (Q' := HORec (F Q)) in *.
  rewrite <- H.
  specialize (HF3 P' Q' P).
  rewrite later_allp.
 eapply derives_trans; [apply andp_derives ; [apply derives_refl | apply HF3] | ].
  specialize (HF2 Q' b P Q). rewrite <- H0 in HF2.
 rewrite <- H in *.
  apply subp_trans with  (F P Q' b).
  apply andp_left2.  apply allp_left with b; auto.
  apply andp_left1; auto.
Qed.


(****** End contractiveness *****)

