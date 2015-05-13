with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
package body Liste is

procedure Insertion_Tete(X: in Element; L: in out Liste) is
Courant: Liste;
begin
if TeteLibre /= null then
TeteLibre.Val := X;
Courant := TeteLibre.Suiv;
TeteLibre.Suiv := L;
L := TeteLibre;
TeteLibre := Courant;
else
L := new Cellule'(X,L);
end if;
end Insertion_Tete;


procedure Supprime_Tete(X: out Element; L: in out Liste) is
Courant: Liste;
begin
--if L /= null then
X := L.Val;
Courant := L;
L := L.Suiv;
Courant.Suiv := TeteLibre;
TeteLibre := Courant;
--else
--raise Erreur_Liste_Vide;
--end if;
end;
procedure Vider_Liste(L: in out Liste) is
X: Element;
begin
while L /= null loop
Supprime_Tete(X,L);
end loop;
end;

function Liste_Vide return Liste is
L:Liste;
begin
L:=null;
return L;
end;

procedure Insertion_Queue(X: in Element; L: in out Liste) is
        A: Liste := L;
        B: Liste := L;
        begin
                while (A /= null) loop
                    B := A;
                    A := A.Suiv;
                        end loop;
                A := new Cellule'(X,null);
                if (B /= null) then
                B.Suiv := A;
                else
                L := A;
  end if;
  end;


function Existe_Liste(X: in Element; L: in Liste) return boolean is
begin
if L /= null then
return (X=L.Val) or else (Existe_Liste(X,L.Suiv));
else
return false;
end if;
end;

function Taille(L: Liste) return Natural is
     begin
     if (L = null) then
                return 0;
        else
                return (1 + Taille(L.Suiv));
     end if;
     end;

procedure Tri(L:in out Liste) is
A: Liste := L ;
E: Element ;
begin
        if (L/=null) then
        E := L.Val;
        while (A /= null) loop
                if (A.Val < E) then
                        E := A.Val;
                end if;
                A := A.Suiv;
        end loop;
        Supprimer(L,E);
        Insertion_Tete(E,L);
        Tri(L.Suiv);
        else
        null;
        end if;
end;
procedure Supprimer(L: in out Liste; X: in Element) is
A : Liste := L;
B : Liste := L;
begin
        if (A.Val = X) then
                L := L.Suiv;
                else
        While (A /= null) loop
        
        if (A.Val = X) then 
                B.Suiv := A.Suiv;
        end if;
        B := A;
        A := A.Suiv;
        end loop;
        end if;
end;

function Suivant(L: Liste) return Liste is
begin
return L.Suiv;
exception
when others => raise Erreur_Liste_Vide;
end Suivant;

function Est_Vide(L: Liste) return boolean is
begin
        return (Taille(L)=0) ;
end;

function Valeur(L: Liste) return element is
begin
return L.Val;
--exception
--when others => raise Erreur_Liste_Vide;
end Valeur;

procedure copie(A: in Liste; B: out Liste) is
C :Liste := A.Suiv;
begin
B := new Cellule'(A.Val,null);
while C /= null loop
Insertion_Queue(C.Val,B);
C := C.Suiv;
end loop;
end copie;
procedure put(A: in Liste) is
begin
if (A /= null) then
        Put(A.Val);
        Put(A.Suiv);
end if;
end;

procedure Supprime_Queue(X: out Element; L: in out Liste) is
A: Liste := L.Suiv;
B: Liste := L;
begin
        if L.Suiv /= Liste_Vide then
        while A.Suiv/=Liste_Vide loop
                A := A.Suiv;
                B := B.Suiv;
                end loop;
        B.Suiv := null;
        X := A.Val;
        A.Suiv := TeteLibre;
        TeteLibre := A;
        else
        X := L.Val;
        L.Suiv := TeteLibre;
        TeteLibre := L;
        L := null;
        end if;
        end;

end Liste;
