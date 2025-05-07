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

procedure procDeclarations(lexemes: lexeme_array; var i: integer);
begin
    eatToken(lexemes, i, type_token_unit._VAR_);
    procDeclaration(lexemes, i);
    procRestDeclaration(lexemes, i);
end;

procedure procDeclaration(lexemes: lexeme_array; var i: integer);
begin
    procListIdent(lexemes, i);
    eatToken(lexemes, i, type_token_unit._COLON_); 
    procType(lexemes, i);
    eatToken(lexemes, i, type_token_unit._SEMICOLON_);
end;

procedure procListIdent(lexemes: lexeme_array; var i: integer);
begin
    eatToken(lexemes, i, type_token_unit._VARIABLE_);
    procRestListIdent(lexemes, i);
end;

procedure procRestListIdent(lexemes: lexeme_array; var i: integer);
begin
    if lexemes[i].token_real = type_token_unit._COMMA_ then
    begin
        eatToken(lexemes, i, type_token_unit._COMMA_);    
        eatToken(lexemes, i, type_token_unit._VARIABLE_); 
        procRestListIdent(lexemes, i);                    
    end;
end;

procedure procRestDeclaration(lexemes: lexeme_array; var i: integer);
begin
    if lexemes[i].token_real = type_token_unit._VARIABLE_ then
    begin
        procDeclaration(lexemes, i);   
        procRestDeclaration(lexemes, i);
    end;
end;

procedure procType(lexemes: lexeme_array; var i: integer);
const 
    typeSet: set of type_token_unit = [type_token_unit._INTEGER_, type_token_unit._REAL_, type_token_unit._STRING_];
begin
    if lexemes[i].token_real in typeSet then
    begin
        eatToken(lexemes, i, lexemes[i].token_real);
    end;
end;