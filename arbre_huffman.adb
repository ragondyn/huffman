with Ada.Text_IO, Comparaisons, File_Priorite;
use Ada.Text_IO, Comparaisons;
with Ada.Integer_Text_IO;

package body Arbre_Huffman is
        
        
	package Ma_File is new File_Priorite(Natural, Compare, Arbre);
	use Ma_File;

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
        procedure Put_ChiffreBinaire(C: in ChiffreBinaire) is
        begin
        Put(C);
        end;
	procedure Affiche_Arbre(A: Arbre; H: in Integer) is
        begin
                if A.EstFeuille then
                if (A.Char in 'a'..'z') then
                Put(A.Char);
                Put(H);
                end if;
                else
                Affiche_Arbre(A.Fils(0),H+1);
                Affiche_Arbre(A.Fils(1),H+1);
                end if;
	end Affiche_Arbre;

	--algo principal : calcul l'arbre a partir des frequences
	function Calcul_Arbre(Frequences : in Tableau_Ascii) return Arbre is
		A : Arbre;
                P1,P2 : Natural;
                Non_Vide: Boolean:=true;
                File:Ma_File.File:=Nouvelle_File(Frequences'Length);
	begin
                for i in Frequences'first..Frequences'last loop
                        declare
                        B: Arbre := new Noeud(True);
                        begin
                        B.Char:=i;
                        Insertion(File,Frequences(i),B);
                        end;
                end loop;

                while (Non_Vide) loop --la liste est initialement non vide
                declare 
                A1,A2:Arbre;
                Filsb:TabFils;
                A3:Arbre;
                begin
                Meilleur(File,P1,A1,Non_Vide);
                Suppression(File);
                Meilleur(File,P2,A2,Non_Vide);
                if Non_vide then
                     Suppression(File);
                     Filsb(0):=A1;
                     Filsb(1):=A2;
                     A3 := new Noeud'(False,Filsb); 
                     Insertion(File,P1+P2,A3);
                else
                Non_Vide:=False;
                A:=A1;
                end if;
                end;
                end loop;
		return A; 
	end Calcul_Arbre;

	function Calcul_Dictionnaire(A : Arbre) return Dico is
		D : Dico;
                L : Liste_ChiffreBinaire := Liste_Vide ;
                procedure calculbis(A: in Arbre;L: in out Liste_ChiffreBinaire;D: in out Dico) is
                e: ChiffreBinaire;
                begin
                if(not A.EstFeuille) then
                       Insertion_Queue(0,L);
                       calculbis(A.Fils(0),L,D);
                       Supprime_Queue(e,L);
                       Insertion_Queue(1,L);
                       calculbis(A.Fils(1),L,D);
                       Supprime_Queue(e,L);
                else
                        declare
                        C:Code := new TabBits(1..Taille(L));
                        Lbis:Liste_ChiffreBinaire := L;
                        begin
                        for i in 1..Taille(L) loop
                                C.all(i):=(Valeur(Lbis));
                                Lbis:=Suivant(Lbis);
                        end loop;
                        D(A.Char) := C;
                        end; 
                        end if;
                end calculbis;
                begin
                calculbis(A,L,D);
		return D;
	end;

	procedure Decodage_Code(Reste : in out Code;
		Arbre_Huffman : Arbre;
		Caractere : out Character) is

		Position_Courante : Arbre;
		Tmp,R : Natural;
		Nouveau_Reste : Code;
	begin
		Position_Courante := Arbre_Huffman;
		while not Position_Courante.EstFeuille loop
			if Reste = null then
				--chargement de l'octet suivant du fichier
				Reste := new TabBits(1..8);
				Caractere := Octet_Suivant;
				Tmp := Character'Pos(Caractere);
				for I in Reste'Range loop
					R := Tmp mod 2;
					Reste(Reste'Last + Reste'First - I) := R;
					Tmp := Tmp / 2;
				end loop;
			end if;
			Position_Courante := Position_Courante.Fils(Reste(1)) ;
			if Reste'Last = 1 then
				Liberer(Reste);
				Reste := null;
			else
				-- TODO : modifier cette procedure
				-- pour eviter de faire a chaque iteration
				-- une allocation + 1 liberation
				Nouveau_Reste := new TabBits(1..(Reste'Last - 1));
				for I in Nouveau_Reste'Range loop
					Nouveau_Reste(I) := Reste(I+1);
				end loop;
				Liberer(Reste);
				Reste := Nouveau_Reste;
			end if;
		end loop;
		Caractere := Position_Courante.Char;
	end;

        procedure Put(C:in Code) is
        A: Integer:=0;
        begin
                for i in C.all'first..C.all'last loop
                        A:=A*10+C.all(i); 
                end loop;
                Put(A);
        end;
end;
