Require Import floyd.proofauto.
Import ListNotations.
Require sha.sha.
Require Import sha.SHA256.
Local Open Scope logic.

Require Import sha.spec_sha.
Require Import sha_lemmas.
Require Import sha.HMAC_functional_prog.
Require Import sha.HMAC256_functional_prog.
Require Import sha.spec_hmacADT.
Require Import vst_lemmas.
Require Import hmac_pure_lemmas.
Require Import hmac_common_lemmas.

Require Import sha.hmac_NK.

Require Import sha.verif_hmacADT_init_part1_5.
Require Import sha.verif_hmacADT_init_part1.
Require Import sha.verif_hmacADT_init_part2.

Lemma body_hmac_init: semax_body HmacVarSpecs HmacFunSpecs 
       f_HMAC_Init HMAC_Init_spec.
Proof.
start_function.
name ctx' _ctx.
name key' _key.
name len' _len.
simpl_stackframe_of. fixup_local_var; intro pad. fixup_local_var; intro ctxkey. 
 
forward.
 
assert_PROP (isptr ctxkey). { entailer!. }
apply isptrD in H; destruct H as [ckb [ckoff X]]; subst ctxkey.
(*destruct H as [KL1 [KL2 KL3]].*) normalize.

(*unfold data_block. normalize. *)

(*isolate branch if (key != NULL) *)
apply seq_assoc.
(*
Definition initPostKeyNullConditional l r (c:val) (k: val) h key ctxkey: mpred:=
  match k with
    Vint z => if Int.eq z Int.zero
              then if zeq r Z0 
                   then (hmacstate_PreInitNull key h c) * (data_at_ Tsh (tarray tuchar 64) ctxkey)
                   else FF
              else FF
  | Vptr b ofs => if zeq r 0 then FF 
                  else EX ll:_, EX CONT:_,
                      !!(Forall isbyteZ key /\ has_lengthK ll key /\ l = Vint(Int.repr ll)) &&
                    ((data_at Tsh t_struct_hmac_ctx_st CONT c) *
                     (data_at Tsh (tarray tuchar 64) (map Vint (map Int.repr (HMAC_SHA256.mkKey key)))
                      ctxkey) *
                     (data_at Tsh (tarray tuchar (Zlength key)) (map Vint (map Int.repr key))
                      (Vptr b ofs)))
  | _ => FF
  end. *)
