unit proc_unit;

interface

uses 
    syntax_utils_unit,
    lexeme_unit, 
    type_token_unit;

procedure procMain(lexemes: lexeme_array; var i: integer);

implementation

procedure procMain(lexemes: lexeme_array; var i: integer);
begin
    eatToken(lexemes, i, type_token_unit._PROGRAM_);
    eatToken(lexemes, i, type_token_unit._VARIABLE_);
    eatToken(lexemes, i, type_token_unit._SEMICOLON_);
    procDeclarations(lexemes, i);
    eatToken(lexemes, i, type_token_unit._BEGIN_);
    procStmtList(lexemes, i);
    eatToken(lexemes, i, type_token_unit._END_);
    eatToken(lexemes, i, type_token_unit._DOT_);
end;

end.