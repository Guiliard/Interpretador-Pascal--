unit syntax_analyzer_unit;

interface

uses 
    proc_unit,
    lexeme_unit, 
    intermediate_code_unit;

function syntaxAnalyzer(lexemes: lexeme_array): intermediate_code_array;

implementation

function syntaxAnalyzer(lexemes: lexeme_array): intermediate_code_array;

var 
    i: integer;

begin
    i := 0;
    Exit(procMain(lexemes, i));
end;

end.
