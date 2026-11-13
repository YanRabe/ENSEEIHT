with Ada.Text_IO;            use Ada.Text_IO;
with SDA_Exceptions;         use SDA_Exceptions;
with Ada.Unchecked_Deallocation;

package body LCA is

	procedure Free is
		new Ada.Unchecked_Deallocation (Object => T_Struct_LCA, Name => T_LCA);


	procedure Initialiser(Sda: out T_LCA) is
	begin
		Sda := Null;
	end Initialiser;


	procedure Detruire (Sda : in out T_LCA) is
	begin
		if Sda /= Null then
			Detruire (Sda.all.Suivante);
			Free(Sda);
		else
			Null;
		end if;
	end Detruire;


   function Cle_indice (Sda : in T_LCA; Indice : in Integer) return T_Cle is
   Curseur : T_LCA := Sda;
   begin 
      if Indice=1 then
         return Curseur.all.Cle;
      end if;
      for i in 2..Indice loop
         if Curseur.all.Suivante /= Null then
            Curseur := Curseur.all.Suivante;
         end if;
      end loop;
      return Curseur.all.Cle;
   end Cle_indice;


	procedure Afficher_Debug (Sda : in T_LCA) is
	Curseur : T_LCA := Sda;
	begin
		if Sda /= Null then
			while Curseur /= Null loop
				Put("-->[");
				Afficher_Cle(Curseur.all.Cle);
				Put(" : ");
				Afficher_Donnee(Curseur.all.Valeur);
				Put("]");
				Curseur := Curseur.all.Suivante;
			end loop;
		end if;
      Put("--E");
      Free (Curseur);
	end Afficher_Debug;


	function Est_Vide (Sda : T_LCA) return Boolean is
	begin
		return (Sda = Null);
	end Est_Vide;


	function Taille (Sda : in T_LCA) return Integer is
	taille :Integer := 0;
	Curseur: T_LCA := Sda;
	begin
		while Curseur /= Null loop
			taille := taille + 1;
			Curseur := Curseur.all.Suivante;
		end loop;
      Free(Curseur);
		return taille;
	end Taille;


	procedure Enregistrer (Sda : in out T_LCA ; Cle : in T_Cle ; Valeur : in T_Valeur) is
	New_Cell : T_LCA;
	Curseur :T_LCA := Sda;
	begin
      while Curseur /= Null and then Curseur.all.Suivante /= Null and then Curseur.all.Cle /= Cle loop
         Curseur := Curseur.all.Suivante;
      end loop;
      
      if Curseur = Null then
         Sda := new T_Struct_LCA'(Cle, Valeur, Null);
      elsif Curseur.all.Cle = Cle then
         Curseur.all.Valeur := Valeur;
      else
         New_Cell := new T_Struct_LCA'(Cle, Valeur, Null);
         Curseur.all.Suivante := New_Cell;
      end if;
	end Enregistrer;


	function Cle_Presente (Sda : in T_LCA ; Cle : in T_Cle) return Boolean is
	Curseur:T_LCA := Sda;
	begin
		while Curseur /= Null and then Curseur.all.Cle /= Cle loop
			Curseur := Curseur.all.Suivante;
		end loop;
		return Curseur /= Null;
	end;


	function La_Valeur (Sda : in T_LCA ; Cle : in T_Cle) return T_Valeur is
	Curseur: T_LCA := Sda;
	begin
		while Curseur /= null and then Curseur.all.Cle /= Cle loop 
			Curseur := Curseur.all.Suivante;
		end loop;
		if Curseur = Null then
        	raise Cle_Absente_Exception;
    	else
        	return Curseur.all.Valeur;
    	end if;
	end La_Valeur;


	procedure Supprimer (Sda : in out T_LCA ; Cle : in T_Cle) is
	Curseur: T_LCA := Sda;
	Curseur_Suivante: T_LCA;
	Curseur_Precedente : T_LCA := Null;
	begin
		-- Vérifier si la liste est vide
		if Sda = Null or not Cle_Presente(Sda, Cle) then
			raise Cle_Absente_Exception;
		end if;

		-- Vérifier si la clé est dans la première cellule
		if Sda.all.Cle = Cle then
			Curseur := Sda;
			Sda := Sda.all.Suivante;
			Free(Curseur);
			return;
		end if;

		--Avancer dans la SDA jusqu'à la cellule précédant celle qu'on veut enlever afin de pouvoir récupérer cette première.
		while Curseur /= Null and then Curseur.all.Suivante /= Null and then Curseur.all.Suivante.all.Cle /= Cle loop
			Curseur := Curseur.all.Suivante;
		end loop;

		-- Vérifier si la clé a été trouvée
		if Curseur = Null or else Curseur.all.Suivante = Null then
			raise Cle_Absente_Exception;
		end if;
		
		--Recupérer la cellule précédante, la suivante, et celle à enlever.
		Curseur_Precedente := Curseur;
		Curseur := Curseur.all.Suivante;
		Curseur_Suivante := Curseur.all.Suivante;

		--Supprimer la cellule.
		Curseur_Precedente.all.Suivante := Curseur_Suivante;
		Free(Curseur);
      Free(Curseur_Precedente);
      Free(Curseur_Suivante);
	end Supprimer;


	procedure Pour_Chaque (Sda : in T_LCA) is
	Curseur :T_LCA := Sda;
	begin
		while Curseur /= Null loop
			begin
				Traiter(Curseur.all.Cle, Curseur.all.Valeur);
			exception
				when others =>
					Put_Line("Erreur lors du traitement de la cellule.");
			end;
			Curseur := Curseur.all.Suivante;
		end loop;
      Free(Curseur);
	end Pour_Chaque;

end LCA;
