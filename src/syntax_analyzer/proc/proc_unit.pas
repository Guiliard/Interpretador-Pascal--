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

procedure procStmtList(lexemes: lexeme_array; var i: integer);
const
    stmtSet: set of type_token_unit = [
    type_token_unit._FOR_, type_token_unit._READ_, type_token_unit._WRITE_,
    type_token_unit._READLN_, type_token_unit._WRITELN_, type_token_unit._WHILE_,
    type_token_unit._VARIABLE_, type_token_unit._IF_, type_token_unit._BEGIN_,
    type_token_unit._BREAK_, type_token_unit._CONTINUE_, type_token_unit._SEMICOLON_];
begin
    if lexemes[i].token_real in stmtSet then
    begin
        procStmt(lexemes, i);   
        procStmtList(lexemes, i);
    end;
end;

procedure procStmt(lexemes: lexeme_array; var i: integer);
begin
    if lexemes[i].token_real = type_token_unit._FOR_ then
    begin
        procForStmt(lexemes, i);
    end
    else if lexemes[i].token_real in [type_token_unit._READ_, type_token_unit._WRITE_, type_token_unit._READLN_, type_token_unit._WRITELN_] then
    begin
        procIoStmt(lexemes, i);
    end
    else if lexemes[i].token_real = type_token_unit._WHILE_ then
    begin
        procWhileStmt(lexemes, i);
    end
    else if lexemes[i].token_real = type_token_unit._VARIABLE_ then
    begin
        procAtrib(lexemes, i);
    end
    else if lexemes[i].token_real = type_token_unit._IF_ then
    begin
        procIfStmt(lexemes, i);
    end
    else if lexemes[i].token_real = type_token_unit._BEGIN_ then
    begin
        procBlock(lexemes, i);
    end
    else if lexemes[i].token_real = type_token_unit._BREAK_ then
    begin
        eatToken(lexemes, i, type_token_unit._BREAK_);
        eatToken(lexemes, i, type_token_unit._SEMICOLON_);
    end
    else if lexemes[i].token_real = type_token_unit._CONTINUE_ then
    begin
        eatToken(lexemes, i, type_token_unit._CONTINUE_);
        eatToken(lexemes, i, type_token_unit._SEMICOLON_);
    end
    else if lexemes[i].token_real = type_token_unit._SEMICOLON_ then
    begin
        eatToken(lexemes, i, type_token_unit._SEMICOLON_);
    end
end;