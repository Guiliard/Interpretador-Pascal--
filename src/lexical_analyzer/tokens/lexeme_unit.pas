unit lexeme_unit;

interface

uses
    type_token_unit;

type 
    lexeme = record
        lex_text: string;
        token_real: typeToken;
        line: integer;
        column: integer;
    end;

    lexeme_array = array of lexeme;

function createLexeme(lex_text: string; token_real: typeToken; line, column: integer): lexeme;

implementation

function createLexeme(lex_text: string; token_real: typeToken; line, column: integer): lexeme;

begin
    createLexeme.lex_text := lex_text;
    createLexeme.token_real := token_real;
    createLexeme.line := line;
    createLexeme.column := column;
end;

end.