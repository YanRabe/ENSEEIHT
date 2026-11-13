with Ada.Directories; use Ada.Directories;

package Octet is
   type T_Octet is mod 2**8;
   type T_Tab_Octet is array(File_Size range <>) of T_Octet;
   type T_ptr_Tab_Octet is access T_Tab_Octet;

   --Procédure de destruction du tableau
   procedure Detruire_Tab_Octet(Tab : in out T_ptr_Tab_Octet);


   --Vérifier si deux octets sont identiques
   function Est_Meme_Octet(Octet_1, Octet_2 : in T_Octet) return Boolean;


   --Lire un fichier binaire
   function Lire_Fichier_Bin(Filename : String) return T_ptr_Tab_Octet;


end Octet;