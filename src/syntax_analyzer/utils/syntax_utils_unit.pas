unit syntax_utils_unit;

interface 

uses
    type_token_unit,
    lexeme_unit;

procedure advanceToken(lexemes: lexeme_array; var i: integer);
procedure showError(currentLexeme: lexeme);
procedure eatToken(lexemes: lexeme_array; var i: integer; token: typeToken);

implementation

procedure advanceToken(lexemes: lexeme_array; var i: integer);
begin 
    if (i <= High(lexemes)) then
    begin
        Inc(i);
    end;
end;

procedure eatToken(lexemes: lexeme_array; var i: integer; token: typeToken);
begin 
    if (lexemes[i].token_real <> token) then
    begin 
        showError(lexemes[i]);
        Halt(1);
    end;
    advanceToken(lexemes, i)
end;

procedure showError(currentLexeme: lexeme);
begin 
    writeln(#10, 'Syntax Error: Unexpected token at line ', currentLexeme.line, ', column ', currentLexeme.column, '. The token: "', currentLexeme.lex_text, '" is not appropriate.', #10);
end;

end.