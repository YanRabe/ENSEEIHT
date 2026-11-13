with Ada.Unchecked_Deallocation;
with Ada.Streams.Stream_IO; use Ada.Streams.Stream_IO;
with Ada.Directories; use Ada.Directories;
package body Octet is 

   --Procédure de libération de la mémoire
   procedure Free_Tab_Octet is new Ada.Unchecked_Deallocation(T_Tab_Octet, T_ptr_Tab_Octet);


   --Détruire le tableau
   procedure Detruire_Tab_Octet(Tab : in out T_ptr_Tab_Octet) is
   begin
      Free_Tab_Octet(Tab);
   end Detruire_Tab_Octet;
   --Vérifier si deux octets sont identiques
      function Est_Meme_Octet(Octet_1, Octet_2 : in T_Octet) return Boolean is
   begin
      return Octet_1 = Octet_2;
   end Est_Meme_Octet;


   --Lire le fichier binaire
   function Lire_Fichier_Bin(Filename : String) return T_ptr_Tab_Octet is

      Taille_Fichier_Bin : File_Size := Ada.Directories.Size(Filename);
      Contenu : T_ptr_Tab_Octet; 
      Flux : Stream_Access;   
      File : File_Type;
 
   begin
      Contenu := new T_Tab_Octet (1 .. Taille_Fichier_Bin);
      Open(File, In_File, Filename);
      Flux := Stream(File);
 
      T_Tab_Octet'Read (Flux, Contenu.all);
 
      Close (File);
 
      return Contenu;
   end Lire_Fichier_Bin;

end Octet;