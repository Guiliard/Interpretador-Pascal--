unit syntax_analyzer_unit;

interface

uses 
    proc_unit,
    lexeme_unit,
    intermediate_code_unit,
    intermediate_utils_unit;

function syntaxAnalyzer(lexemes: lexeme_array): arrayCode;

implementation

function syntaxAnalyzer(lexemes: lexeme_array): arrayCode;

var 
    i: integer;
    code: arrayCode;

begin
    i := 0;
    code := procMain(lexemes, i);
    Exit(code);
end;

end.
