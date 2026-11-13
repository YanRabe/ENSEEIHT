--Définition d'un Arbre binaire en utilisant le schéma des
--structures chainees associatives.
with Octet; use Octet;
with LCA;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

generic
   type T_Cle is private;
   type T_Valeur is private;

package ARBRE is
   type T_ARBRE is limited private;
   type T_ptr_arbre is limited private;
   type T_ptr_infixe is limited private;
   type T_ptr_symbole is limited private;
   type T_ptr_Huffman is limited private;

   package LCA_S is 
      new LCA(T_Cle, T_Valeur);
   use LCA_S;

   -- === Spécification des sous-programmes pour l'arbre ===
   -- Initialiser un Arbre.  L'Arbre est vide.
	procedure AB_Initialiser(Arbre: out T_ARBRE) with
		Post => AB_Est_Vide (Arbre);


	-- Détruire un Arbre. Il ne devra plus être utilisée.
	procedure AB_Detruire (Arbre : in out T_ARBRE);


	-- Est-ce qu'un Arbre est vide ?
	function AB_Est_Vide (Arbre : in T_ARBRE) return Boolean;


   --Est-ce que c'est une feuille ?
   function AB_Est_Feuille(Arbre: in T_ARBRE) return Boolean;


   -- Assigner un noeud à un autre noeud.
   procedure Assigner(Noeud: in T_Arbre ; Noeud_copie : out T_Arbre);


   --Permet de récupérer la profondeur d'un arbre
   function AB_Profondeur(Arbre: in T_ARBRE) return Integer;


   -- Comparer deux arbres.
   function AB_egaux(Arbre1 : in T_ARBRE ; Arbre2 : in T_ARBRE) return Boolean;


   -- Créer un noeud avec une clé, une valeur associée et les fils gauche et droit.
   procedure AB_Creer_Noeud(Noeud: out T_ARBRE; Cle: in T_Cle; Valeur: in T_Valeur; Fils_Gauche : in T_ARBRE; Fils_Droit : in T_ARBRE); 
      --  with
      --  Post => (La_Cle(Noeud) = Cle) and (La_Valeur(Noeud) = Valeur) and (Noeud.all.Fils_Gauche = Fils_Gauche) and (Noeud.all.Fils_Droit = Fils_Droit);

	-- Assigner une clé associée à un noeud.
	procedure AB_Assigner_Cle (Noeud : in out T_ARBRE ; Cle : in T_Cle) with
		Post => (AB_La_Cle (Noeud) = Cle) ;  -- clé insérée


   --  -- Assigner  une valeur associée à un noeud.
	procedure AB_Assigner_Valeur (Noeud : in out T_ARBRE ; Valeur : in T_Valeur) with
		Post => (AB_La_Valeur(Noeud) = Valeur) ;  -- Valeur insérée


   --  --Assigner un fils gauche à un noeud. Assigne le parent par la même occasion.
   --  procedure Assigner_Fils_Gauche (Noeud: in out T_ARBRE; Fils: in out T_ARBRE);


   --  --Assigner un fils droit à un noeud. Assigne le parent par la même occasion.
   --  procedure Assigner_Fils_Droit (Noeud: in out T_ARBRE; Fils: in out T_ARBRE);


	-- Obtenir la valeur associée du noeud.
	-- Exception : Cle_Absente_Exception si Clé n'est pas utilisée dans l'Arbre
	function AB_La_Valeur (Noeud : in T_ARBRE) return T_Valeur;


   --Obtenir la clé du noeud.
   function AB_La_Cle (Noeud: in T_ARBRE) return T_Cle;


   --Obtenir le fils gauche du noeud.
   function AB_Fils_Gauche (Noeud: in T_ARBRE) return T_ARBRE;


   --Obtenir le fils droit du noeud.
   function AB_Fils_Droit (Noeud: in T_ARBRE) return T_ARBRE;


   --Obtenir le nombre de noeuds dans un arbre
   function AB_Nombre_Noeuds(Arbre : in T_ARBRE) return Integer;


   -- Afficher l'Arbre en révélant sa structure interne.
	generic
		with procedure Afficher_Cle (Cle : in T_Cle);
		with procedure Afficher_Donnee (Valeur : in T_Valeur);
	procedure AB_Afficher_Debug (Arbre : in T_ARBRE);
   

   --Générer l'arbre de Huffman à partir du parcours infixe
   procedure Generer_Arbre_Parcours(Tab_symbole : in T_LCA; Tab_Entree : in T_ptr_Tab_Octet; 
   Arbre, Arbre_vide : in out T_ARBRE; Indice_Symboles, Indice_Bit, Indice_Parcours_Entree, Indice_Symboles_Max : in out Integer;
   Cle_Default: in T_Cle; Valeur_Default: in T_Valeur);


   --Décoder un symbole compressé en utilisant l'arbre d'Huffman
   procedure Decoder_Symbole_Compresse(Arbre: in T_ARBRE; Tab_Entree : in T_ptr_Tab_Octet; Indice_Bit, Indice_Parcours_Entree : in out Integer;
   String: in out T_Cle; Octet_du_String: in out T_Valeur);


   -- === Specification pour les sous-programmes associés aux tableaux d'arbres ===

   -- Permet de vérifier si un tableau d'arbre est vide
   function Est_vide_tab_arbre(Tab : in T_ptr_arbre) return Boolean;


   -- Permet de vérifier si un arbre est présent dans un tableau d'arbre
   function Arbre_Present(Tab : T_ptr_arbre; Arbre : T_ARBRE) return Boolean;


   -- Permet de récupérer la taille d'un tableau d'arbre
   function Taille_Table_Arbre(Tab : in T_ptr_arbre) return Integer;


   -- Permet de récupérer le pointeur d'une cellule d'arbre à un indice donné dans un tableau d'arbre
   function Arbre_indice(Table_arbres : in T_ptr_arbre; Indice : in Integer) return T_ARBRE;


   -- Permet de récupérer la clé d'un arbre à un indice donné dans un tableau d'arbre
   function Cle_Arbre_indice(Table_arbres : in T_ptr_arbre; Indice : in Integer) return T_Cle;


   -- Permet de récupérer la clé d'un arbre à un indice donné dans un tableau d'arbre
   function Valeur_Arbre_indice(Table_arbres : in T_ptr_arbre; Indice : in Integer) return T_Valeur;


   -- Permet d'enregistrer un arbre dans un tableau d'arbre
   procedure Enregistrer_Arbre(Tab : in out T_ptr_arbre; Arbre : in T_ARBRE);


   --Permet de supprimer un tableau d'arbre
   procedure Detruire_tab_arbre(Tab : in out T_ptr_arbre);


   --Permet de supprimer une cellule d'arbre dans un tableau d'arbre
   procedure Detruire_Cellule_Arbre(Tab : in out T_ptr_arbre; Arbre : in T_ARBRE);


   --Permet de renvoyer les deux arbres de valeur minimale d'un tableau d'arbre et de les supprimer du tableau d'arbre
   generic
   with function Inferieur_Strict(A : in T_Valeur; B : in T_Valeur) return Boolean;
   procedure Mins_Tab_Arbre(Tab : in out T_ptr_arbre ; Min1 : out T_ARBRE ; Min2 : out T_ARBRE);


   -- Permet de générer les tableaux de parcours infixe et de symbole de l'arbre d'Huffman
   procedure Table_symbole_infixe(Arbre : in T_ARBRE; Tab_symbole : out T_ptr_symbole; Tab_arbre : out T_ptr_infixe);


   -- Permet d'afficher un tableau d'arbre
   generic
      with procedure Afficher_Arbre(Arbre : in T_ARBRE);
   procedure Afficher_Tab_Arbre(Tab : in T_ptr_arbre);


   -- Permet d'initialiser un tableau de parcours infixe
   procedure Init_infixe(Tab : out T_ptr_infixe);


   -- Permet d'enregistrer une valeur dans un tableau de parcours infixe
   procedure Enregistrer_infixe(Tab : in out T_ptr_infixe; Valeur : in Integer);


   -- Permet de récupérer une valeur à un indice donné dans un tableau de parcours infixe
   function Infixe_Indice(Tab : in T_ptr_infixe; Indice : in Integer) return Integer;


   -- Permet de supprimer un tableau de parcours infixe
   procedure Detruire_infixe(Tab : in out T_ptr_infixe);


   -- Permet de récupérer la taille d'un tableau de parcours infixe
   function Taille_infixe(Tab : in T_ptr_infixe) return Integer;


   -- Permet d'enregistrer une valeur à un indice donné dans un tableau de parcours infixe
   procedure Enregistrer_infixe_indice(Tab : in out T_ptr_infixe; Valeur : in Integer; Indice : in Integer);


   --Permet d'assigner un tableau de parcours infixe à un autre tableau de parcours infixe
   procedure Assigner_Infixe(Tab : in T_ptr_infixe; Tab_out : out T_ptr_infixe);


   --Permet d'obtenir l'encodage binaire d'un symbole c'est a dire son parcours dans l'arbre d'Huffman generique pour l'affichage debugg
   procedure Symbole_encodage(Arbre : in T_ARBRE; Symbole : in T_Cle; gauche : in Boolean; indice : in Integer; Tab : in out T_ptr_infixe; Tab_out : out T_ptr_infixe);


   -- Permet d'initialiser un tableau de symbole en faisant un parcours infixe de l'arbre d'Huffman
   procedure Init_symbole(Tab : out T_ptr_symbole);


   -- Permet d'enregistrer un symbole dans un tableau de symbole
   procedure Enregistrer_symbole(Tab : in out T_ptr_symbole; Symbole : in T_Cle);


   -- Permet de récupérer le symbole à un indice donné dans un tableau de symbole
   function Symbole_Indice(Tab : in T_ptr_symbole; Indice : in Integer) return T_Cle;


   -- Permet de récupérer la taille d'un tableau de symbole
   function Taille_symbole(Tab : in T_ptr_symbole) return Integer;


   -- Permet de supprimer un tableau de symbole
   procedure Detruire_symbole(Tab : in out T_ptr_symbole);


   -- Permet d'enregistrer une nouvelle cellule dans un tableau de Huffman
   procedure Enregistrer_Tab_Huffman(Symbole : in T_Cle; Tab_encodage : in T_ptr_infixe; Tab_Huffman : in out T_ptr_Huffman);


   -- Permet de récupérer l'encodage d'un symbole dans une table de Huffman
   procedure Encodage_symbole(Symbole : in T_Cle; Tab_Huffman : in out T_ptr_Huffman; Tab_encodage : out T_ptr_infixe);


   -- Permet de supprimer un tableau de Huffman
   procedure Detruire_Tab_Huffman(Tab : in out T_ptr_Huffman);


   generic
      with function Different_fin(Symbole : in T_Cle) return Boolean;
   function Trouver_symbole_fin(Tab : in T_ptr_symbole) return Integer;


   generic 
      with procedure Afficher_element_infixe(Valeur : in Integer);
   procedure Afficher_infixe(Tab : in T_ptr_infixe);


   generic
      with procedure Afficher_element_symbole(Valeur : in T_Cle);
   procedure Afficher_symbole(Tab : in T_ptr_symbole); 

   
