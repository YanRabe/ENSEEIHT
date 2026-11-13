(* Module de la passe de génération de code *)
(* doit être conforme à l'interface Passe *)
open Tds
open Ast
open Type
open Code
open Tam

type t1 = Ast.AstPlacement.programme
type t2 = string


let rec get_type_affectable a =
  match a with
  | AstType.Ident info ->
      (match info_ast_to_info info with
       | InfoVar(_, t, _, _) -> t
       | InfoConst _ -> Int
       | _ -> failwith "Erreur interne: get_type_affectable")
  | AstType.Deref a_sub ->
      match get_type_affectable a_sub with
      | Pointer t -> t
      | _ -> failwith "Erreur interne: deref d'un non pointeur"

let rec analyse_code_affectable_value a =
  match a with
  | AstType.Ident(info_ast) ->
      begin match info_ast_to_info info_ast with
      | InfoVar(_, t, dep, reg) ->
          let taille = getTaille t in
          "LOAD (" ^ (string_of_int taille) ^ ") " ^ (string_of_int dep) ^ "[" ^ reg ^ "]\n"
      | InfoConst(_, v) ->
          "LOADL " ^ (string_of_int v) ^ "\n"
      | _ -> failwith "Erreur interne: Ident non variable/constante"
      end
  | AstType.Deref(a_sub) ->
      let code_ptr = analyse_code_affectable_value a_sub in (* Charge l'adresse *)
      let t = get_type_affectable a in (* Type pointé *)
      let taille = getTaille t in
      code_ptr ^ "LOADI (" ^ (string_of_int taille) ^ ")\n"


(* analyse_code_expression : AstPlacement.expression -> string *)
let rec analyse_code_expression e =
  match e with
  | AstType.AppelFonction(info_ast, args) ->
      let code_args = String.concat "" (List.map analyse_code_expression args) in
      let nom = match info_ast_to_info info_ast with
        | InfoFun(n, _, _) -> n
        | _ -> failwith "Erreur interne"
      in
      code_args ^ "CALL (ST) " ^ nom ^ "\n"
      
  | AstType.Affectable a ->
      analyse_code_affectable_value a
      
  | AstType.Booleen(b) ->
      if b then "LOADL 1\n" else "LOADL 0\n"
      
  | AstType.Entier(i) ->
      "LOADL " ^ (string_of_int i) ^ "\n"
      
  | AstType.Unaire(u, e) ->
      let code_e = analyse_code_expression e in
      begin match u with
      | Numerateur -> code_e ^ "POP (0) 1\n"
      | Denominateur -> code_e ^ "POP (1) 1\n"
      end
      
  | AstType.Binaire(b, e1, e2) ->
      let code_e1 = analyse_code_expression e1 in
      let code_e2 = analyse_code_expression e2 in
      begin match b with
      | Fraction -> code_e1 ^ code_e2 ^ "CALL (ST) norm\n"
      | PlusInt -> code_e1 ^ code_e2 ^ "SUBR IAdd\n"
      | PlusRat -> code_e1 ^ code_e2 ^ "CALL (ST) RAdd\n"
      | MultInt -> code_e1 ^ code_e2 ^ "SUBR IMul\n"
      | MultRat -> code_e1 ^ code_e2 ^ "CALL (ST) RMul\n"
      | EquInt -> code_e1 ^ code_e2 ^ "SUBR IEq\n"
      | EquBool -> code_e1 ^ code_e2 ^ "SUBR IEq\n"
      | Inf -> code_e1 ^ code_e2 ^ "SUBR ILss\n"
      end

  | AstType.Null -> "LOADL 0\n"
  
  | AstType.New t -> 
      let taille = getTaille t in
      "LOADL " ^ (string_of_int taille) ^ "\nSUBR MAlloc\n"
      
  | AstType.Adresse info ->
      begin match info_ast_to_info info with
      | InfoVar(_, _, dep, reg) ->
          "LOADA " ^ (string_of_int dep) ^ "[" ^ reg ^ "]\n"
      | _ -> failwith "Erreur interne: Adresse d'autre chose qu'une variable"
      end
(* analyse_code_instruction : AstPlacement.instruction -> string *)
let rec analyse_code_instruction i =
  match i with
  | AstPlacement.Declaration(info_ast, e) ->
      analyse_code_expression e
      
  | AstPlacement.Affectation(a, e) ->
      let code_e = analyse_code_expression e in
      begin match a with
      | AstType.Ident info_ast ->
          (* Cas classique : x = e *)
          begin match info_ast_to_info info_ast with
          | InfoVar(_, t, dep, reg) ->
              let taille = getTaille t in
              code_e ^ "STORE (" ^ (string_of_int taille) ^ ") " ^ (string_of_int dep) ^ "[" ^ reg ^ "]\n"
          | _ -> failwith "Erreur interne: Affectation sur non-variable code"
          end
  | AstType.Deref a_sub ->
    (* Cas pointeur : *p = e *)
    (* On empile la valeur de e, puis l'adresse contenue dans p, puis STOREI *)
    let code_addr = analyse_code_affectable_value a_sub in 
    let t = get_type_affectable (AstType.Deref a_sub) in
    let taille = getTaille t in
    code_e ^ code_addr ^ "STOREI (" ^ (string_of_int taille) ^ ")\n"
  end
      
  | AstPlacement.AffichageInt(e) ->
      let code_e = analyse_code_expression e in
      code_e ^ "SUBR IOut\n"
      
  | AstPlacement.AffichageRat(e) ->
      let code_e = analyse_code_expression e in
      code_e ^ "CALL (ST) ROut\n"
      
  | AstPlacement.AffichageBool(e) ->
      let code_e = analyse_code_expression e in
      code_e ^ "SUBR BOut\n"
      
 | AstPlacement.Conditionnelle(e, (bt, taille_t), (be, taille_e)) ->
    let code_e = analyse_code_expression e in
    let code_bt = analyse_code_bloc_sans_pop bt in
    let code_be = analyse_code_bloc_sans_pop be in 
    let pop_t = if taille_t > 0 then "POP (0) " ^ (string_of_int taille_t) ^ "\n" else "" in
    let pop_e = if taille_e > 0 then "POP (0) " ^ (string_of_int taille_e) ^ "\n" else "" in
    let sinon = getEtiquette() in
    let fin = getEtiquette() in
    code_e ^
    "JUMPIF (0) " ^ sinon ^ "\n" ^
    code_bt ^ pop_t ^
    "JUMP " ^ fin ^ "\n" ^
    sinon ^ "\n" ^
    code_be ^ pop_e ^
    fin ^ "\n"
      
  | AstPlacement.TantQue(e, (b, taille_b)) ->
    let code_e = analyse_code_expression e in
    let code_b = analyse_code_bloc_sans_pop b in
    let pop_b = if taille_b > 0 then "POP (0) " ^ (string_of_int taille_b) ^ "\n" else "" in
    let debut = getEtiquette() in
    let fin = getEtiquette() in
    debut ^ "\n" ^
    code_e ^
    "JUMPIF (0) " ^ fin ^ "\n" ^
    code_b ^ pop_b ^
    "JUMP " ^ debut ^ "\n" ^
    fin ^ "\n"

  | AstPlacement.Retour(e, taille_ret, taille_params) ->
      let code_e = analyse_code_expression e in
      code_e ^
      "RETURN (" ^ (string_of_int taille_ret) ^ ") " ^ (string_of_int taille_params) ^ "\n"
      
  | AstPlacement.Empty -> ""

  | AstPlacement.AppelProcedure(info_ast, args) ->
      let code_args = String.concat "" (List.map analyse_code_expression args) in
      let nom = match info_ast_to_info info_ast with
        | InfoFun(n, _, _) -> n
        | _ -> failwith "Erreur interne"
      in
      code_args ^ "CALL (ST) " ^ nom ^ "\n"

  | AstPlacement.RetourVoid(_, taille_ret, taille_params) ->
      "RETURN (" ^ (string_of_int taille_ret) ^ ") " ^ (string_of_int taille_params) ^ "\n"


and analyse_code_bloc instructions taille_bloc =
  let code_instructions = String.concat "" (List.map analyse_code_instruction instructions) in
  code_instructions ^
  (if taille_bloc > 0 then "POP (0) " ^ (string_of_int taille_bloc) ^ "\n" else "")

(* Version sans POP final pour les structures de contrôle *)
and analyse_code_bloc_sans_pop instructions =
  String.concat "" (List.map analyse_code_instruction instructions)

(* analyse_code_fonction : AstPlacement.fonction -> string *)
let analyse_code_fonction (AstPlacement.Fonction(info_ast, params, (bloc, taille_bloc))) =
  let nom = match info_ast_to_info info_ast with
    | InfoFun(n, _, _) -> n
    | _ -> failwith "Erreur interne"
  in
  let code_bloc = analyse_code_bloc bloc taille_bloc in
  nom ^ "\n" ^ code_bloc ^ "HALT\n"

(* analyser : AstPlacement.programme -> string *)
let analyser (AstPlacement.Programme(fonctions, (prog, taille_prog))) =
  let code_fonctions = String.concat "\n" (List.map analyse_code_fonction fonctions) in
  let code_prog = analyse_code_bloc prog taille_prog in
  getEntete() ^
  code_fonctions ^ "\n" ^
  "main\n" ^
  code_prog ^
  "HALT\n"