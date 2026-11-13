with Ada.Text_IO; use Ada.Text_IO;
with Ada.IO_Exceptions; 
with SDA_Exceptions; use SDA_Exceptions;
with Ada.Streams.Stream_IO; use Ada.Streams.Stream_IO;
with Ada.Streams; use Ada.Streams;
with Ada.Command_Line;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Octet; use Octet;
with LCA;
with Arbre;


procedure Compression is

   type T_String is array(1..2) of Character;

   package ARBRE_Character is new Arbre(T_String, Integer);
   use ARBRE_Character;

   package LCA_Character is new LCA (T_String, Integer);
   use LCA_Character;

   Octet : T_Octet;
   File_Name : Unbounded_String;
   New_File_Name : Unbounded_String;
   New_File : Ada.Streams.Stream_IO.File_Type;
   Stream_input : Stream_Access;
   Stream_output : Stream_Access;
   File : Ada.Streams.Stream_IO.File_Type;
   Ch : Character;
   Frequences : T_LCA;
   Arbre_vide, Nouvel_Arbre: T_ARBRE;
   Min1, Min2 : T_ARBRE;
   Table_arbres : T_ptr_arbre;
   Arbre_Huffman : T_ARBRE;
   Tab_symbole : T_ptr_symbole;
   Tab_arbre_infixe, Tab_Int_Char: T_ptr_infixe;
   Position_char_fin : Integer;
   Bit_Count : Natural := 0;
   Table_Huffman : T_ptr_Huffman;
   Bavard : Boolean := True;
   

   function Different_fin(Symbole : in T_String) return Boolean is
   begin
      return not (Symbole = "\$");
   end Different_fin;


   function Inferieur_Strict(A : in Integer; B : in Integer) return Boolean is
   begin
      return A < B;
   end Inferieur_Strict;


   function To_Character(S : T_String) return Character is
   begin
      return S(1);
   end To_Character;


   -- Permet de convertir un Character en T_String
   function To_T_String (C : Character) return T_String is
   begin
      return T_String'(C, ' '); -- Le deuxième caractère est rempli par défaut avec ' '
   end To_T_String;


   procedure AB_Afficher_Cle (Cle : in T_String) is
   begin
      if Cle(2) = ' ' then
         Put(" '" & Cle(1) & "'");
      else
         Put(" '" & Cle(1) & Cle(2) & "'");
      end if;
   end AB_Afficher_Cle;


   procedure AB_Afficher_Donnee (Valeur : in Integer) is
   begin
      Put("(" & Integer'Image(Valeur) & ")");
   end AB_Afficher_Donnee;


   procedure AB_Afficher is new AB_Afficher_Debug(AB_Afficher_Cle, AB_Afficher_Donnee);


   procedure Min is new Mins_Tab_Arbre(Inferieur_Strict);


   function Indice_symbole_fin is new Trouver_symbole_fin(Different_fin);


   function Shift_Left (Value : in T_Octet; Amount : in Natural) return T_Octet is
   Octet : T_Octet := Value;
   begin
      for i in 1..Amount loop
         Octet :=(Octet * 2) or 0;
      end loop;
      return Octet;
   end Shift_Left;


begin

   --Vérifier que le nombre d'arguments est correct
   if Ada.Command_Line.Argument_Count < 1 then
      Put_Line("Utilisation: ./compression <file_name>. Manque d'arguments.");
      raise Argument_Invalide_Exception;
      
   --Vérifier les arguments et établir le mode
   elsif Ada.Command_Line.Argument_Count = 1 then
      Bavard := True;

   else
      if Ada.Command_Line.Argument (Ada.Command_Line.Argument_Count-1) = "-b" or 
      Ada.Command_Line.Argument (Ada.Command_Line.Argument_Count-1) = "--bavard" then
         Bavard := True;

      elsif Ada.Command_Line.Argument (Ada.Command_Line.Argument_Count-1) = "-s" or
      Ada.Command_Line.Argument (Ada.Command_Line.Argument_Count-1) = "--silencieux" then
         Bavard := False;

      else
         Put_Line("Utilisation: ./compression [-b | --bavard | -s | --silencieux] <file_name>.");
         raise Argument_Invalide_Exception;
      end if;
   end if;

   File_Name := To_Unbounded_String(Ada.Command_Line.Argument(Ada.Command_Line.Argument_Count));
   

   -- Initialiser la liste des fréquences
   Initialiser(Frequences);

   -- Ouvrir le fichier
   Open(File, In_File, To_String(File_Name));
   Stream_input := Stream(File);

   -- Lire chaque charactère et changer sa fréquence dans la LCA
   while not End_Of_File(File) loop
      Ch := Character'Input(Stream_input);
      if Ch /= ASCII.CR then
         if Ch = ASCII.LF then
            begin
               Enregistrer(Frequences, "\n", La_Valeur(Frequences, "\n") + 1);
               exception
                  when Cle_Absente_Exception =>
                     Enregistrer(Frequences, "\n", 1);
                  when others =>
                     Null;
            end;

         else
            begin
               Enregistrer(Frequences, To_T_String(Ch), La_Valeur(Frequences, To_T_String(Ch)) + 1);
               exception
                  when Cle_Absente_Exception =>
                     Enregistrer(Frequences, To_T_String(Ch), 1);
                  when others =>
                     Null; 
            end;
         end if;
      end if;
   end loop;
   Enregistrer(Frequences, "\$", 0);

   -- Fermer le fichier
   Close(File);


   --Initialiser l'arbre vide pour créer des feuilles
   AB_Initialiser(Arbre_vide);

   -- Créer le tableau des feuilles
   for i in 1..Taille(Frequences) loop
      AB_Creer_Noeud(Nouvel_Arbre, Cle_indice(Frequences, i), La_Valeur(Frequences, Cle_indice(Frequences, i)), Arbre_vide, Arbre_vide);
      Enregistrer_Arbre(Table_arbres, Nouvel_Arbre);
   end loop;

   -- Créer l'arbre de Huffman
   while Taille_Table_Arbre(Table_arbres) > 1 loop
      Min(Table_arbres, Min1, Min2);
      if AB_La_Valeur(Min1) > AB_La_Valeur(Min2) then
         AB_Creer_Noeud(Nouvel_Arbre,To_T_String('0'), AB_La_Valeur(Min1) + AB_La_Valeur(Min2), Min2, Min1);
      else
         AB_Creer_Noeud(Nouvel_Arbre,To_T_String('0'), AB_La_Valeur(Min1) + AB_La_Valeur(Min2), Min1, Min2);
      end if;
      Enregistrer_Arbre(Table_arbres, Nouvel_Arbre);
   end loop;
   Assigner(Arbre_indice(Table_arbres, 1),Arbre_Huffman);
   if Bavard then
      AB_Afficher(Arbre_Huffman);
      New_Line;
   end if;

   --Détruire le tableau d'arbre
   Detruire_tab_arbre(Table_arbres);

   -- Créer les tableaux de parcours infixe et de symbole de l'arbre d'Huffman
   Init_infixe(Tab_arbre_infixe);
   Init_symbole(Tab_symbole);
   Table_symbole_infixe(Arbre_Huffman, Tab_symbole, Tab_arbre_infixe);



   --Afficher la table de Huffmann
   declare 
      Bit_sequence : String(1..Taille_infixe(Tab_arbre_infixe));
      Tab : T_ptr_infixe;
      Tab_out : T_ptr_infixe;
      Symbole : T_String;
   begin
      for I in 1..Taille_symbole(Tab_symbole) loop
         Symbole := Symbole_Indice(Tab_symbole, I);
         Symbole_encodage(Arbre_Huffman, Symbole, False, 0, Tab, Tab_out);
         Enregistrer_Tab_Huffman(Symbole, Tab_out, Table_Huffman);
         if Bavard then
            New_Line;
            if Symbole(2) = ' ' then
               Put("'" & Symbole(1) & "'" & Symbole(2));
            else
               Put("'" & Symbole(1) & Symbole(2) & "'");
            end if;
            Put(" --> ");
            for j in 1..Taille_infixe(Tab_out) loop
               Bit_sequence(j) := Character'Val(48 + Infixe_Indice(Tab_out, j));
               Put(Bit_sequence(j));
            end loop;
         end if;
      end loop;
   end;

   --Créer la table des entiers représentant les symboles
   Init_infixe(Tab_Int_Char);
   Position_char_fin := Indice_symbole_fin(Tab_symbole);

   Enregistrer_infixe(Tab_Int_Char, Position_char_fin);
   for i in 1..Taille(Frequences) loop
      if Different_fin(Symbole_Indice(Tab_symbole, i)) then
         if Symbole_Indice(Tab_symbole, i)= "\n" then
            Enregistrer_infixe(Tab_Int_Char, 10);
         else      
            Enregistrer_infixe(Tab_Int_Char, Character'Pos(To_Character(Symbole_Indice(Tab_symbole, i))));
         end if;
      end if;
   end loop;
   Enregistrer_infixe(Tab_Int_Char, Character'Pos(To_Character(Symbole_Indice(Tab_symbole, Taille(Frequences)))));

   -- Ouvrir un nouveau fichier avec l'extension .hff pour y écrire les données compressées
   New_File_Name:= File_Name & ".hff";
   Create(New_File, Out_File, To_String(New_File_Name));

   -- Écrire les données compressées dans le nouveau fichier

   -- Ecrire la liste des symboles dans l'ordre du parcours infixe en binaire
   Stream_output := Stream(New_File);
   for i in 1..Taille(Frequences)+1 loop
      Octet := T_Octet(Infixe_Indice(Tab_Int_Char, i));
      T_Octet'Write(Stream_output, Octet);
   end loop;

   declare 
      Bit_sequence : String(1..Taille_infixe(Tab_arbre_infixe)); 
   begin 
      for i in Bit_sequence'Range loop
         Bit_sequence(i) := Character'Val(48 + Infixe_Indice(Tab_arbre_infixe, i));
      end loop;

      Octet:=0;

      -- Parcourir la séquence de bits
      for I in Bit_sequence'Range loop
   
         -- Ecrire les bits dans l'octet par ordre de poids 
         if Bit_Sequence(I) = '1' then
            Octet := (Octet*2) or 1;
         else 
            Octet := (Octet*2) or 0; 
         end if;

         -- Augmenter le bit count permettant de savoir combien de bits ont été accumulés dans l'octet
         Bit_Count := Bit_Count + 1;

         -- Lorsque l'octet est complété écire l'octet dans le fichier
         if Bit_Count = 8 then
            T_Octet'Write(Stream_output, Octet);
            Octet := 0; 
            Bit_Count := 0;     
         end if;
      end loop;

      -- Remplir le dernier octet avec des zéros
      if Bit_Count > 0 then
         Octet := Shift_Left(Octet, 8 - Bit_Count);
         T_Octet'Write(Stream_output, Octet);
      end if;
   end;
   
   Open(File, In_File, To_String(File_Name));
   Stream_input:= Stream(File);
   Octet:=0;
   Bit_Count:=0;
   declare 
      Bit_sequence : String(1..Taille_infixe(Tab_arbre_infixe));
      Symbole : T_String;
      Tab_encodage : T_ptr_infixe;
   begin
      while not End_Of_File(File) loop
         Ch := Character'Input(Stream_input);
         if Ch /= ASCII.CR then
            if Ch = ASCII.LF then
               Symbole:= "\n";
            else
               Symbole := To_T_String(Ch);
            end if;
            Encodage_symbole(Symbole, Table_Huffman, Tab_encodage);
            for i in 1..Taille_infixe(Tab_encodage) loop
               Bit_sequence(i) := Character'Val(48 + Infixe_Indice(Tab_encodage, i));
            end loop;
            -- Parcourir la séquence de bits
            for I in 1..Taille_infixe(Tab_encodage) loop
         
               -- Ecrire les bits dans l'octet par ordre de poids
               if Bit_Sequence(I) = '1' then
                  Octet := (Octet*2) or 1; 
               else 
                  Octet := (Octet*2) or 0; 
               end if;

               -- Augmenter le bit count permettant de savoir combien de bits ont été accumulés dans l'octet
               Bit_Count := Bit_Count + 1;

               -- Lorsque l'octet est complété écire l'octet dans le fichier
               if Bit_Count = 8 then
                  T_Octet'Write(Stream_output, Octet);
                  Octet := 0; 
                  Bit_Count := 0;    
               end if;
            end loop;
         end if;
      end loop;
      -- Ajouter le symbole de fin
      Symbole := "\$";
      Encodage_symbole(Symbole, Table_Huffman, Tab_encodage);
      for i in 1..Taille_infixe(Tab_encodage) loop
         Bit_sequence(i) := Character'Val(48 + Infixe_Indice(Tab_encodage, i));
      end loop;
      for I in 1..Taille_infixe(Tab_encodage) loop
      
         -- Ecrire les bits dans l'octet par ordre de poids
         if Bit_Sequence(I) = '1' then
            Octet := (Octet*2) or 1; 
         else 
            Octet := (Octet*2) or 0; 
         end if;

         -- Augmenter le bit count permettant de savoir combien de bits ont été accumulés dans l'octet
         Bit_Count := Bit_Count + 1;

         -- Lorsque l'octet est complété écire l'octet dans le fichier
         if Bit_Count = 8 then
            T_Octet'Write(Stream_output, Octet);
            Octet := 0; 
            Bit_Count := 0;    
         end if;
      end loop;
      -- Remplir le dernier octet avec des zéros
      if Bit_Count > 0 then
         Octet := Shift_Left(Octet, 8 - Bit_Count);
         T_Octet'Write(Stream_output, Octet);
      end if;
      --Detruire les tables infixe obsolètes
      Detruire_infixe(Tab_encodage);
   end;
   
   --Detruire les tables infixe obsolètes
   Detruire_infixe(Tab_arbre_infixe);
   Detruire_infixe(Tab_Int_Char);
   --Detruire les tables infixe obsolètes
   Detruire_symbole(Tab_symbole);
   --Detruire Arbres obslètes
   AB_Detruire(Arbre_Huffman);
   --Detruire la table de Huffman
   Detruire_tab_Huffman(Table_Huffman);

   -- Fermer le fichier input
   Close(File);

   -- Fermer le fichier output
   Close(New_File);

   --Détruire la liste des fréquences 
   Detruire(Frequences);
   exception
      when Ada.IO_Exceptions.Name_Error =>
         Put_Line("Fichier introuvale. Veuillez vérifier le nom du fichier.");
      when others =>
         raise;
end Compression;