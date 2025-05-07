unit syntax_analyzer_unit;

interface

uses 
    proc_unit,
    lexeme_unit;

procedure syntaxAnalyzer(lexemes: lexeme_array);

implementation

procedure syntaxAnalyzer(lexemes: lexeme_array);

var 
    i: integer;

begin
    i := 0;
    procMain(lexemes, i);
end;

end.