private
   type T_Noeud_Arbre;
   type T_ARBRE is access T_Noeud_Arbre;

   type T_Noeud_Arbre is record
      Cle: T_Cle;
      Valeur: T_Valeur;
      Fils_Gauche: T_ARBRE;
      Fils_Droit: T_ARBRE;
   end record;

   type T_Cellule_Arbre;
   type T_ptr_arbre is access T_Cellule_Arbre;
   type T_Cellule_Arbre is record
      Arbre : T_ARBRE;
      Suivante : T_ptr_arbre;
   end record;


   -- Structure de données utilisée pour parcourir un arbre en Infixe


   type T_Parcour_Infixe;
   type T_ptr_infixe is access T_Parcour_Infixe;
   type T_Parcour_Infixe is record
      Valeur: Integer;
      Suivante: T_ptr_infixe;
   end record;

   -- Structure de données utilisée pour stocker les symboles de l'Arbre de Huffmann

   type T_Tab_symbole;
   type T_ptr_symbole is access T_Tab_symbole;
   type T_Tab_symbole is record
      Symbole : T_Cle;
      Suivante : T_ptr_symbole;
   end record;

   -- Structure de données permettant de mainpuler la table d'Huffman

   type T_Cellule_Huffman;
   type T_ptr_Huffman is access T_Cellule_Huffman;
   type T_Cellule_Huffman is record
      Symbole : T_Cle;
      Tab_encodage : T_ptr_infixe;
      Suivante : T_ptr_Huffman;
   end record;

end ARBRE;