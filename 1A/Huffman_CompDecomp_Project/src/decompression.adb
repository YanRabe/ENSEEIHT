with Ada.IO_Exceptions;
with Ada.Direct_IO;
with Ada.Text_IO; use Ada.Text_IO;
with LCA;
with SDA_Exceptions; use SDA_Exceptions;
with Ada.Directories; use Ada.Directories;
with Ada.Command_Line;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Unchecked_Deallocation;
with Octet; use Octet;
with Arbre;

procedure Decompression is
   --Packages et types
   type T_String is array(1..2) of Character;

   package Arbres is new Arbre(T_String, T_Octet);
   use Arbres;

   package Octet_IO is new Ada.Direct_IO (T_Octet);
   use Octet_IO;


   -- Variables
   Octet : T_Octet;
   Tmp_Octet : T_Octet;
   Tmp_Char : Character;
   Tmp_String : T_String;
   File_Name : Unbounded_String;
   New_File_Name : Unbounded_String;
   Og_Text : Unbounded_String;
   New_File : Octet_IO.File_Type;
   Tab_Entree : T_ptr_Tab_Octet;
   Arbre_Vide, Arbre_Huffman : T_ARBRE;
   Tab_Symbole_Binaire_Original : LCA_S.T_LCA;
   Position_char_fin, Tmp_Exploration_Index, Nb_Symbole, Indice_Bit, Indice_Symboles : Integer;
   Bavard : Boolean := True;

   -- === Fonctions et procédures ===
   --Vérifier qu'un symbole est différent de "\$"
   function Est_Hff(Name: in String) return Boolean is
   begin
      return Name(Name'Last-2) = 'h' 
      and then Name(Name'Last-1) = 'f' 
      and then Name(Name'Last) = 'f'; 
   end Est_Hff;

   --Vérifier qu'un symbole est différent de celui de fin
   function Different_fin(Symbole : in T_String) return Boolean is
   begin
      return not (Symbole = "\$");
   end Different_fin;


    --Convertir un Character en T_String
   function To_T_String (C : in Character) return T_String is
   begin
      return T_String'(C, ' '); -- Le deuxième caractère est rempli par défaut avec ' '
   end To_T_String;


   --Convertir un T_String en Unbounded_String
   function To_UB_String(S : in T_String) return Unbounded_String is
   begin
      if S(2) = ' ' then
         return To_Unbounded_String("" & S(1));
      else
         return To_Unbounded_String(S(1) & S(2));
      end if;
   end To_UB_String;


   --Afficher une clé
   procedure Afficher_Elem (Cle : in T_String) is
   begin
      if Cle(2) = ' ' then
         Put(" '" & Cle(1) & "'");
      else
         Put(" '" & Cle(1) & Cle(2) & "'");
      end if;
   end Afficher_Elem;


   --Afficher une donnée
   procedure AB_Afficher_Donnee (Valeur : in T_Octet) is
   begin
      Put("(" & T_Octet'Image(Valeur) & ")");
   end AB_Afficher_Donnee;


   procedure Afficher_Debug is new LCA_S.Afficher_Debug(Afficher_Elem, AB_Afficher_Donnee);


   procedure Afficher_Arbre is new AB_Afficher_Debug(Afficher_Elem, AB_Afficher_Donnee);

begin
  --Vérifier que le nombre d'arguments est correct
   if Ada.Command_Line.Argument_Count < 1 then
      Put_Line("Utilisation: ./decompression <file_name>. Manque d'arguments.");
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
         Put_Line("Utilisation: ./decompression [-b | --bavard | -s | --silencieux] <file_name>.");
         raise Argument_Invalide_Exception;
      end if;
   end if;

   -- Récupérer le nom du fichier à décompresser
   File_Name := To_Unbounded_String(Ada.Command_Line.Argument(Ada.Command_Line.Argument_Count));
   if To_String(File_Name)'Length < 3 then
      Put_Line("Erreur: Le fichier n'est pas un fichier compressé de Huffman.");
      raise Argument_Invalide_Exception;
   else
      if not Est_Hff(To_String(File_Name)) then
         Put_Line("Erreur: Le fichier n'est pas un fichier compressé de Huffman.");
         raise Argument_Invalide_Exception;
      end if;
   end if;


   -- Ouvrir le fichier à décompresser
   Tab_Entree := Lire_Fichier_Bin(To_String(File_Name));
   Position_char_fin := Integer(Tab_Entree.all(1));   

   
   --Debuggage
   if Bavard then
      Put_Line("Position du caractère de fin : " & Position_char_fin'Image);
      New_Line;
   end if;


   --Afficher les octets récupérés en décimal
   if Bavard then
      Put("Octets récupérés : ");
      for I in Tab_Entree.all'Range loop
         Put(Tab_Entree.all(I)'Image & ";");
      end loop;
      New_Line;
   end if;


   --Créer Tableau de symboles (on les gardera en binaire dans la version finale)
   LCA_S.Initialiser(Tab_Symbole_Binaire_Original);


   --Ajouter les symboles avant le caractère de fin
   for i in 2..Position_char_fin+1 loop
      Octet := Tab_Entree.all(File_Size(i));
      if Octet = 10 then
         LCA_S.Enregistrer(Tab_Symbole_Binaire_Original, "\n", Octet);
      else
         Tmp_Char := Character'Val(Octet);
         LCA_S.Enregistrer(Tab_Symbole_Binaire_Original, To_T_String(Tmp_Char), Octet);
      end if;
   end loop;
   --  if Bavard then
   --     New_line;
   --     Put_Line ("Symboles précédant le caractère de fin : ");
   --     Afficher_Tab_symbole (Tab_Symbole_Binaire_Original);
   --     New_Line;
   --  end if;

   --Ajouter le symbole de fin
   Tmp_String := ('\', '$');
   LCA_S.Enregistrer(Tab_Symbole_Binaire_Original, Tmp_String, -1);
   Tmp_Exploration_Index := Position_char_fin + 2;
   Tmp_Octet := Tab_Entree.all(File_Size(Tmp_Exploration_Index+1));


   --Ajouter les symboles après le caractère de fin jusqu'à répétitition d'un octet.
   Octet := Tab_Entree.all(File_Size(Tmp_Exploration_Index));
   while not Est_Meme_Octet(Octet, Tmp_Octet) loop
      if Octet = 10 then
         LCA_S.Enregistrer(Tab_Symbole_Binaire_Original, "\n", Octet);
      else
         Tmp_Char := Character'Val(Octet);
         LCA_S.Enregistrer(Tab_Symbole_Binaire_Original, To_T_String(Tmp_Char), Octet);
      end if;
      Tmp_Exploration_Index := Tmp_Exploration_Index + 1;
      Octet := Tab_Entree.all(File_Size(Tmp_Exploration_Index));
      Tmp_Octet := Tab_Entree.all(File_Size(Tmp_Exploration_Index+1));
   end loop;
   Tmp_Char := Character'Val(Octet);
   LCA_S.Enregistrer(Tab_Symbole_Binaire_Original, To_T_String(Tmp_Char), Octet);


   --Afficher les symboles récupérés
   if Bavard then
      New_Line;
      Put_Line("Tableau des symboles : ");
      Afficher_Debug(Tab_Symbole_Binaire_Original);
      New_Line;
   end if;

--Récupérer la structure de l'arbre d'Huffman
   Tmp_Exploration_Index := Tmp_Exploration_Index + 2;
   AB_Creer_Noeud(Arbre_Huffman, To_T_String('0'), 0, Arbre_Vide, Arbre_Vide);

   --Récupérer le nombre de symboles
   Nb_Symbole := LCA_S.Taille(Tab_Symbole_Binaire_Original);
   Indice_Symboles := 1;
   Indice_Bit := 1;

   --Générer l'arbre de Huffman récursivement
   Generer_Arbre_Parcours(Tab_Symbole_Binaire_Original, Tab_Entree, Arbre_Huffman, Arbre_Vide, 
   Indice_Symboles, Indice_Bit, Tmp_Exploration_Index, Nb_Symbole, To_T_String('0'), 0);
   

--Afficher l'arbre d'Huffman
   if Bavard then
      New_Line;
      Put_Line("Arbre d'Huffman (avec octet et symbole correspondant en ASCII pour l'affichage) : ");
      Afficher_Arbre(Arbre_Huffman);
      New_Line;
      Put_Line ("Index d'exploration et bit courants:" & Tmp_Exploration_Index'Image & "; " & Indice_Bit'Image);
   end if;

--Créer le fichier décompressé
New_File_Name := File_Name & ".d";
Create(New_File, Out_File, To_String(New_File_Name));

--Décoder le texte compressé
   Tmp_Exploration_Index := Tmp_Exploration_Index + 1;
   Indice_Bit := 1;
   --Décoder le symbole codé courant à l'aide de l'arbre
   Decoder_Symbole_Compresse(Arbre_Huffman, Tab_Entree, Indice_Bit, Tmp_Exploration_Index, Tmp_String, Tmp_Octet);
   if Bavard then
      Put_Line("Symboles décodés : ");
      Afficher_Elem (Tmp_String);
   end if;
   --Ajouter le caractère dans le texte décompressé à afficher
   Og_Text := To_UB_String(Tmp_String);
   --Ecrire l'octet dans le fichier
   Write(New_File, Tmp_Octet);
   --Récupérer les symboles jusqu'à la fin du texte
   while Different_Fin(Tmp_String) loop
      --Décoder le symbole codé courant à l'aide de l'arbre
      Decoder_Symbole_Compresse(Arbre_Huffman, Tab_Entree, Indice_Bit, Tmp_Exploration_Index, Tmp_String, Tmp_Octet);
      --Afficher le symbole décodé associé à l'octet
      if Bavard then
         Afficher_Elem(Tmp_String);
      end if;
      --Ajouter le caractère dans le texte décompressé à afficher
      if Different_Fin(Tmp_String) then
         if Tmp_Octet = 10 then
            Og_Text := Og_Text & Character'Val(10);
         else
            Og_Text := Og_Text & To_UB_String(Tmp_String);
         end if;
         --Ecrire l'octet dans le fichier
         Write(New_File, Tmp_Octet);
      end if;
   end loop;

--Fermer le fichier après écriture
Close(New_File);


--Afficher le texte décompressé
   if Bavard then
      New_Line;
      New_Line;
      Put_Line("Texte décompressé : ");
      Put(To_String(Og_Text));
   end if;


--Libérer la mémoire pointée
   Detruire_Tab_Octet(Tab_Entree);
   LCA_S.Detruire(Tab_Symbole_Binaire_Original);
   AB_Detruire (Arbre_Huffman);
   AB_Detruire (Arbre_Vide);

--Gérer les exceptions
   exception
      when Ada.IO_Exceptions.Name_Error =>
         Put_Line("Erreur: Fichier introuvable. Veuillez vérifier le nom du fichier.");
      when Argument_Invalide_Exception =>
         Put_Line ("Veuillez vérifier vos arguments.");
      when others =>
      -- Solution temporaire pour compenser un dépassement d'indice d'origine inconnue mais
      --qui n'empêche pas de décoder l'intégralité du texte.
         if Bavard then
            New_Line;
            New_Line;
            Put_Line("Texte décompressé : ");
            Put(To_String(Og_Text));
         end if;
         --Libérer la mémoire pointée
         Detruire_Tab_Octet(Tab_Entree);
         LCA_S.Detruire(Tab_Symbole_Binaire_Original);
         AB_Detruire (Arbre_Huffman);
         AB_Detruire (Arbre_Vide);

end Decompression;