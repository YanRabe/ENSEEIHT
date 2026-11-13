-- Définition d'une exception commune à toutes les SDA.
package SDA_Exceptions is

	Cle_Absente_Exception  : Exception;	-- une clé est absente d'un SDA
   Arbre_Absent_Exception : Exception; -- un arbre est absent d'une liste d'arbres
   Table_Arbre_Vide_Exception : Exception; -- une table d'arbre est vide
   Argument_Invalide_Exception : Exception; -- un argument est invalide
   
end SDA_Exceptions;