remember (EX  cb : block,
                 (EX  cofs : int,
                   (EX  r : Z, 
                    PROP  (c = Vptr cb cofs /\ (r=0 \/ r=1))
                    LOCAL  (temp _reset (Vint (Int.repr r));
                      lvar _ctx_key (tarray tuchar 64) (Vptr ckb ckoff); 
                      lvar _pad (tarray tuchar 64) pad;
                      temp _ctx c; temp _key k; temp _len l;
                      gvar sha._K256 kv)
                    SEP  (`(data_at_ Tsh (tarray tuchar 64) pad);
                    `(initPostKeyNullConditional l r c k h1 key (Vptr ckb ckoff));
                    `(K_vector kv))))) as PostKeyNull. 
forward_seq. instantiate (1:= PostKeyNull). (*eapply semax_seq.*)
{ (*semax_subcommand HmacVarSpecs HmacFunSpecs f_HMAC_Init. 
   fold initPre.
   assert (DD: Delta= initialized _reset Delta) by reflexivity.
   rewrite DD.*)
   eapply hmac_init_part1; eassumption. 
}
subst PostKeyNull. normalize.
apply extract_exists_pre; intros cb. 
apply extract_exists_pre; intros cofs. 
apply extract_exists_pre; intros r.
normalize. unfold POSTCONDITION, abbreviate. subst c.
rename H0 into R.

(*isolate branch if (reset) *)
apply seq_assoc. 
(*Definition initPostResetConditional l r (c:val) (k: val) h key ctxS iS oS: mpred:=
  match k with
    Vint z => if Int.eq z Int.zero
              then if zeq r Z0 then hmacstate_PreInitNull key h c else FF
              else FF
  | Vptr b ofs => if zeq r 0 then FF
                  else EX ll:_, !!(Forall isbyteZ key/\ has_lengthK ll key /\ l = Vint(Int.repr ll)) &&
                       ((data_at Tsh t_struct_hmac_ctx_st (postResetHMS ctxS iS oS) c) *
                        (data_at Tsh (tarray tuchar (Zlength key)) (map Vint (map Int.repr key)) (Vptr b ofs)))
  | _ => FF
  end.
*)
remember (EX iSA:_, EX iS:_, EX oSA:_, EX oS:_, EX CONT:_,
          PROP  (innerShaInit (map Byte.repr (HMAC_SHA256.mkKey key)) iSA /\ s256_relate iSA iS /\
                 outerShaInit (map Byte.repr (HMAC_SHA256.mkKey key)) oSA /\ s256_relate oSA oS)
                 LOCAL  (
                  lvar _pad (tarray tuchar 64) pad; 
                  lvar _ctx_key (tarray tuchar 64) (Vptr ckb ckoff); 
                  temp _ctx (Vptr cb cofs); temp _key k;
                  temp _len l;
                  gvar sha._K256 kv)
                 SEP  (`(data_at_ Tsh (tarray tuchar 64) pad);
                  `(data_at_ Tsh (Tarray tuchar 64 noattr) (Vptr ckb ckoff));                 
                  `(initPostResetConditional l r (Vptr cb cofs) k h1 key CONT iS oS); `(K_vector kv)))
  as PostResetBranch.
(*forward_seq. instantiate (1:= PostResetBranch).*)
eapply semax_seq. instantiate (1:=PostResetBranch).
 { (* semax_subcommand HmacVarSpecs HmacFunSpecs f_HMAC_Init.*)
   eapply init_part2; eassumption. }
{ (*Continuation after if (reset*)
  subst PostResetBranch.
  simpl update_tycon.
  apply semax_extensionality_Delta with (Delta). apply expr_lemmas.tycontext_sub_refl.
  apply extract_exists_pre; intros iSA. 
  apply extract_exists_pre; intros iS. 
  apply extract_exists_pre; intros oSA. 
  apply extract_exists_pre; intros oS. unfold initPostResetConditional.
  apply extract_exists_pre; intros CONT. 
  normalize. 
  rename H into INNER. rename H0 into InnerRelate.
  rename H1 into OUTER. rename H2 into OuterRelate.
  unfold initPostResetConditional.
  destruct k;
    try solve [apply semax_pre with (P':=FF); try entailer!; try apply semax_ff].
  { (*k is integer, ie key==null*)
     destruct (Int.eq i Int.zero). 
     Focus 2. apply semax_pre with (P':=FF); try entailer; try apply semax_ff.
     destruct R; subst r; simpl.
     Focus 2. apply semax_pre with (P':=FF); try entailer; try apply semax_ff.
     unfold hmacstate_PreInitNull; simpl. normalize.
     intros s. normalize. intros v. normalize. rename H into Hs.
     unfold hmac_relate_PreInitNull in Hs. 
     clear INNER InnerRelate OUTER OuterRelate iSA iS oSA oS.
     destruct h1.
     destruct Hs as [IREL [OREL [ILEN [OLEN [ISHA OSHA]]]]].
     destruct s as [mdS [iS oS]]. simpl in *.
     unfold_data_at 1%nat.

     rewrite (field_at_data_at Tsh t_struct_hmac_ctx_st [StructField _md_ctx]).
     simpl.
     assert_PROP (field_compatible t_struct_hmac_ctx_st [StructField _md_ctx] (Vptr cb cofs)).
         entailer!.
     rename H into FC.
     unfold field_address; rewrite if_true by auto.   
     rewrite (field_at_data_at Tsh t_struct_hmac_ctx_st [StructField _i_ctx]).
     assert_PROP (field_compatible t_struct_hmac_ctx_st [StructField _i_ctx] (Vptr cb cofs)).
         entailer!.
     rename H into FCI.
     unfold field_address; rewrite if_true by auto.  
     simpl. 
     replace_SEP 2 (`(memory_block Tsh (Int.repr 108) (Vptr cb cofs))).
     { entailer!. } (* NOTE: using entailer here leaves a subgoal that can be proven like this:
      unfold nested_field_type2; simpl.
      eapply data_at_memory_block; simpl; try reflexivity.
      rewrite int_max_unsigned_eq; omega. }
    rewrite (field_at_data_at Tsh t_struct_hmac_ctx_st [StructField _i_ctx]).
*)
     forward_call' ((Tsh, Tsh),
             Vptr cb cofs,
             offset_val
              (Int.repr (nested_field_offset2 t_struct_hmac_ctx_st [StructField _i_ctx]))
              (Vptr cb cofs),
             mkTrep t_struct_SHA256state_st iS) rv.
     subst rv. simpl.

     forward. (*return*)
     unfold hmacInit. 
     remember (Int.unsigned (Int.repr (if zlt 64 (Zlength key) then 32 else Zlength key)))as KL.
     apply (exp_right (HMACabs iSha iSha oSha)).   
     entailer!.
     exists iSha, oSha. auto. 
     simpl_stackframe_of. unfold tarray.
     cancel.
     unfold hmacstate_, hmac_relate.
      normalize.
      apply (exp_right (iS, (iS, oS))).
      simpl. entailer!. cancel.

      unfold_data_at 3%nat. 
      unfold tarray in *. rewrite (lvar_eval_lvar _ _ _ _ H0). 
      rewrite (lvar_eval_lvar _ _ _ _ H1). cancel.
      rewrite (field_at_data_at Tsh t_struct_hmac_ctx_st [StructField _i_ctx]).
      rewrite (field_at_data_at Tsh t_struct_hmac_ctx_st [StructField _md_ctx]).
        unfold field_address; repeat rewrite if_true by auto.
        change (nested_field_offset2 t_struct_hmac_ctx_st [StructField _md_ctx])
           with 0.
        change (nested_field_offset2 t_struct_hmac_ctx_st [StructField _i_ctx])
           with 108.
        normalize.
  }

  { (*k is Vptr, key!=NULL*)
    destruct R; subst r; simpl. 
    apply semax_pre with (P':=FF); try entailer; try apply semax_ff.
    normalize. intros ll; normalize. subst l. rename ll into l. 
    rename H into isbyteKey. rename H0 into KL. 
    unfold postResetHMS. simpl. unfold_data_at 1%nat.
    rewrite (field_at_data_at Tsh t_struct_hmac_ctx_st [StructField _md_ctx]).
    simpl.
    assert_PROP (field_compatible t_struct_hmac_ctx_st [StructField _md_ctx] (Vptr cb cofs)).
         entailer!.
    rename H into FC.

    rename b into kb; rename i into kofs.
    replace_SEP 2
      (`(memory_block Tsh (Int.repr (sizeof (nested_field_type2 t_struct_hmac_ctx_st [StructField _md_ctx])))
           (field_address t_struct_hmac_ctx_st [StructField _md_ctx] (Vptr cb cofs)))).
    { entailer. unfold field_address. rewrite if_true by auto.
      unfold nested_field_type2; simpl.
      eapply data_at_memory_block; simpl; try reflexivity.
      rewrite int_max_unsigned_eq; omega. }
    rewrite (field_at_data_at Tsh t_struct_hmac_ctx_st [StructField _i_ctx]).

    (*Call to _memcpy*)
    forward_call' ((Tsh, Tsh),
             Vptr cb cofs,
             field_address t_struct_hmac_ctx_st [StructField _i_ctx]  (Vptr cb cofs),
             mkTrep t_struct_SHA256state_st iS) rv.
    { entailer!; unfold field_address; rewrite if_true by auto; reflexivity. }
    { simpl. unfold field_address. rewrite if_true by auto. entailer!.
      (*Again, entailer leaves a subgoal*) }
    subst rv; simpl. 

    forward. (*return*)
    apply (exp_right (HMACabs iSA iSA oSA)). 
    entailer!.
    { unfold hmacInit. exists iSA, oSA. auto. }
    { unfold data_block. simpl_stackframe_of. entailer!. cancel.
      unfold hmacstate_, hmac_relate.
      normalize.
      apply (exp_right (iS, (iS, oS))).
      simpl. entailer!.
      { rewrite (updAbs_len _ _ _ INNER), Zlength_mkArgZ,
           map_length, mkKey_length; reflexivity. }
      { rewrite (updAbs_len _ _ _ OUTER), Zlength_mkArgZ,
           map_length, mkKey_length; reflexivity. }

      { unfold tarray in *.
        rewrite (lvar_eval_lvar _ _ _ _ H0).         
        rewrite (lvar_eval_lvar _ _ _ _ H1).
        unfold_data_at 3%nat. cancel.
        rewrite (field_at_data_at Tsh t_struct_hmac_ctx_st [StructField _i_ctx]).
        rewrite (field_at_data_at Tsh t_struct_hmac_ctx_st [StructField _md_ctx]).
        cancel.
        unfold field_address; rewrite if_true by auto.
        change (nested_field_offset2 t_struct_hmac_ctx_st [StructField _md_ctx])
           with 0.
        normalize. 
      }
    }
  }
} 
Qed.