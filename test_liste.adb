with liste;
with Ada.Integer_Text_IO,Ada.Text_IO;
use Ada.Integer_Text_IO,Ada.Text_IO;

procedure test_liste is 
procedure Pute(A: in Integer) is
begin
Put(A);
end Pute;

Package Package_Liste_Integer is new Liste(Integer,"<",Pute);
type Liste_Integer is new Package_Liste_Integer.Liste;
use Package_Liste_Integer;
L: Liste_Integer;
X:Integer;

begin
Insertion_Tete(1,L);
Insertion_Tete(2,L);
Insertion_Tete(3,L);
Insertion_Queue(4,L);
Put(L);
New_Line;
Supprime_Queue(X,L);
Put(L);
Put(Taille(L));
end;
