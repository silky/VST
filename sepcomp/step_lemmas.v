Require Import AST.
Require Import Coqlib.
Require Import Globalenvs.

Require Import extspec.
Require Import core_semantics.
Require Import core_semantics_lemmas.

Section safety.
  Context {F V C M Z:Type}.
  Context {Hrel: nat -> M -> M -> Prop}.
  Context (Hcore:CoreSemantics (Genv.t F V) C M).
  Variable (Hspec:external_specification M external_function Z).

  Variable ge : Genv.t F V.

  Inductive safeN_ : nat -> Z -> C -> M -> Prop :=
  | safeN_0: forall z c m, safeN_ O z c m
  | safeN_step:
      forall n z c m c' m',
      corestep Hcore ge c m c' m' ->
      safeN_ n z c' m' -> 
      safeN_ (S n) z c m
  | safeN_external:
      forall n z c m e sig args x,
      at_external Hcore c = Some (e,sig,args) ->
      ext_spec_pre Hspec e x (Genv.genv_symb ge) (sig_args sig) args z m ->
      (forall ret m' z' n',
         (n' <= n)%nat -> 
         Hrel n' m m' -> 
         ext_spec_post Hspec e x (Genv.genv_symb ge) (sig_res sig) ret z' m' ->
         exists c',
           after_external Hcore ret c = Some c' /\
           safeN_ n' z' c' m') -> 
      safeN_ (S n) z c m
  | safeN_halted:
      forall n z c m i,
      halted Hcore c = Some i -> 
      ext_spec_exit Hspec (Some i) z m ->
      safeN_ n z c m.

  Definition corestep_fun  :=
       forall ge m q m1 q1 m2 q2 ,
       corestep Hcore ge q m q1 m1 -> 
       corestep Hcore ge q m q2 m2 -> 
       (q1, m1) = (q2, m2).

  Lemma safe_corestep_forward:
     corestep_fun -> 
    forall c m c' m' n z,
    corestep Hcore ge c m c' m' -> safeN_ (S n) z c m -> safeN_ n z c' m'.
  Proof.
    simpl; intros; inv H1.
    assert ((c',m') = (c'0,m'0)) by (eapply H; eauto).
    inv H1; auto.
    erewrite corestep_not_at_external in H3; eauto; congruence.
    erewrite corestep_not_halted in H2; eauto; congruence.
  Qed.

  Lemma safe_corestep_backward:
    forall c m c' m' n z,
    corestep Hcore ge c m c' m' -> safeN_ n z c' m' -> safeN_ (S n) z c m.
  Proof.
    intros; eapply safeN_step; eauto.
  Qed.

  Lemma safe_downward1 :
    forall n c m z,
      safeN_ (S n) z c m -> safeN_ n z c m.
  Proof.
    induction n. econstructor; eauto.
    intros c m z H. inv H.
    + econstructor; eauto. 
    + eapply safeN_external; eauto. 
    + eapply safeN_halted; eauto.
  Qed.

  Lemma safe_downward : 
    forall n n' c m z,
      le n' n ->
      safeN_ n z c m -> safeN_ n' z c m.
  Proof.
    do 6 intro. revert c m z. induction H; auto.
    intros. apply IHle. apply safe_downward1. auto.
  Qed.

  Lemma safe_corestepN_forward:
    corestep_fun -> 
    forall z c m c' m' n n0,
      corestepN Hcore ge n0 c m c' m' -> 
      safeN_ (n + S n0) z c m -> 
      safeN_ n z c' m'.
  Proof.
    intros.
    revert c m c' m' n H0 H1.
    induction n0; intros; auto.
    simpl in H0; inv H0.
    eapply safe_downward in H1; eauto. omega.
    simpl in H0. destruct H0 as [c2 [m2 [STEP STEPN]]].
    apply (IHn0 _ _ _ _ n STEPN). 
    assert (Heq: (n + S (S n0) = S (n + S n0))%nat) by omega.
    rewrite Heq in H1.
    eapply safe_corestep_forward in H1; eauto.
  Qed.

  Lemma safe_step'_back2 :
    forall
      {ora st m st' m' n},
      corestep Hcore ge st m st' m' ->
      safeN_ (n-1) ora st' m' ->
      safeN_ n ora st m.
  Proof.
    intros.
    destruct n.
    constructor.
    simpl in H0. replace (n-0)%nat with n in H0.
    eapply safe_corestep_backward; eauto. 
    omega.
  Qed.

  Lemma safe_corestepN_backward:
    forall z c m c' m' n n0,
      corestepN Hcore ge n0 c m c' m' -> 
      safeN_ (n - n0) z c' m' -> 
      safeN_ n z c m.
  Proof.
    simpl; intros.
    revert c m c' m' n H H0.
    induction n0; intros; auto.
    simpl in H; inv H.
    solve[assert (Heq: (n = n - 0)%nat) by omega; rewrite Heq; auto].
    simpl in H. destruct H as [c2 [m2 [STEP STEPN]]].
    assert (H: safeN_ (n - 1 - n0) z c' m'). 
    eapply safe_downward in H0; eauto. omega.
    specialize (IHn0 _ _ _ _ (n - 1)%nat STEPN H). 
    solve[eapply safe_step'_back2; eauto].
  Qed.
    
  Lemma convergent_controls_safe : 
    forall m q1 q2,
      (at_external Hcore q1 = at_external Hcore q2) ->
      (forall ret q', after_external Hcore ret q1 = Some q' ->
                      after_external Hcore ret q2 = Some q') ->
      (halted Hcore q1 = halted Hcore q2) ->
      (forall q' m', corestep Hcore ge q1 m q' m' -> 
                     corestep Hcore ge q2 m q' m') ->
      (forall n z, safeN_ n z q1 m -> safeN_ n z q2 m).
  Proof.
    intros. destruct n; simpl in *; try constructor.
    inv H3. 
    + econstructor; eauto.
    + eapply safeN_external; eauto.
      rewrite <-H; auto.
      intros ????? H8 H9.
      specialize (H7 _ _ _ _ H3 H8 H9).
      destruct H7 as [c' [? ?]].
      exists c'; split; auto.
    + eapply safeN_halted; eauto.
      rewrite <-H1; auto.
  Qed.

  Lemma wlog_safeN_gt0 : forall
    n z q m,
    (lt 0 n -> safeN_ n z q m) -> 
    safeN_ n z q m.
  Proof.
    intros. destruct n. constructor.
    apply H. omega.
  Qed.

End safety.

Section dry_safety.
  Context {F V C M Z:Type}.
  Context (Hcore:CoreSemantics (Genv.t F V) C M).
  Variable (Hspec:external_specification M external_function Z).
  Definition dry_safeN := @safeN_ F V C M Z (fun n' m m' => True) Hcore Hspec.
End dry_safety.
