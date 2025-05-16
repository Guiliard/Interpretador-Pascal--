unit syntax_utils_unit;

interface 

uses
    type_token_unit,
    lexeme_unit;

procedure advanceToken(var i: integer);
procedure showErrorSyntax(currentLexeme: lexeme; token: typeToken);
procedure eatToken(lexemes: lexeme_array; var i: integer; token: typeToken);

implementation

procedure advanceToken(var i: integer);
begin 
    Inc(i);
end;

procedure eatToken(lexemes: lexeme_array; var i: integer; token: typeToken);
begin 
    if (i = High(lexemes)) then
    begin
        writeln(#10, 'Syntax Error: Unexpected end of file at line ', lexemes[i-1].line, '.', #10);
        Halt(1);
    end 
    else 
    if (lexemes[i].token_real <> token) then
    begin 
        showErrorSyntax(lexemes[i], token);
        Halt(1);
    end;
    advanceToken(i)
end;

procedure showErrorSyntax(currentLexeme: lexeme; token: typeToken);
begin 
    writeln(#10, 'Syntax Error: Unexpected token at line ', currentLexeme.line, ', column ', currentLexeme.column, '. The token: "', currentLexeme.lex_text, '" is not appropriate.');
    writeln('The token: "', currentLexeme.lex_text, '" is a ', currentLexeme.token_real, ' type.', ' It should be a ', token, ' type.', #10);
end;

end.