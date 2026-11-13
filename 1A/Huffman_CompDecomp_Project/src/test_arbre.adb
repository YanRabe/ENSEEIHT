with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Integer_Text_IO;   use Ada.Integer_Text_IO;
with SDA_Exceptions;         use SDA_Exceptions;
with ARBRE;

procedure Test_ARBRE is

   package ARBRE_String_Integer is
      new Arbre (T_Cle => Character, T_Valeur => Integer);
   use ARBRE_String_Integer;


   procedure Afficher_Donnee (Valeur : in Integer) is
   begin
      Put("(");
      Put(Valeur,1);
      Put(")");
   end Afficher_Donnee;


   procedure Afficher_Cle (Cle : in Character) is
   begin
      Put("'" & Cle & "'");
   end Afficher_Cle;


   procedure Afficher is new AB_Afficher_Debug(Afficher_Cle => Afficher_Cle, Afficher_Donnee => Afficher_Donnee);

   
   procedure Afficher_Tab is new Afficher_Tab_Arbre(Afficher);


   Arbre_1, Arbre_2, Arbre_3, Arbre_4, Arbre_vide, Arbre_5 , Arbre_6, Arbre_7: T_ARBRE;
   Tab_Arbre: T_ptr_arbre;
   begin
      -- === Tests pour l'arbre ===
      Put_Line("=== Test minimal pour l'Arbre ===");
      New_Line;

      Put_Line("--- Test Initialisation ---");
      AB_Initialiser(Arbre_1);
      AB_Initialiser(Arbre_vide);
      pragma Assert(AB_Est_Vide(Arbre_1) = True);
      Put_Line("Initialisation fonctionne.");
      New_Line;

      Put_Line("---Test Nouveau Noeud ---");
      AB_Creer_Noeud(Arbre_1, 'm', 2, Arbre_vide, Arbre_vide);
      pragma Assert(AB_Est_Vide(Arbre_1) = False);
      pragma Assert(AB_Est_Feuille(Arbre_1) = True);
      pragma Assert(AB_La_Cle(Arbre_1) = 'm');
      pragma Assert(AB_La_Valeur(Arbre_1) = 2);

      New_Line;
      Afficher(Arbre_1);

      New_Line;
      New_Line;

      Put_Line("--- Test Assigner_Fils ---");
      AB_Creer_Noeud(Arbre_2, 'n', 3, Arbre_vide, Arbre_vide);
      AB_Creer_Noeud(Arbre_6, 'o', 4, Arbre_1, Arbre_2);
      AB_Creer_Noeud(Arbre_7, 'o', 4, Arbre_1, Arbre_2);
      AB_Creer_Noeud(Arbre_3, 'o', 4, Arbre_6, Arbre_7);
      pragma Assert(AB_La_Cle(Arbre_3) = 'o');
      pragma Assert(AB_Est_Vide(Arbre_3) = False);
      pragma Assert(AB_Est_Feuille(Arbre_3) = False);
      
      Afficher(Arbre_3);
      New_Line;


      -- === Tests pour le tableau d'arbre ===
      Put_Line("=== Test minimal pour le Tableau d'arbre ===");
      New_Line;

      Put_Line("--- Test Enregistrement ---");
      Enregistrer_Arbre(Tab_Arbre, Arbre_1);
      pragma Assert(Est_vide_tab_arbre(Tab_Arbre) = False);
      Put_Line("Est_vide_tab_arbre fonctionne.");
      pragma Assert(Arbre_Present(Tab_Arbre, Arbre_1) = True);
      Put_Line("Arbre_Present fonctionne.");
      Put("Le tableau obtenu est comme suit: ");
      Afficher_Tab(Tab_Arbre);
      New_Line;
      Put_Line("La procédure d'Enregistrement fonctionne.");
      New_Line;
      
      Put_Line("--- Test Accès ---");
      Assigner(Arbre_indice(Tab_Arbre, 1), Arbre_4);
      Afficher(Arbre_4);
      pragma Assert(Cle_Arbre_indice(Tab_Arbre, 1) = 'm');
      pragma Assert(Valeur_Arbre_indice(Tab_Arbre, 1) = 2);
      Put_Line("Les procédures d'Accès fonctionnent.");
      New_Line;

      Put_Line("--- Test Egalité ---");
      AB_Creer_Noeud(Arbre_5, 'm', 2, Arbre_vide, Arbre_vide);
      Assigner(Arbre_5, Arbre_4);
      pragma Assert(AB_egaux(Arbre_5, Arbre_4) = True);
      Put_Line("Les arbres sont égaux.");
      pragma Assert(AB_egaux(Arbre_3, Arbre_4) = False);
      Put_Line("La procédure d'Egalité fonctionne.");
      New_Line;

      Put_Line("--- Test Suppression ---");
      AB_Creer_Noeud(Arbre_5,'p',2,Arbre_vide,Arbre_vide);
      Enregistrer_Arbre(Tab_Arbre, Arbre_3);
      Enregistrer_Arbre(Tab_Arbre, Arbre_5);
      Afficher_Tab(Tab_Arbre);
      New_Line;
      Detruire_Cellule_Arbre(Tab_Arbre, Arbre_1);
      Put_Line("La cellule a été supprimée.");
      Afficher_Tab(Tab_Arbre);
      New_Line;
      pragma Assert(Arbre_Present(Tab_Arbre, Arbre_1) = False);
      Detruire_Cellule_Arbre(Tab_Arbre, Arbre_5);
      Put_Line("La cellule a été supprimée.");
      Afficher_Tab(Tab_Arbre);
      New_Line;
      pragma Assert(Arbre_Present(Tab_Arbre, Arbre_5) = False);
      Detruire_Cellule_Arbre(Tab_Arbre, Arbre_3);
      Put_Line("La cellule suivante a été supprimée.");
      Afficher(Arbre_3);
      New_Line;
      pragma Assert(Arbre_Present(Tab_Arbre, Arbre_3) = False);
      Put_Line("Voici le tableau d'arbre après suppression: ");
      Afficher_Tab(Tab_Arbre);
      Detruire_tab_arbre(Tab_Arbre);
      Put_Line("Le tableau a été supprimé.");
      Put_Line("La procédure de Suppression fonctionne.");
      New_Line;

      Put_Line(" == Tests terminés == ");

      exception
         when Table_Arbre_Vide_Exception => Put_Line("Tableau d'arbre vide.");
         when Arbre_Absent_Exception => Put_Line("Arbre absent.");
         when constraint_error => Put_Line("Erreur de contrainte.");
         when others => Put_Line("Erreur dans le test.");
      Put_Line(" == Tests terminés == ");

end Test_ARBRE;