unit lexeme;

uses
    table_token;

interface

type 
    lexeme = record
        lex_text: string;
        token_real: table_token;
        line: integer;
        column: integer;
    end;

implementation

end.