Require Import floyd.proofauto.
Import ListNotations.
Require sha.sha.
Require sha.SHA256.
Local Open Scope logic.

Require Import sha.spec_sha.
Require Import sha_lemmas.

Require Import sha.hmac091c.
Require Import sha.vst_lemmas.
Require Import sha.hmac_pure_lemmas.
Require Import sha.hmac_common_lemmas.
Require Import sha.spec_hmac.

Lemma body_hmac_update: semax_body HmacVarSpecs HmacFunSpecs 
       f_HMAC_Update HMAC_Update_spec.
Proof.
start_function.
name ctx' _ctx.
name data' _data.
name len' _len.
unfold hmacstate_. normalize. intros ST. normalize.
destruct H as [DL1 [DL2 DL3]].
destruct h1; simpl in *.
destruct H0 as [reprMD [reprI [reprO [iShaLen [oShaLen [KeyST [l [KeylenST [KL ZLen]]]]]]]]].
rewrite KL in *. revert POSTCONDITION; subst keylen; intros.

unfold_data_at 1%nat.
rewrite field_at_data_at with (gfs:=[StructField _md_ctx]).
assert_PROP (field_compatible t_struct_hmac_ctx_st [StructField _md_ctx] c).
  { entailer!. } 
rename H into FC.
make_Vptr c. 

forward_call' (ctx, data, Vptr b i, d, Tsh, len, kv) s.
  { unfold sha256state_, field_address; normalize.
    rewrite if_true by eauto. apply (exp_right (mdCtx ST)). entailer!. }
  { intuition. }
rename H into HmacUpdate.
normalize. simpl. 
assert (FF: firstn (Z.to_nat len) data = data). 
    rewrite DL1 in *. 
    apply firstn_same. rewrite Zlength_correct, Nat2Z.id. omega.
rewrite FF in *. 

forward.
apply (exp_right (HMACabs s iSha oSha (Int.unsigned l) key)). entailer.
apply andp_right. apply prop_right. exists s; eauto.
unfold hmacstate_, sha256state_, hmac_relate. normalize.
apply (exp_right (r, (iCtx ST, (oCtx ST, (Vint l, Key ST))))). 
simpl. entailer!.
(*apply andp_right. apply prop_right.*) exists l; eauto.

unfold_data_at 2%nat.
destruct ST as [ST1 [ST2 [ST3 [ST4 ST5]]]]. simpl in *. subst ST4. cancel.
rewrite field_at_data_at. 
unfold nested_field_type2, field_address; simpl.
rewrite if_true by eauto. entailer!.
Qed.