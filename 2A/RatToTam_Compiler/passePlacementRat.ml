(* Module de la passe de gestion des identifiants *)
(* doit être conforme à l'interface Passe *)
open Tds
open Exceptions
open Ast
open Type

type t1 = Ast.AstType.programme
type t2 = Ast.AstPlacement.programme


let print_info_ast ia =
  match info_ast_to_info ia with
  | InfoVar(n, t, d, r) ->
      Printf.printf "VAR %s : type=%s offset=%d reg=%s\n"
        n (string_of_type t) d r
  | InfoFun(n, _, _) ->
      Printf.printf "FUN %s\n" n
  | _ -> ()



(* analyse_instruction :  base (int de la ou on en est)-> reg ("sb" ou "lb") -> AstPlacement.instruction *)

(* analyse_placement_instruction : retourne (instruction transformée, nouvelle_base, taille_max) *)
let rec analyse_placement_instruction base reg i =
  match i with
  | AstType.Declaration (info_ast, expr) ->
      let t = match info_ast_to_info info_ast with
      | InfoVar(_,t,_,_) -> t
      | _ -> failwith "placement_instruction : declaration"
      in
      let taille = getTaille t in
      modifier_adresse_variable base reg info_ast;
      (AstPlacement.Declaration (info_ast, expr), base + taille, base + taille)
      
  | AstType.Affectation (a, expr) ->
      (AstPlacement.Affectation (a, expr), base, base)
      
  | AstType.AffichageInt e ->
      (AstPlacement.AffichageInt e, base, base)
      
  | AstType.AffichageRat e ->
      (AstPlacement.AffichageRat e, base, base)
      
  | AstType.AffichageBool e ->
      (AstPlacement.AffichageBool e, base, base)
      
  | AstType.Conditionnelle (e, b1, b2) ->
      let (nb1, taille1) = analyse_placement_bloc base reg b1 in
      let (nb2,  taille2) = analyse_placement_bloc base reg b2 in
      let taille_max = max taille1 taille2 in
      (AstPlacement.Conditionnelle (e, nb1, nb2), base, taille_max)
      
  | AstType.TantQue (e, b) ->
      let (nb, taille_bloc) = analyse_placement_bloc base reg b in
      (AstPlacement.TantQue (e, nb), base, taille_bloc)
      
  | AstType.Retour(exp, info_fun) ->
      let (taille_ret, taille_params) =
        match info_ast_to_info info_fun with
        | InfoFun(_, t_ret, t_params) ->
            ( getTaille t_ret,
              List.fold_left (fun acc t -> acc + getTaille t) 0 t_params )
        | _ -> failwith "Erreur interne : retour hors fonction"
      in
      ( AstPlacement.Retour(exp, taille_ret, taille_params), base, base )
      
  | AstType.Empty ->
      (AstPlacement.Empty, base, base)
      
  | AstType.AppelProcedure(info_ast, params) -> 
      (AstPlacement.AppelProcedure(info_ast, params), base, base)

  | AstType.RetourVoid(info_fun) ->
      let (taille_ret, taille_params) =
        match info_ast_to_info info_fun with
        | InfoFun(_, t_ret, t_params) ->
            ( getTaille t_ret,
              List.fold_left (fun acc t -> acc + getTaille t) 0 t_params )
        | _ -> failwith "Erreur interne : retour void hors fonction"
      in
      (AstPlacement.RetourVoid(info_fun, taille_ret, taille_params), base, base)


(* analyse_placement_bloc : retourne ((bloc transformé, taille du bloc), taille_max atteinte) *)
and analyse_placement_bloc base reg instructions =
  let rec aux base_courante taille_max acc = function
    | [] -> (List.rev acc, taille_max, base_courante)
    | i :: q ->
        let (ni, nouvelle_base, taille_instr) = analyse_placement_instruction base_courante reg i in
        let nouvelle_taille_max = max taille_max taille_instr in
        aux nouvelle_base nouvelle_taille_max (ni :: acc) q
  in
  let (instrs, taille_max, derniere_base) = aux base base [] instructions in
  let taille_bloc = derniere_base - base in
  ((instrs, taille_bloc), taille_max)




(* analyse_placement_fonction : tds -> AstSyntax.fonction -> AstTds.fonction *)


let analyse_placement_fonction (AstType.Fonction(info_fun, params, bloc)) =
  let reg = "LB" in  
  let taille_params =
    List.fold_left
      (fun acc ia ->
        match info_ast_to_info ia with
        | InfoVar(_, t, _, _) -> acc + getTaille t
        | _ -> acc)
      0
      params
  in

  let _ =
    List.fold_left
      (fun offset ia ->
        match info_ast_to_info ia with
        | InfoVar(_, t, _, _) ->
            let taille = getTaille t in 
            modifier_adresse_variable offset reg ia;
            offset + taille
        | _ -> offset)
      (-taille_params)
      params
  in
  let (nbloc, _) = analyse_placement_bloc 3 reg bloc in

  AstPlacement.Fonction(info_fun, params, nbloc)

let analyser (AstType.Programme(fonctions, bloc)) =
  let nf = List.map analyse_placement_fonction fonctions in
  let (nb, _) = analyse_placement_bloc 0 "SB" bloc in
  AstPlacement.Programme(nf, nb)

