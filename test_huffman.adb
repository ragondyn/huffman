with arbre_huffman;
use arbre_huffman;

procedure test_huffman is
C : Code;
begin
C := new TabBits(1..3);
C.all(1) := 1;
C.all(2) := 1;
C.all(3) := 0;
Put(C);
end;



