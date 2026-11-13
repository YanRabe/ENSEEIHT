(* Module de la passe de gestion du type *)
(* doit être conforme à l'interface Passe *)
open Tds
open Exceptions
open Ast
open Type

type t1 = Ast.AstTds.programme
type t2 = Ast.AstType.programme

exception PasDeReturn


let est_compatible t1 t2 =
  match t1, t2 with
  | Pointer _, Pointer Undefined -> true
  | Pointer Undefined, Pointer _ -> true
  | _ -> Type.est_compatible t1 t2


let get_type_info info =
  match info_ast_to_info info with
  | InfoVar(_, t, _, _) -> t
  | InfoConst _ -> Int
  | InfoFun(_, t, _) -> t
  | _ -> failwith "Erreur interne"

let rec get_type_affectable a =
  match a with
  | AstType.Ident info -> get_type_info info
  | AstType.Deref a -> 
      match get_type_affectable a with
      | Pointer t -> t
      | t -> failwith "Erreur déreférencement d'un non pointeur"

(* Obtient le type d'une expression AstType *)
let rec get_type_expression e =
   match e with
    | AstType.AppelFonction(i,_) -> begin match info_ast_to_info i with
                                    |InfoFun(_,t,_) -> t
                                    |_ -> failwith "Erreur interne: AppelFonction doit avoir une InfoFun"
                                    end
    | AstType.Affectable a -> get_type_affectable a
    | AstType.Booleen(_) -> Bool
    | AstType.Entier(_) -> Int
    | AstType.Unaire(_,_) -> Int
    | AstType.Binaire(bi,_,_) -> begin match bi with
                                    |Ast.AstType.Fraction -> Rat
                                    |Ast.AstType.PlusInt -> Int
                                    | Ast.AstType.PlusRat -> Rat
                                    | Ast.AstType.MultInt -> Int
                                    | Ast.AstType.MultRat -> Rat
                                    | Ast.AstType.EquInt -> Bool
                                    | Ast.AstType.EquBool -> Bool
                                    | Ast.AstType.Inf -> Bool
                                  end
    | AstType.Null -> Pointer Undefined 
    | AstType.New t -> Pointer t
    | AstType.Adresse info -> Pointer (get_type_info info)


let rec analyse_type_affectable a =
  match a with
  | AstTds.Ident(info) -> 
      let t = get_type_info info in
      (AstType.Ident info, t)
  | AstTds.Deref(aine) ->
      let (na, ta) = analyse_type_affectable aine in
      match ta with
      | Pointer t -> (AstType.Deref na, t)
      | _ -> raise (TypeInattendu(ta, Pointer Undefined))

(* Analyse de type d'une expression AstTds -> AstType *)
let rec analyse_type_expression exp =  
  match exp with
  | AstTds.AppelFonction(info_ast, exp_args_list) -> 
      begin match info_ast_to_info info_ast with
      | InfoFun(_, _, typ_args_list) -> 
          let exp_args_analysed = List.map analyse_type_expression exp_args_list in
          let typ_list = List.map get_type_expression exp_args_analysed in
          if est_compatible_list typ_list typ_args_list then
            AstType.AppelFonction(info_ast, exp_args_analysed)
          else 
            raise (TypesParametresInattendus (typ_list, typ_args_list))
      | _ -> failwith "Erreur interne: AppelFonction attend une InfoFun"
      end
  | AstTds.Booleen(b) -> AstType.Booleen(b)
  | AstTds.Affectable a ->
      let (na, _) = analyse_type_affectable a in
      AstType.Affectable na
  | AstTds.Entier(i) -> AstType.Entier(i)
  | AstTds.Unaire(u, e) ->  
      let e_typed = analyse_type_expression e in
      let t = get_type_expression e_typed in 
      begin match u with
      | AstSyntax.Numerateur -> 
          if est_compatible t Rat then 
            AstType.Unaire(AstType.Numerateur, e_typed)
          else
            raise (TypeInattendu(t, Rat))
      | AstSyntax.Denominateur ->
          if est_compatible t Rat then
            AstType.Unaire(AstType.Denominateur, e_typed)
          else
            raise (TypeInattendu(t, Rat))
      end
  | AstTds.Binaire(bi, e1, e2) -> 
      let e1_typed = analyse_type_expression e1 in
      let t1 = get_type_expression e1_typed in
      let e2_typed = analyse_type_expression e2 in
      let t2 = get_type_expression e2_typed in
      begin match bi with 
      | AstSyntax.Fraction ->
          if est_compatible t1 Int && est_compatible t2 Int then
            AstType.Binaire(AstType.Fraction, e1_typed, e2_typed)
          else
            raise (TypeBinaireInattendu(bi, t1, t2))
      | AstSyntax.Plus ->
          if est_compatible t1 Int && est_compatible t2 Int then
            AstType.Binaire(AstType.PlusInt, e1_typed, e2_typed)
          else if est_compatible t1 Rat && est_compatible t2 Rat then
            AstType.Binaire(AstType.PlusRat, e1_typed, e2_typed)
          else
            raise (TypeBinaireInattendu(bi, t1, t2))
      | AstSyntax.Mult ->
          if est_compatible t1 Int && est_compatible t2 Int then
            AstType.Binaire(AstType.MultInt, e1_typed, e2_typed)
          else if est_compatible t1 Rat && est_compatible t2 Rat then
            AstType.Binaire(AstType.MultRat, e1_typed, e2_typed)
          else
            raise (TypeBinaireInattendu(bi, t1, t2))
      | AstSyntax.Equ ->
          if est_compatible t1 Int && est_compatible t2 Int then
            AstType.Binaire(AstType.EquInt, e1_typed, e2_typed)
          else if est_compatible t1 Bool && est_compatible t2 Bool then
            AstType.Binaire(AstType.EquBool, e1_typed, e2_typed)
          else
            raise (TypeBinaireInattendu(bi, t1, t2))
      | AstSyntax.Inf ->
          if est_compatible t1 Int && est_compatible t2 Int then
            AstType.Binaire(AstType.Inf, e1_typed, e2_typed)
          else
            raise (TypeBinaireInattendu(bi, t1, t2))
      end
  | AstTds.Null -> AstType.Null
  | AstTds.New t -> AstType.New t
  | AstTds.Adresse info -> AstType.Adresse info

(*AstTds -> AstType*)
let rec analyse_unaire (AstTds.Unaire(u,e)) =
match u with
|AstSyntax.Numerateur _ -> AstType.Unaire(AstType.Numerateur, analyse_type_expression  e)
|AstSyntax.Denominateur _ -> AstType.Unaire(AstType.Denominateur, analyse_type_expression  e)

let rec analyse_type_instruction oia i = 
  match i with
  |AstTds.Declaration(t1, info_ast, exp) -> let exp_analysed = analyse_type_expression exp in
                                            let exp_typed = get_type_expression exp_analysed in
                                            if est_compatible t1 exp_typed then begin
                                              modifier_type_variable t1 info_ast;
                                              AstType.Declaration(info_ast, exp_analysed) end
                                            else
                                              raise (TypeInattendu (exp_typed, t1))
  |AstTds.Affectation(a, exp) -> let (na, ta) = analyse_type_affectable a in
                                        let exp_analysed = analyse_type_expression exp in
                                        let type_exp = get_type_expression exp_analysed in
                                        
                                        if est_compatible ta type_exp then 
                                          AstType.Affectation(na, exp_analysed)
                                        else 
                                          raise (TypeInattendu (type_exp, ta))
  |AstTds.Affichage(exp) -> let exp_analysed = analyse_type_expression exp in
                            let type_exp = get_type_expression exp_analysed in
                            begin match type_exp with
                            |Int -> AstType.AffichageInt (exp_analysed)
                            |Rat -> AstType.AffichageRat (exp_analysed)
                            |Bool -> AstType.AffichageBool (exp_analysed)
                            |_ -> raise (MauvaiseUtilisationIdentifiant "affichage d'un mauvais type")
                            end
  |AstTds.Conditionnelle(c,t,e) ->let nc = analyse_type_expression  c in
                                    let type_nc = get_type_expression nc in
                                    if est_compatible type_nc Bool then begin
                                    let tast = analyse_type_bloc  oia t in
                                    let east = analyse_type_bloc  oia e in
                                    AstType.Conditionnelle (nc, tast, east) end
                                    else
                                      raise (TypeInattendu(type_nc,Bool))
  | AstTds.TantQue (c,b) ->
      let nc = analyse_type_expression  c in
      let type_nc = get_type_expression nc in
      if est_compatible type_nc Bool then begin
      let bast = analyse_type_bloc  oia b in
      AstType.TantQue (nc, bast) end
      else
        raise (TypeInattendu(type_nc,Bool))
  | AstTds.Retour (e, info_ast) ->
      begin
      match oia with
      | None -> raise RetourDansMain
      | Some ia ->
        let ne = analyse_type_expression  e in
        AstType.Retour (ne,ia)
      end
  | AstTds.Empty -> 
    AstType.Empty
  | AstTds.AppelProcedure(info_ast, liste_exp) ->

      let (type_retour, types_params_attendus) = 
        match info_ast_to_info info_ast with
        | InfoFun(_, tr, tp) -> (tr, tp)
        | _ -> failwith "Erreur interne: AppelProcedure sur un identifiant qui n'est pas une fonction"
      in
      

      if type_retour <> Void then
        raise (TypeInattendu(type_retour, Void));


      let liste_exp_analysees = List.map analyse_type_expression liste_exp in
      let types_params_reels = List.map (fun e -> get_type_expression e) liste_exp_analysees in

      if not (est_compatible_list types_params_attendus types_params_reels) then
        raise (TypesParametresInattendus(types_params_attendus, types_params_reels));

      AstType.AppelProcedure(info_ast, liste_exp_analysees)


  | AstTds.RetourVoid(info_ast) ->
      let type_attendu = 
        match info_ast_to_info info_ast with
        | InfoFun(_, tr, _) -> tr
        | _ -> failwith "Erreur interne: RetourVoid hors fonction valide"
      in
      
      if type_attendu <> Void then
        raise (TypeInattendu(type_attendu, Void));
        
      AstType.RetourVoid(info_ast)
      
and analyse_type_bloc oia li =
  List.map (analyse_type_instruction oia) li

let analyse_type_fonction (AstTds.Fonction(t, info_ast, lp, li)) =
  List.iter (fun (typ_param, ia_param) ->
    modifier_type_variable typ_param ia_param
  ) lp;
  

  let bloc_analyse = analyse_type_bloc (Some info_ast) li in
  

  let type_retour_attendu = match info_ast_to_info info_ast with
    | InfoFun(_, t_ret, _) -> t_ret
    | _ -> failwith "Erreur interne: analyse_type_fonction attend une InfoFun"
  in
  

  let rec check_return instructions =
    match instructions with
    | [] -> ()
    | AstType.Retour(e, _) :: _ ->
        let t_ret = get_type_expression e in
        if est_compatible type_retour_attendu t_ret then
          ()
        else
          raise (TypeInattendu (t_ret, type_retour_attendu))
    | AstType.RetourVoid(_) :: _ -> (* AJOUT POUR LE RETURNVOID *)
        if type_retour_attendu = Void then ()
        else raise (TypeInattendu (Void, type_retour_attendu))

    | AstType.Conditionnelle(_, bloc_then, bloc_else) :: rest ->
        let has_then_return = try  check_return bloc_then; true with PasDeReturn -> false in
        let has_else_return = try check_return bloc_else; true with PasDeReturn -> false in
        if has_else_return && has_then_return then
          ()
        else check_return rest
    |AstType.TantQue(c, b) :: rest ->  
      let has_while_return = try  check_return b; true with PasDeReturn -> false in
   
      check_return rest
    | _ :: rest -> check_return rest
  in
  check_return bloc_analyse;
  
  modifier_type_fonction t (List.map fst lp) info_ast;
  
  AstType.Fonction(info_ast, List.map snd lp, bloc_analyse)

let analyser (AstTds.Programme (fonctions,prog)) =
  let nf = List.map (analyse_type_fonction) fonctions in
  let nb = analyse_type_bloc None prog in
  AstType.Programme (nf,nb)