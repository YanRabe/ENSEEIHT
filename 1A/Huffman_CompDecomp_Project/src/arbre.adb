with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Unchecked_Deallocation;
with Ada.Directories; use Ada.Directories;
with ARBRE;
with SDA_Exceptions;  use SDA_Exceptions;

package body Arbre is


   -- Procedure free pour les 5 structures de données différentes qui utilisent des pointeurs

   procedure Free is
      new Ada.Unchecked_Deallocation(Object => T_Noeud_Arbre, Name => T_ARBRE);


   procedure Free_TAB_AB is
      new Ada.Unchecked_Deallocation(Object => T_Cellule_Arbre, Name => T_ptr_arbre);


   procedure Free_TAB_SYMBOLE is 
      new Ada.Unchecked_Deallocation(Object => T_Tab_symbole, Name => T_ptr_symbole);


   procedure Free_TAB_INFIXE is
      new Ada.Unchecked_Deallocation(Object => T_Parcour_Infixe, Name => T_ptr_infixe);


   procedure Free_TAB_HUFFMAN is 
      new Ada.Unchecked_Deallocation(Object => T_Cellule_Huffman, Name => T_ptr_Huffman);


   -- === Corps des sous-programmes de la spécification pour le type T_ARBRE ===


   procedure AB_Initialiser(Arbre: out T_ARBRE) is
   begin
      Arbre := Null;
   end AB_Initialiser;


   procedure AB_Detruire(Arbre: in out T_ARBRE) is
   begin
      if Arbre /= Null then
         AB_Detruire(Arbre.all.Fils_Gauche);
         AB_Detruire(Arbre.all.Fils_Droit);
         Free(Arbre);
      else
         Free(Arbre);
      end if;
   end AB_Detruire;


   function AB_Est_Vide(Arbre: in T_ARBRE) return Boolean is
   begin
      return (Arbre = Null);
   end AB_Est_Vide;


   function AB_Est_Feuille(Arbre: in T_ARBRE) return Boolean is
   begin
      return (Arbre.all.Fils_Gauche = Null and Arbre.all.Fils_Droit = Null);
   end AB_Est_Feuille;


   -- ma proposition pour assigner


   procedure AB_Creer_Noeud(Noeud: out T_ARBRE; Cle: in T_Cle; Valeur: in T_Valeur; Fils_Gauche : in T_ARBRE; Fils_Droit : in T_ARBRE) is
   begin
      Noeud := new T_Noeud_Arbre;
      Noeud.all.Cle := Cle;
      Noeud.all.Valeur := Valeur;
      Noeud.all.Fils_Gauche := Fils_Gauche;
      Noeud.all.Fils_Droit := Fils_Droit;
   end AB_Creer_Noeud;


   procedure AB_Assigner_Cle(Noeud: in out T_ARBRE; Cle: in T_Cle) is
   begin
      Noeud.all.Cle := Cle;
   end AB_Assigner_Cle;


   procedure AB_Assigner_Valeur(Noeud: in out T_ARBRE; Valeur: in T_Valeur) is
   begin
      Noeud.all.Valeur := Valeur;
   end AB_Assigner_Valeur;

   
   function AB_Profondeur(Arbre: in T_ARBRE) return Integer is
   begin
      if AB_Est_Vide(Arbre) then
         return 0;
      elsif AB_Est_Feuille(Arbre) then
         return 1;
      else
         if AB_Profondeur(Arbre.all.Fils_Gauche) > AB_Profondeur(Arbre.all.Fils_Droit) then
            return 1 + AB_Profondeur(Arbre.all.Fils_Gauche);
         else
            return 1 + AB_Profondeur(Arbre.all.Fils_Droit);
         end if;
      end if;
   end AB_Profondeur;


   procedure Assigner(Noeud: in T_Arbre ; Noeud_copie : out T_Arbre) is
   begin 
      Noeud_copie:= Noeud;
   end;


   function AB_egaux(Arbre1 : in T_ARBRE; Arbre2: in T_ARBRE) return Boolean is
   begin
      if AB_Est_Vide(Arbre1) or AB_Est_Vide(Arbre2) then
         if AB_Est_Vide(Arbre1) and AB_Est_Vide(Arbre2) then
            return True;
         else
            return False;
         end if;
      else
         if Arbre1.all.Cle=Arbre2.all.Cle and Arbre1.all.Valeur=Arbre2.all.Valeur then
            if AB_Est_Feuille(Arbre1) and AB_Est_Feuille(Arbre2) then
               return True;
            elsif AB_egaux(Arbre1.Fils_Gauche, Arbre2.Fils_Gauche) and AB_egaux(Arbre2.Fils_Droit, Arbre2.Fils_Droit)then
               return True;
            end if;
         end if;
      end if;
      return False;
   end AB_egaux;


   function AB_La_Valeur(Noeud: in T_ARBRE) return T_Valeur is
   begin
      return Noeud.all.Valeur;
   end AB_La_Valeur;


   function AB_La_Cle(Noeud: in T_ARBRE) return T_Cle is
   begin
      return Noeud.all.Cle;
   end AB_La_Cle;


   function AB_Fils_Gauche(Noeud: in T_ARBRE) return T_ARBRE is
   begin
      if Noeud.all.Fils_Gauche = Null then
         Noeud.all.Fils_Gauche := new T_Noeud_Arbre;
      end if;
      return Noeud.all.Fils_Gauche;
   end AB_Fils_Gauche;


   function AB_Fils_Droit(Noeud: in T_ARBRE) return T_ARBRE is
   begin
      if Noeud.all.Fils_Droit = Null then
         Noeud.all.Fils_Droit := new T_Noeud_Arbre;
      end if;
      return Noeud.all.Fils_Droit;
   end AB_Fils_Droit;


   procedure AB_Afficher_Debug(Arbre: in T_ARBRE) is
   Taille : constant Integer := AB_Profondeur(Arbre);
   type T_Tab is array(1..Taille) of Integer;
   Tableau : T_Tab;
   niveau : Constant Integer := 0;
      procedure Afficher(Arbre: in T_ARBRE; niveau: in Integer; Tab : in out T_Tab) is
      begin
         if AB_Est_Vide(Arbre) then
            Null;
         else
            if not AB_Est_Feuille(Arbre) then
               Afficher_Donnee(AB_La_Valeur(Arbre)); 
            else
               Afficher_Donnee(AB_La_Valeur(Arbre)); 
               Afficher_Cle(AB_La_Cle(Arbre));
            end if;
            if not AB_Est_Feuille(Arbre) then
               New_Line;
               if niveau /= 0 then
                  for i in 1..niveau loop
                     if Tab(i) = 0 then
                        Put("|     ");
                     elsif Tab(i) = 1 then
                        Put("      ");
                     end if;
                  end loop;
               end if;
               Put("\--0--");
            end if;
            Tab(niveau+1) := 0;
            Afficher(Arbre.all.Fils_Gauche, niveau + 1,Tab);
            if not AB_Est_Feuille(Arbre) then
               New_Line;
               if niveau /= 0 then
                  for i in 1..niveau loop
                     if Tab(i) = 0 then
                        Put("|     ");
                     elsif Tab(i) = 1 then
                        Put("      ");
                     end if;
                  end loop;
               end if;
               Put("\--1--");
            end if;
            Tab(niveau+1) := 1;
            Afficher(Arbre.all.Fils_Droit, niveau + 1,Tab);
         end if;
      end Afficher;
   begin
      for i in 1..Taille loop
         Tableau(i) := 2;
      end loop;
      Afficher(Arbre, niveau, Tableau);
   end AB_Afficher_Debug;


   --Générer l'arbre de Huffman à partir du parcours infixe
   procedure Generer_Arbre_Parcours(Tab_symbole : in T_LCA; Tab_Entree : in T_ptr_Tab_Octet; 
   Arbre, Arbre_vide : in out T_ARBRE; Indice_Symboles, Indice_Bit, Indice_Parcours_Entree, Indice_Symboles_Max : in out Integer;
   Cle_Default : in T_Cle; Valeur_Default: in T_Valeur) is
      Bit : T_Octet;
      Octet : T_Octet := Tab_Entree.all(File_Size(Indice_Parcours_Entree));
   begin
      --Récupérer le bit de poids fort
      Bit := Octet / 128;
      --Décaler l'octet de 1 bit vers la gauche
      Tab_Entree.all(File_Size(Indice_Parcours_Entree)) := Octet*2;
      --Générer l'arbre à partir du parcours infixe
      if Indice_Symboles <= Indice_Symboles_Max then
         --Avancer vers le prochain octet si on a parcouru tous les bits de l'octet actuel
         if Indice_Bit = 8 then
               Indice_Bit := 1;
               Indice_Parcours_Entree := Indice_Parcours_Entree + 1;
            else
               Indice_Bit := Indice_Bit + 1;
            end if;
         --Créer une feuille si on a un bit à 1
         if Bit = 1 then
            AB_Assigner_Cle(Arbre, LCA_S.Cle_indice(Tab_symbole, Indice_Symboles));
            AB_Assigner_Valeur(Arbre, LCA_S.La_Valeur(Tab_symbole, LCA_S.Cle_indice(Tab_symbole, Indice_Symboles)));
            Indice_Symboles := Indice_Symboles + 1;
         --Génerer le sous-arbre gauche puis le sous-arbre droit à partir du parcours infixe
         else
            AB_Creer_Noeud(Arbre.all.Fils_Gauche, Cle_Default, Valeur_Default, Arbre_vide, Arbre_vide);
            AB_Creer_Noeud(Arbre.all.Fils_Droit, Cle_Default, Valeur_Default, Arbre_vide, Arbre_vide);
            Generer_Arbre_Parcours(Tab_symbole, Tab_Entree, Arbre.all.Fils_Gauche, 
            Arbre_vide, Indice_Symboles, Indice_Bit, Indice_Parcours_Entree, Indice_Symboles_Max,
            Cle_Default, Valeur_Default);
            Generer_Arbre_Parcours(Tab_symbole, Tab_Entree, Arbre.all.Fils_Droit, 
            Arbre_vide, Indice_Symboles, Indice_Bit, Indice_Parcours_Entree, Indice_Symboles_Max,
            Cle_Default, Valeur_Default);
         end if;
      end if;
   end Generer_Arbre_Parcours;


   --Décoder un symbole compressé à partir de l'arbre de Huffman
   procedure Decoder_Symbole_Compresse(Arbre: in T_ARBRE; Tab_Entree : in T_ptr_Tab_Octet; Indice_Bit, Indice_Parcours_Entree : in out Integer;
   String: in out T_Cle; Octet_du_String: in out T_Valeur)
   is
      Bit : T_Octet;
      Octet : T_Octet := Tab_Entree.all(File_Size(Indice_Parcours_Entree));

   begin
      --  New_Line;
      --  Put_Line("Octet actuel avant changement : ");
      --  Put(Integer(Octet), Base => 2);
      --  New_Line;
      if AB_Est_Feuille(Arbre) then
         String := AB_La_Cle(Arbre);
         Octet_du_String := AB_La_Valeur(Arbre);
      else
         Bit := Octet / 128;
         Tab_Entree.all(File_Size(Indice_Parcours_Entree)) := Octet*2;
         if Indice_Bit = 8 then
            Indice_Bit := 1;
            Indice_Parcours_Entree := Indice_Parcours_Entree + 1;
         else
            Indice_Bit := Indice_Bit + 1;
         end if;
         if Bit = 1 then
            Decoder_Symbole_Compresse(Arbre.all.Fils_Droit, Tab_Entree, Indice_Bit, Indice_Parcours_Entree, String, Octet_du_String);
         else
            Decoder_Symbole_Compresse(Arbre.all.Fils_Gauche, Tab_Entree, Indice_Bit, Indice_Parcours_Entree, String, Octet_du_String);
         end if;
      end if;
   end Decoder_Symbole_Compresse;


   -- Corps des sous-programmes de la spécification pour le type T_ptr_Arbre


   function Est_vide_tab_arbre(Tab : in T_ptr_arbre) return Boolean is
   begin
      return(Tab = null);
   end Est_vide_tab_arbre;

      --  procedure Initialiser_tab_arbre(Tab : in out T_ptr_arbre) is
      --  begin
      --     Tab := null;
      --  end Initialiser_tab_arbre;


   function Taille_Table_Arbre(Tab : in T_ptr_arbre) return Integer is
   Cursor : T_ptr_arbre := Tab;
   Taille : Integer := 0;
   begin
      while Cursor/=null loop
         Taille := Taille + 1;
         Cursor := Cursor.all.Suivante;
      end loop;
      return Taille;
   end Taille_Table_Arbre;


   function Arbre_Present(Tab : T_ptr_arbre; Arbre : T_ARBRE) return Boolean is
   Cursor : T_ptr_arbre := Tab;
   begin 
      while Cursor/=null loop
         if AB_egaux(Cursor.Arbre,Arbre) then
            return True;
         end if;
         Cursor := Cursor.all.Suivante;
      end loop;
      return False;
   end Arbre_Present;


   function Arbre_indice(Table_arbres : in T_ptr_arbre; Indice : in Integer) return T_ARBRE is
   Cursor : T_ptr_arbre := Table_arbres;
   begin
      if Indice=1 then
         return Cursor.all.Arbre;
      end if;
      for i in 2..Indice loop
         Cursor := Cursor.all.Suivante;
      end loop;
      if Cursor/=null then
         return Cursor.all.Arbre;
      else
         raise Arbre_Absent_Exception;
      end if;
   end Arbre_indice;


   function Cle_Arbre_indice(Table_arbres : in T_ptr_arbre; Indice : in Integer) return T_Cle is
   begin
      return AB_La_Cle(Arbre_indice(Table_arbres, Indice));
   end Cle_Arbre_indice;


   function Valeur_Arbre_indice(Table_arbres : in T_ptr_arbre; Indice : in Integer) return T_Valeur is
   begin
      return AB_La_Valeur(Arbre_indice(Table_arbres, Indice));
   end Valeur_Arbre_indice;


   procedure Detruire_tab_arbre(Tab : in out T_ptr_arbre) is
   Cursor : T_ptr_arbre := Tab;
   A_detruire : T_ptr_arbre;
   begin
      if Est_vide_tab_arbre(Tab) then
         null;
      else
         while not Est_vide_tab_arbre(Cursor.all.Suivante) loop
            A_detruire := Cursor;
            Cursor := Cursor.all.Suivante;
            Free_TAB_AB(A_detruire);
         end loop;
      end if;
   end Detruire_tab_arbre;


   procedure Detruire_Cellule_Arbre(Tab : in out T_ptr_arbre; Arbre : in T_ARBRE) is
   Curseur : T_ptr_arbre := Tab;
   Curseur_Precedente : T_ptr_arbre;
   Curseur_Suivante : T_ptr_arbre;
   begin
      -- Vérifier si la liste est vide
		if Tab = Null or not Arbre_Present(Tab, Arbre) then
			raise Table_Arbre_Vide_Exception;
		end if;

		-- Vérifier si l'ARBRE est dans la première cellule
		if AB_egaux(Tab.all.Arbre,Arbre) then
			Curseur := Tab;
			Tab := Tab.all.Suivante;
			return;
		end if;

		--Avancer dans l'ARBRE jusqu'à la cellule précédant celle qu'on veut enlever afin de pouvoir récupérer cette première.
		while Curseur /= Null and then Curseur.all.Suivante /= Null and then not AB_egaux(Curseur.all.Suivante.all.Arbre,Arbre) loop
			Curseur := Curseur.all.Suivante;
		end loop;

		-- Vérifier si l'ARBRE a été trouvée
		if Curseur = Null or else Curseur.all.Suivante = Null then
			raise Arbre_Absent_Exception;
		end if;
		
		--Recupérer la cellule précédante, la suivante, et celle à enlever.
		Curseur_Precedente := Curseur;
		Curseur := Curseur.all.Suivante;
		Curseur_Suivante := Curseur.all.Suivante;

		--Supprimer la cellule.
		Curseur_Precedente.all.Suivante := Curseur_Suivante;
      Free_TAB_AB(Curseur);
   end Detruire_Cellule_Arbre;


   procedure Enregistrer_Arbre(Tab : in out T_ptr_arbre; Arbre : in T_ARBRE) is
   Nouvelle_cellule : T_ptr_arbre;
   begin 
      Nouvelle_cellule := new T_Cellule_Arbre;
      Nouvelle_cellule.all.Arbre := Arbre;
      Nouvelle_cellule.all.Suivante := Tab;
      Tab := Nouvelle_cellule;
   end Enregistrer_Arbre;


   procedure Afficher_Tab_Arbre(Tab : in T_ptr_arbre) is 
   Curseur : T_ptr_arbre := Tab;
   begin
      while Curseur/=Null loop
         New_Line;
         Afficher_Arbre(Curseur.all.Arbre);
         New_Line;
         Put(AB_Profondeur(Curseur.all.Arbre),1);
         Curseur := Curseur.all.Suivante;
      end loop;
   end Afficher_Tab_Arbre;


   procedure Mins_Tab_Arbre(Tab : in out T_ptr_arbre ; Min1 : out T_ARBRE ; Min2 : out T_ARBRE) is
   procedure Min_Tab_Arbre(Tab : in out T_ptr_arbre ; Min : out T_ARBRE) is
   begin
      if Est_vide_tab_arbre(Tab) then
         raise Table_Arbre_Vide_Exception;
      end if;
      Min := Tab.all.Arbre;
      for i in 1..Taille_Table_Arbre(Tab) loop
         if Inferieur_Strict(Valeur_Arbre_indice(Tab, i), AB_La_Valeur(Min)) then
            Min := Arbre_indice(Tab, i);
         end if;
      end loop;
      Detruire_Cellule_Arbre(Tab, Min);
   end Min_Tab_Arbre;
   begin
      Min_Tab_Arbre(Tab, Min1);
      Min_Tab_Arbre(Tab, Min2);
   end Mins_Tab_Arbre;


   function AB_Nombre_Noeuds(Arbre : in T_ARBRE) return Integer is
   begin
      if AB_Est_Vide(Arbre) then
         return 0;
      else
         return 1 + AB_Nombre_Noeuds(Arbre.all.Fils_Gauche) + AB_Nombre_Noeuds(Arbre.all.Fils_Droit);
      end if;
   end AB_Nombre_Noeuds;


   -- Corps des sous-programmes de la spécification pour le type T_ptr_infixe


   procedure Init_infixe(Tab : out T_ptr_infixe) is
   begin
      Tab:=Null;
   end Init_infixe;


   procedure Enregistrer_infixe(Tab : in out T_ptr_infixe; Valeur : in Integer) is
   Nouvelle_cellule : T_ptr_infixe;
   Curseur : T_ptr_infixe := Tab;
   begin
      Nouvelle_cellule := new T_Parcour_Infixe;
      Nouvelle_cellule.all.Valeur := Valeur;
      Nouvelle_cellule.all.Suivante := Null;
      if Tab = Null then
         Tab := Nouvelle_cellule;
      else
         while Curseur.all.Suivante /= Null loop
            Curseur := Curseur.all.Suivante;
         end loop;
         Curseur.all.Suivante := Nouvelle_cellule;
      end if;
   end Enregistrer_infixe;


   procedure Afficher_infixe(Tab : in T_ptr_infixe) is
   Curseur : T_ptr_infixe := Tab;
   begin
      while Curseur /= Null loop
         Afficher_element_infixe(Curseur.all.Valeur);
         Put(" ; ");
         Curseur := Curseur.all.Suivante;
      end loop;
   end Afficher_infixe;


   function Infixe_Indice(Tab : in T_ptr_infixe; Indice : in Integer) return Integer is
   Cursor : T_ptr_infixe := Tab;
   begin
      if Indice=1 then
         return Cursor.all.Valeur;
      end if;
      for i in 2..Indice loop
         Cursor := Cursor.all.Suivante;
      end loop;
      return Cursor.all.Valeur;
   end Infixe_Indice;


   procedure Detruire_infixe(Tab : in out T_ptr_infixe) is
   A_detruire : T_ptr_infixe;
   begin 
      if Tab = Null then
         Free_TAB_INFIXE(Tab);
      else
         while Tab /= Null loop
            A_detruire := Tab;
            Tab := Tab.all.Suivante;
            Free_TAB_INFIXE(A_detruire);
         end loop;
      end if;
   end Detruire_infixe;


   function Taille_infixe(Tab : in T_ptr_infixe) return Integer is
   begin
      if Tab = Null then
         return 0;
      else
         return 1+Taille_infixe(Tab.all.Suivante);
      end if;
   end Taille_infixe;


   function Taille_symbole(Tab : in T_ptr_symbole) return Integer is
   begin
      if Tab = Null then
         return 0;
      else
         return 1+Taille_symbole(Tab.all.Suivante);
      end if;
   end Taille_symbole;


   procedure Assigner_Infixe(Tab : in T_ptr_infixe; Tab_out : out T_ptr_infixe) is
   Curseur : T_ptr_infixe := Tab;
   begin
      Tab_out:=Null;
      while Curseur /= Null loop
         Enregistrer_infixe(Tab_out, Curseur.all.Valeur);
         Curseur := Curseur.all.Suivante;
      end loop;
   end Assigner_Infixe;


   procedure Enregistrer_infixe_indice(Tab : in out T_ptr_infixe; Valeur : in Integer; Indice : in Integer) is
   begin
      if Indice=1 then
         if Tab = Null then
            Tab:=new T_Parcour_Infixe;
            Tab.all.Suivante:=Null;
         end if;
         Tab.all.Valeur := Valeur;
      else
         Enregistrer_infixe_indice(Tab.all.Suivante, Valeur, Indice-1);
      end if;
   end Enregistrer_infixe_indice;


   procedure Symbole_encodage(Arbre : in T_ARBRE; Symbole : in T_Cle; gauche : in Boolean; indice : in Integer; Tab : in out T_ptr_infixe; Tab_out : out T_ptr_infixe) is
   Curseur : T_ptr_infixe :=Tab;
   begin
      if indice=0 then
         Symbole_encodage(Arbre.all.Fils_Gauche, Symbole, True, indice+1, Tab, Tab_out);
         Symbole_encodage(Arbre.all.Fils_Droit, Symbole, False, indice+1, Tab, Tab_out);
      else
         --Effacer les valeurs de Tab ayant un indice supérieur à l'indice actuel
         if Tab/=Null then
            if indice = 1 and Tab.all.Suivante /= Null then
               Detruire_infixe(Tab.all.Suivante);
               Tab.all.Suivante := Null;
            elsif indice > 1 then
               for i in 1..indice-1 loop
                  Curseur:=Curseur.all.Suivante;
               end loop;
               if Curseur/=Null then
                  Detruire_infixe(Curseur.all.Suivante);
               end if;
            end if;
         end if;
         if gauche then 
            Enregistrer_infixe_indice(Tab,0,indice);
         else
            Enregistrer_infixe_indice(Tab,1,indice);
         end if;
         if AB_Est_Feuille(Arbre) then
            if Arbre.all.Cle=Symbole then
               Assigner_Infixe(Tab, Tab_out);
            end if;
         else
            Symbole_encodage(Arbre.all.Fils_Gauche, Symbole, True, indice+1, Tab, Tab_out);
            Symbole_encodage(Arbre.all.Fils_Droit, Symbole, False, indice+1, Tab, Tab_out);
         end if;
      end if;
   end Symbole_encodage;


   -- === Corps des sous-programmes de la spécification pour le type T_ptr_symbole ===


   function Trouver_symbole_fin(Tab : in T_ptr_symbole) return Integer is
   begin
      if Different_fin(Tab.all.Symbole) then
         return 1+Trouver_symbole_fin(Tab.all.Suivante);
      else
         return 0;
      end if;
   end Trouver_symbole_fin;


   procedure Init_symbole(Tab : out T_ptr_symbole) is
   begin
      Tab:=Null;
   end Init_symbole;


   procedure Enregistrer_symbole(Tab : in out T_ptr_symbole; Symbole : in T_Cle) is
   Nouvelle_cellule : T_ptr_symbole;
   Curseur : T_ptr_symbole := Tab;
   begin
      Nouvelle_cellule := new T_Tab_symbole;
      Nouvelle_cellule.all.Symbole := Symbole;
      Nouvelle_cellule.all.Suivante := Null;
      if Tab = Null then
         Tab := Nouvelle_cellule;
      else
         while Curseur.all.Suivante /= Null loop
            Curseur := Curseur.all.Suivante;
         end loop;
         Curseur.all.Suivante := Nouvelle_cellule;
      end if;
   end Enregistrer_symbole;


   function Symbole_Indice(Tab : in T_ptr_symbole; Indice : in Integer) return T_Cle is
   Cursor : T_ptr_symbole := Tab;
   begin
      if Indice=1 then
         return Cursor.all.Symbole;
      end if;
      for i in 2..Indice loop
         Cursor := Cursor.all.Suivante;
      end loop;
      return Cursor.all.Symbole;
   end Symbole_Indice;


   procedure Afficher_symbole(Tab : in T_ptr_symbole) is
   Curseur : T_ptr_symbole := Tab;
   begin
      while Curseur /= Null loop
         Afficher_element_symbole(Curseur.all.Symbole);
         Curseur := Curseur.all.Suivante;
      end loop;
   end Afficher_symbole;


   procedure Detruire_symbole(Tab : in out T_ptr_symbole) is
   A_detruire : T_ptr_symbole;
   begin 
      if Tab = Null then
         Free_TAB_SYMBOLE(Tab);
      else
         while Tab /= Null loop
            A_detruire := Tab;
            Tab := Tab.all.Suivante;
            Free_TAB_SYMBOLE(A_detruire);
         end loop;
      end if;
   end Detruire_symbole;
   

   procedure Table_symbole_infixe(Arbre : in T_ARBRE; Tab_symbole : out T_ptr_symbole; Tab_arbre : out T_ptr_infixe) is
   begin
      if Arbre.all.Fils_Gauche /= Null then
         Enregistrer_infixe(Tab_arbre, 0);
         Table_symbole_infixe(Arbre.all.Fils_Gauche, Tab_symbole, Tab_arbre);
         Table_symbole_infixe(Arbre.all.Fils_Droit, Tab_symbole, Tab_arbre);
      else
         Enregistrer_infixe(Tab_arbre, 1);
         Enregistrer_symbole(Tab_symbole, Arbre.all.Cle);
      end if;
   end Table_symbole_infixe;


   procedure Enregistrer_Tab_Huffman(Symbole : in T_Cle; Tab_encodage : in T_ptr_infixe; Tab_Huffman : in out T_ptr_Huffman) is
   Nouvelle_cellule : T_ptr_Huffman;
   begin
      Nouvelle_cellule := new T_Cellule_Huffman;
      Nouvelle_cellule.all.Symbole := Symbole;
      Assigner_Infixe(Tab_encodage, Nouvelle_cellule.all.Tab_encodage);
      Nouvelle_cellule.all.Suivante := Tab_Huffman;
      Tab_Huffman := Nouvelle_cellule;
   end Enregistrer_Tab_Huffman;


   procedure Encodage_symbole(Symbole : in T_Cle; Tab_Huffman : in out T_ptr_Huffman; Tab_encodage : out T_ptr_infixe) is
   Curseur : T_ptr_Huffman := Tab_Huffman;
   begin
      while Curseur /= Null loop
         if Curseur.all.Symbole = Symbole then
            Assigner_Infixe(Curseur.all.Tab_encodage, Tab_encodage);
            return;
         end if;
         Curseur := Curseur.all.Suivante;
      end loop;

   end Encodage_symbole;


   procedure Detruire_Tab_Huffman(Tab : in out T_ptr_Huffman) is
   A_detruire : T_ptr_Huffman;
   begin 
      if Tab = Null then
         Free_TAB_HUFFMAN(Tab);
      else
         while Tab /= Null loop
            A_detruire := Tab;
            Free_TAB_INFIXE(A_detruire.all.Tab_encodage);
            Tab := Tab.all.Suivante;
            Free_TAB_HUFFMAN(A_detruire);
         end loop;
      end if;
   end Detruire_Tab_Huffman;

end Arbre;