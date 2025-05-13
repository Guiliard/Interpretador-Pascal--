unit syntax_utils_unit;

interface 

uses
    type_token_unit,
    lexeme_unit;

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
    if (currentLexeme.token_real = type_token_unit._INVALID_TOKEN_) then
    begin
        writeln('Error: Invalid token at line ', currentLexeme.line, ', column ', currentLexeme.column, ', Token: ', currentLexeme.lex_text, '.', #10);
    end

    else
    if (currentLexeme.token_real = type_token_unit._END_OF_FILE_) then
    begin
        writeln('Error: Unexpected end of file.', #10);
    end
    
    else
    begin
        writeln('Error: Unexpected token at line ', currentLexeme.line, ', column ', currentLexeme.column, ', Token: ', currentLexeme.lex_text, '.', #10);
    end;
end;

end.