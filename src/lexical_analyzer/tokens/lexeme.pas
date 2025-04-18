unit lexeme;

uses
    type_token;

interface

type 
    lexeme = record
        lex_text: string;
        token_real: type_token;
        line: integer;
        column: integer;
    end;

function createLexeme(lex_text: string; token_real: type_token; line, column: integer): lexeme;

implementation

function createLexeme(lex_text: string; token_real: type_token; line, column: integer): lexeme;

begin
    Result.lex_text := lex_text;
    Result.token_real := token_real;
    Result.line := line;
    Result.column := column;
end;

end.