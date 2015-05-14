with Ada.Text_IO, Comparaisons, File_Priorite;
use Ada.Text_IO, Comparaisons;
with Ada.Integer_Text_IO;

package body Arbre_Huffman is
        
        
	package Ma_File is new File_Priorite(Natural, Compare, Arbre);
	use Ma_File;
        
        --On définit le type liste pour des chiffres binaires, afin de stocker aisément le code des caractères de l'arbre lors de son parcours 
        package Package_Liste_ChiffreBinaire is new Liste(ChiffreBinaire, "<", Put_ChiffreBinaire);
        use Package_Liste_ChiffreBinaire;
        type Liste_ChiffreBinaire is new Package_Liste_ChiffreBinaire.Liste;
	
        type TabFils is array(ChiffreBinaire) of Arbre ;

	type Noeud(EstFeuille: Boolean) is record
		case EstFeuille is
			when True => Char : Character;
			when False =>
				Fils: TabFils;
				-- on a: Fils(0) /= null and Fils(1) /= null
		end case ;
	end record;



---------------------------------------------------------------------------------------------------------------------------------



        procedure Put_ChiffreBinaire(C: in ChiffreBinaire) is
        --nécessaire pour l'appel du package générique liste
        begin
        Put(C);
        end;

	procedure Affiche_Arbre(A: Arbre; H: in Integer) is
        begin
               
		if A.EstFeuille then
                --On se réduit aux lettres de l'alphabet courant pour plus de lisibilité
                if (A.Char in 'a'..'z' or A.Char in 'A'..'Z') then
                Put(A.Char);
                --On affiche la longueur du code qui code chaque caractère
                New_Line;
		Put("Profondeur:");
                Put(H);
                Put(" ");
                end if;
                else
                --On effectue la même chose pour le fils gauche, et le fils droit
                Affiche_Arbre(A.Fils(0),H+1);
                Affiche_Arbre(A.Fils(1),H+1);
                end if;
	end Affiche_Arbre;

	-- algo principal : calcul l'arbre a partir des frequences
	function Calcul_Arbre(Frequences : in Tableau_Ascii) return Arbre is
		A : Arbre;
                P1,P2 : Natural; --Priorités des deux arbres de probabilités minimales dans la file
                Non_Vide: Boolean:=true;
                File:Ma_File.File:=Nouvelle_File(Frequences'Length);
	begin
                --On construit la file de priorité initiale des arbres-feuilles  
                
                for i in Frequences'first..Frequences'last loop
                        declare
                        B: Arbre := new Noeud(True);
                        begin
                        B.Char:=i;
                        Insertion(File,Frequences(i),B);
                        end;
                end loop;
                
                --Et on construit l'arbre

                while (Non_Vide) loop --la liste est initialement non vide
                declare 
                A1,A2:Arbre; -- Les deux arbres de probabilités minimales de la file, de probabilités P1 et P2
                Filsb:TabFils;
                A3:Arbre; -- Arbre construit à partir de A1 et A2, de proba P1+P2
                begin
                -- On retire A1 de la file
                Meilleur(File,P1,A1,Non_Vide); 
                Suppression(File);
                -- On retire A2 de la file
                Meilleur(File,P2,A2,Non_Vide);
                --Si A2 existe (l'algo n'est pas terminé)
                if Non_vide then 
                     -- On le supprime
                     Suppression(File);
                     -- On construit A3
                     Filsb(0):=A1;
                     Filsb(1):=A2;
                     A3 := new Noeud'(False,Filsb);
                     -- Et on insère A3
                     Insertion(File,P1+P2,A3);
                else
                --A2 n'existe pas, la file contenait un unique arbre, l'arbre à construire, qu'on stocke dans A
                A:=A1;
                end if;
                end;
                end loop;
		return A; 
	end Calcul_Arbre;

	function Calcul_Dictionnaire(A : Arbre) return Dico is
		D : Dico;
                L : Liste_ChiffreBinaire := Liste_Vide ;

                -- On va définir une fonction récursive pouvant stocker son parcours antérieur dans l'arbre afin de déterminer facilement le code du noeud qu'elle traite
                --Pour cela, on utilise une liste, Liste_ChiffreBinaire

                procedure calculbis(A: in Arbre;L: in out Liste_ChiffreBinaire;D: in out Dico) is
                e: ChiffreBinaire;
                begin
                if(not A.EstFeuille) then
                       --Si le noeud courant n'est pas un feuille, alors le code de toutes les feuilles
                       --du sous arbre gauche commencera par L@0
                       Insertion_Queue(0,L);
                       calculbis(A.Fils(0),L,D);
                       Supprime_Queue(e,L);
                       --Et celles du sous arbre droit, par L@1
                       Insertion_Queue(1,L);
                       calculbis(A.Fils(1),L,D);
                       Supprime_Queue(e,L);
                else
                -- si c'est un feuille, il faut convertir L, une Liste_ChiffreBinaire en Code 
                        declare
                        C:Code := new TabBits(1..Taille(L));
                        Lbis:Liste_ChiffreBinaire := L;
                        begin
                        for i in 1..Taille(L) loop
                                C.all(i):=(Valeur(Lbis));
                                Lbis:=Suivant(Lbis);
                        end loop;
                -- On stocke le résultat C dans le dictionnaire, à l'indice correspondant au caractère de la feuille
                        D(A.Char) := C;
                        end; 
                        end if;
                end calculbis;
                
                --Programme principal, executé sur l'arbre A, à partir d'une liste vide L
                begin
                calculbis(A,L,D);
		return D;
	end;

	procedure Decodage_Code(Reste : in out Code;
		Arbre_Huffman : Arbre;
		Caractere : out Character) is

		Position_Courante : Arbre;
                ResteB: Liste_ChiffreBinaire := Liste_Vide; --On va copier la valeur de Reste dans ResteB 
		Tmp,R : Natural;
                T:ChiffreBinaire;
	begin
                -- On copie Reste dans ResteB si Reste n'est pas null
                if Reste /= null then

                for i in Reste.all'first..Reste.all'last loop
                        Insertion_Queue(Reste.all(i),ResteB);        
                end loop;
                -- On libère Reste
                Liberer(Reste);
                end if;

		Position_Courante := Arbre_Huffman; --Position courante est à la racine
		while not Position_Courante.EstFeuille loop --Tant qu'on n'est pas à une feuille
			if Est_Vide(ResteB) then
				--chargement de l'octet suivant du fichier
				Caractere := Octet_Suivant;
				Tmp := Character'Pos(Caractere);
				for I in 1..8 loop
					R := Tmp mod 2;
                                        Insertion_Tete(R,ResteB);
					Tmp := Tmp / 2;
				end loop;
			end if;
                        -- L'octet suivant est chargé dans Reste
			Position_Courante := Position_Courante.Fils(Valeur(ResteB)) ;
                        -- On se déplace dans l'arbre selon la valeur du code stocké dans Reste
		        Supprime_Tete(T,ResteB);
                        --On supprime le bit qu'on vient de lire
		end loop;
		Caractere := Position_Courante.Char;
                --On stocke les valeurs de ResteB dans Reste (futur caractère à lire)
                Reste := new TabBits(1..Taille(ResteB));
                for i in Reste.all'first..Reste.all'last loop
                        Supprime_Tete(T,ResteB);
                        Reste.all(i) := T;
                end loop;

	end;

        procedure Put(C:in Code) is
        A: Integer := 0;
        begin   
        Put(C.all'last-C.all'first+1);
                for i in C.all'first..C.all'last loop
                        A:=A*10+C.all(i); 
                end loop;
                Put(A);
        end;



        procedure Encryptage_Arbre(A: in Arbre; C: out Code) is
        
        procedure Ajout_Char(K:in Character; C: in out Liste_ChiffreBinaire) is 
        A : Integer := Character'Pos(K);
        L : Liste_ChiffreBinaire := Liste_Vide;
        begin
                for i in 1..8 loop
                        Insertion_Queue((A mod 2),L); 
                        A := A/2;
                end loop;
                While not Est_Vide(L) loop
                        Supprime_Queue(A,L);
                        Insertion_Queue(A,C);
                end loop;
        end;
        
        procedure Encryptagebis(A: in Arbre; C: in out Liste_ChiffreBinaire) is
                begin
                if A.EstFeuille then
                        Insertion_Queue(1,C);
                        Ajout_Char(A.Char,C);
                else
                        Insertion_Queue(0,C);
                        Encryptagebis(A.Fils(0),C);
                        Encryptagebis(A.Fils(1),C);
                end if;
                end Encryptagebis;
        L: Liste_ChiffreBinaire := Liste_Vide;
        T:ChiffreBinaire;


        begin
           Encryptagebis(A,L);
           C := new TabBits(1..Taille(L));
           for i in C.all'range loop
                Supprime_Tete(T,L);
                C.all(i) := T;
           end loop;
        end;

        procedure Decryptage_Arbre(Reste: in out Code; A: out Arbre) is

        -- Procedure auxiliaire recursive
	procedure DecryptBis(ResteB: in out Liste_ChiffreBinaire; A: in out Arbre) is
        
        Fils: TabFils := (others => null);
        T: ChiffreBinaire;
        K: Character;
        Val_Char: Integer := 0;
        begin

        Supprime_Tete(T,ResteB);
	
        if (T=1) then
		--On ajoute une feuille à l'arbre
      		-- on met le caractère dans K
		Val_Char := 0;
                for i in 1..8 loop
                      Supprime_Tete(T,ResteB);
                      Val_Char := 2*Val_Char + T;
                end loop;
                K := Character'Val(Val_Char);
		--On crée la feuille associé
                A := new Noeud'(True,K);
        else
		--Si ce n'est pas une feuille, on crée un noeud, et recommence
                A := new Noeud'(False, Fils);
                DecryptBis(ResteB,A.Fils(0));
                DecryptBis(ResteB,A.Fils(1));
        end if;
        
        end;
	
	ResteB : Liste_ChiffreBinaire := Liste_Vide;
        Tmp,R : Integer;
        Caractere : Character;
        T: ChiffreBinaire;
	K: Integer := 0;
	--Programme principal
        begin
         	
		--chargement du code de l'arbre
		for i in 1..Reste.all'last/8 loop
			
			Caractere := Octet_Suivant;
			Tmp := Character'Pos(Caractere);
			for j in 1..8 loop
				R := Tmp mod 2;
				Reste.all(i*8-j+1) := R;
				Tmp := Tmp / 2;
			end loop;
			
		end loop;
		
		--On traduit Reste en Liste_ChiffreBinaire
		for i in Reste.all'range loop
			Insertion_Queue(Reste.all(i),ResteB);
		end loop;
		Liberer(Reste);
		
		-- On Construit l'arbre
                DecryptBis(ResteB,A);
		
		--On stocke le reste des bits non utilisés dans Reste
                Reste := new TabBits(1..(Taille(ResteB)));
                
                for i in Reste.all'first..Reste.all'last loop
                        Supprime_Tete(T,ResteB);
                        Reste.all(i) := T;
                end loop;
        end;
end;
