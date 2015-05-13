With Ada.Text_IO;
use Ada.Text_IO;

package body File_Priorite is

   ----------------------------------------------------------------------------------------------------------

   -- Définition des types utilisés

   type Element is record
      D : Donnee;
      P : Priorite;
   end record;

   type Tas is array(Positive range <>) of Element;

   type File_Interne is record
      T : access Tas;
      Top : Natural; -- derniere case remplie du tableau Tas 
   end record;

   ----------------------------------------------------------------------------------------------------------

   function Nouvelle_File(Taille: Positive) return File is
      F: File;
   begin
      F := new File_Interne'(T=>new Tas(1..Taille),Top=>0);
      return F;
   end;

   -- procedure pour reograniser le tas dans le cas où l'élement inséré a une plus grande priorité que son pere: 
   -- echange recursivement l'élement inséré avec son pere

   procedure echanger_insere_pere(I : Natural; F : File) is
      Element_tempo : Element;
   begin
      if I = F.T'First 
      then return; 
      end if;
      if Compare(F.T(I/2).P,F.T(I).P)=SUP then
	 Element_tempo := F.T(I/2); -- on divise l'indice d'un element par 2 pour retrouver l'indice de son pere
	 F.T(I/2) := F.T(I);
	 F.T(I) := Element_tempo;
	 echanger_insere_pere(I/2,F);
      end if;
   end;


   procedure Insertion(F: in out File; P: Priorite; D: Donnee) is

   begin
      F.Top := F.Top + 1; -- +1 pour le fils de droite
      F.T(F.Top) := (P=>P,D=>D);
      Echanger_insere_pere(F.Top,F); 
   end;

   procedure Meilleur(F: in File; P: out Priorite; D: out Donnee; Statut: out Boolean) is
   begin
      if F.Top = 0 then
	 Statut := False;
      else
	 P := F.T(F.T'First).P;
	 D := F.T(F.T'First).D;
	 Statut := True;
      end if;
   end;
   
   -- procedure pour réorganiser le tas aprés avoir remplacer la racine: échange recursivement
   -- l'element d'indice I avec le fils de plus grande priorité

   procedure echanger_insere_plus_grand_fils(I : Natural; F : File) is
      Element_tempo : Element;
      Fils : Positive; -- indice du plus grand fils
   begin
      if 2*I > F.Top then
	 return ;         -- arret quand l'element n'a pas de fils
      elsif 2*I+1 > F.Top or else Compare(F.T(2*I).P,F.T(2*I+1).P)=INF then
	 Fils := 2*I;     -- cas 1: F.T(I) n'a pas de fils droit ou si la priorite du fils gauche est plus grande
      else
	 Fils := 2*I+1;   -- cas 2: la priorite du fils droit est plus grande
      end if;

      if Compare(F.T(I).P,F.T(Fils).P)=SUP then
	 Element_tempo := F.T(I);
	 F.T(I) := F.T(Fils);
	 F.T(Fils) := Element_tempo;
	 echanger_insere_plus_grand_fils(Fils,F); 
      end if;
   end;


   procedure Suppression(F: in out File) is

   begin
      -- cas où la file serait vide
      if F.Top = 0 
      then return; 
      end if;
      F.T(F.T'First) := F.T(F.Top);
      F.Top := F.Top - 1;
      echanger_insere_plus_grand_fils(F.T'First,F);
   end;

   
   
end ;
