unit proc_unit;

interface

uses 
    syntax_utils_unit,
    lexeme_unit, 
    type_token_unit;

procedure procMain(lexemes: lexeme_array; var i: integer);
procedure procDeclarations(lexemes: lexeme_array; var i: integer); 
procedure procStmtList(lexemes: lexeme_array; var i: integer);
procedure procDeclaration(lexemes: lexeme_array; var i: integer);
procedure procRestDeclaration(lexemes: lexeme_array; var i: integer);
procedure procListIdent(lexemes: lexeme_array; var i: integer);
procedure procType(lexemes: lexeme_array; var i: integer);
procedure procRestListIdent(lexemes: lexeme_array; var i: integer);
procedure procStmt(lexemes: lexeme_array; var i: integer);
procedure procForStmt(lexemes: lexeme_array; var i: integer);
procedure procIoStmt(lexemes: lexeme_array; var i: integer);
procedure procWhileStmt(lexemes: lexeme_array; var i: integer);
procedure procAtrib(lexemes: lexeme_array; var i: integer);
procedure procIfStmt(lexemes: lexeme_array; var i: integer);
procedure procEndFor(lexemes: lexeme_array; var i: integer);
procedure procOutList(lexemes: lexeme_array; var i: integer);
procedure procOut(lexemes: lexeme_array; var i: integer);
procedure procRestOutList(lexemes: lexeme_array; var i: integer);
procedure procExpr(lexemes: lexeme_array; var i: integer);
procedure procElsePart(lexemes: lexeme_array; var i: integer);
procedure procOr(lexemes: lexeme_array; var i: integer);
procedure procAnd(lexemes: lexeme_array; var i: integer);
procedure procRestOr(lexemes: lexeme_array; var i: integer);
procedure procNot(lexemes: lexeme_array; var i: integer);
procedure procRestAnd(lexemes: lexeme_array; var i: integer);
procedure procRel(lexemes: lexeme_array; var i: integer);
procedure procAdd(lexemes: lexeme_array; var i: integer);
procedure procRestRel(lexemes: lexeme_array; var i: integer);
procedure procMult(lexemes: lexeme_array; var i: integer);
procedure procRestAdd(lexemes: lexeme_array; var i: integer);
procedure procUno(lexemes: lexeme_array; var i: integer);
procedure procRestMult(lexemes: lexeme_array; var i: integer);
procedure procFactor(lexemes: lexeme_array; var i: integer);

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
    if (High(lexemes) > i) then
    begin 
        writeln(#10, 'Syntax Error: Unexpected tokens after ''end.'' (remaining tokens: ', High(lexemes) - i, ', expected: 0)', #10);
        Halt(1);
    end
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
    typeSet: set of typeToken = [_INTEGER_, _REAL_, _STRING_];
begin
    if lexemes[i].token_real in typeSet then
    begin
        eatToken(lexemes, i, lexemes[i].token_real);
    end;
end;

procedure procBlock(lexemes: lexeme_array; var i: integer);
begin
    eatToken(lexemes, i, type_token_unit._BEGIN_);
    procStmtList(lexemes, i);
    eatToken(lexemes, i, type_token_unit._END_);
    if (lexemes[i].token_real <> type_token_unit._ELSE_) then
        eatToken(lexemes, i, type_token_unit._SEMICOLON_);
end;

procedure procStmtList(lexemes: lexeme_array; var i: integer);
const
    stmtSet: set of typeToken = [_FOR_, _READ_, _WRITE_, _READLN_, _WRITELN_,
    _WHILE_, _VARIABLE_, _IF_, _BEGIN_, _BREAK_, _CONTINUE_, _SEMICOLON_];
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

    else 
    if lexemes[i].token_real in [type_token_unit._READ_, type_token_unit._WRITE_, type_token_unit._READLN_, type_token_unit._WRITELN_] then
    begin
        procIoStmt(lexemes, i);
    end

    else 
    if lexemes[i].token_real = type_token_unit._WHILE_ then
    begin
        procWhileStmt(lexemes, i);
    end

    else 
    if lexemes[i].token_real = type_token_unit._VARIABLE_ then
    begin
        procAtrib(lexemes, i);
        eatToken(lexemes, i, type_token_unit._SEMICOLON_);
    end

    else 
    if lexemes[i].token_real = type_token_unit._IF_ then
    begin
        procIfStmt(lexemes, i);
    end

    else 
    if lexemes[i].token_real = type_token_unit._BEGIN_ then
    begin
        procBlock(lexemes, i);
    end

    else 
    if lexemes[i].token_real = type_token_unit._BREAK_ then
    begin
        eatToken(lexemes, i, type_token_unit._BREAK_);
        eatToken(lexemes, i, type_token_unit._SEMICOLON_);
    end

    else 
    if lexemes[i].token_real = type_token_unit._CONTINUE_ then
    begin
        eatToken(lexemes, i, type_token_unit._CONTINUE_);
        eatToken(lexemes, i, type_token_unit._SEMICOLON_);
    end

    else 
    if lexemes[i].token_real = type_token_unit._SEMICOLON_ then
    begin
        eatToken(lexemes, i, type_token_unit._SEMICOLON_);
    end;
end;

procedure procForStmt(lexemes: lexeme_array; var i: integer);
begin
    eatToken(lexemes, i, type_token_unit._FOR_); 
    procAtrib(lexemes, i);
    eatToken(lexemes, i, type_token_unit._TO_);
    procEndFor(lexemes, i);
    eatToken(lexemes, i, type_token_unit._DO_);
    procStmt(lexemes, i);
end;

procedure procEndFor(lexemes: lexeme_array; var i: integer);
begin
    if lexemes[i].token_real in [type_token_unit._VARIABLE_, type_token_unit._DECIMAL_,
    type_token_unit._HEXADECIMAL_, type_token_unit._OCTAL_] then
    begin
        eatToken(lexemes, i, lexemes[i].token_real);
    end;
end;

procedure procIoStmt(lexemes: lexeme_array; var i: integer);
begin
    if lexemes[i].token_real in [type_token_unit._READ_, type_token_unit._READLN_] then
    begin
        eatToken(lexemes, i, lexemes[i].token_real);
        eatToken(lexemes, i, type_token_unit._LEFT_PAREN_);
        eatToken(lexemes, i, type_token_unit._VARIABLE_);
        eatToken(lexemes, i, type_token_unit._RIGHT_PAREN_);
        eatToken(lexemes, i, type_token_unit._SEMICOLON_);
    end
    else
    if lexemes[i].token_real in [type_token_unit._WRITE_, type_token_unit._WRITELN_] then
    begin
        eatToken(lexemes, i, lexemes[i].token_real);
        eatToken(lexemes, i, type_token_unit._LEFT_PAREN_);
        procOutList(lexemes, i);
        eatToken(lexemes, i, type_token_unit._RIGHT_PAREN_);
        eatToken(lexemes, i, type_token_unit._SEMICOLON_);
    end;
end;

procedure procOutList(lexemes: lexeme_array; var i: integer);
begin
    procOut(lexemes, i);
    procRestOutList(lexemes, i);
end;

procedure procRestOutList(lexemes: lexeme_array; var i: integer);
begin
    if lexemes[i].token_real = type_token_unit._COMMA_ then
    begin
        eatToken(lexemes, i, type_token_unit._COMMA_);
        procOutList(lexemes, i);                    
    end;
end;

procedure procOut(lexemes: lexeme_array; var i: integer);
begin
    if lexemes[i].token_real in [type_token_unit._STRING_LITERAL_, type_token_unit._VARIABLE_, type_token_unit._DECIMAL_, type_token_unit._FLOAT_] then
    begin
        eatToken(lexemes, i, lexemes[i].token_real);
    end;
end;

procedure procWhileStmt(lexemes: lexeme_array; var i: integer);
begin
    eatToken(lexemes, i, type_token_unit._WHILE_);
    procExpr(lexemes, i);
    eatToken(lexemes, i, type_token_unit._DO_);
    procStmt(lexemes, i);
end;

procedure procIfStmt(lexemes: lexeme_array; var i: integer);
begin
    eatToken(lexemes, i, type_token_unit._IF_);
    procExpr(lexemes, i);
    eatToken(lexemes, i, type_token_unit._THEN_);
    procStmt(lexemes, i);
    procElsePart(lexemes, i);
end;

procedure procElsePart(lexemes: lexeme_array; var i: integer);
begin
    if lexemes[i].token_real = type_token_unit._ELSE_ then
    begin
        eatToken(lexemes, i, type_token_unit._ELSE_);
        procStmt(lexemes, i);                  
    end;
end;

procedure procAtrib(lexemes: lexeme_array; var i: integer);
begin
    eatToken(lexemes, i, type_token_unit._VARIABLE_);
    eatToken(lexemes, i, type_token_unit._ASSIGN_);
    procExpr(lexemes, i);
end;

procedure procExpr(lexemes: lexeme_array; var i: integer);
begin
    procOr(lexemes, i);
end;

procedure procOr(lexemes: lexeme_array; var i: integer);
begin
    procAnd(lexemes, i);
    procRestOr(lexemes, i);
end;

procedure procRestOr(lexemes: lexeme_array; var i: integer);
begin
    if lexemes[i].token_real = type_token_unit._OR_ then
    begin
        eatToken(lexemes, i, type_token_unit._OR_);
        procAnd(lexemes, i);
        procRestOr(lexemes, i);
    end;
end;

procedure procAnd(lexemes: lexeme_array; var i: integer);
begin
    procNot(lexemes, i);
    procRestAnd(lexemes, i);
end;

procedure procRestAnd(lexemes: lexeme_array; var i: integer);
begin
    if lexemes[i].token_real = type_token_unit._AND_ then
    begin
        eatToken(lexemes, i, type_token_unit._AND_);
        procNot(lexemes, i);
        procRestAnd(lexemes, i);
    end;
end;

procedure procNot(lexemes: lexeme_array; var i: integer);
begin
    if lexemes[i].token_real = type_token_unit._NOT_ then
    begin
        eatToken(lexemes, i, type_token_unit._NOT_);
        procNot(lexemes, i);
    end
    else
    begin
        procRel(lexemes, i);
    end;
end;

procedure procRel(lexemes: lexeme_array; var i: integer);
begin
    procAdd(lexemes, i);
    procRestRel(lexemes, i);
end;

procedure procRestRel(lexemes: lexeme_array; var i: integer);
begin
    if lexemes[i].token_real = type_token_unit._EQUAL_ then
    begin
        eatToken(lexemes, i, type_token_unit._EQUAL_);
        procAdd(lexemes, i);
    end
    else if lexemes[i].token_real = type_token_unit._NOT_EQUAL_ then
    begin
        eatToken(lexemes, i, type_token_unit._NOT_EQUAL_);
        procAdd(lexemes, i);
    end
    else if lexemes[i].token_real = type_token_unit._LOWER_ then
    begin
        eatToken(lexemes, i, type_token_unit._LOWER_);
        procAdd(lexemes, i);
    end
    else if lexemes[i].token_real = type_token_unit._LOWER_EQUAL_ then
    begin
        eatToken(lexemes, i, type_token_unit._LOWER_EQUAL_);
        procAdd(lexemes, i);
    end
    else if lexemes[i].token_real = type_token_unit._GREATER_ then
    begin
        eatToken(lexemes, i, type_token_unit._GREATER_);
        procAdd(lexemes, i);
    end
    else if lexemes[i].token_real = type_token_unit._GREATER_EQUAL_ then
    begin
        eatToken(lexemes, i, type_token_unit._GREATER_EQUAL_);
        procAdd(lexemes, i);
    end;
end;

procedure procAdd(lexemes: lexeme_array; var i: integer);
begin
    procMult(lexemes, i);
    procRestAdd(lexemes, i);
end;

procedure procRestAdd(lexemes: lexeme_array; var i: integer);
begin
    if lexemes[i].token_real = type_token_unit._ADD_ then
    begin
        eatToken(lexemes, i, type_token_unit._ADD_);
        procMult(lexemes, i);
        procRestAdd(lexemes, i);
    end
    else
    if lexemes[i].token_real = type_token_unit._SUB_ then
    begin
        eatToken(lexemes, i, type_token_unit._SUB_);
        procMult(lexemes, i);
        procRestAdd(lexemes, i);
    end;
end;

procedure procMult(lexemes: lexeme_array; var i: integer);
begin
    procUno(lexemes, i);
    procRestMult(lexemes, i);
end;

procedure procRestMult(lexemes: lexeme_array; var i: integer);
begin
    if lexemes[i].token_real = type_token_unit._MUL_ then
    begin
        eatToken(lexemes, i, type_token_unit._MUL_);
        procUno(lexemes, i);
        procRestMult(lexemes, i);
    end
    else
    if lexemes[i].token_real = type_token_unit._REAL_DIV_ then
    begin
        eatToken(lexemes, i, type_token_unit._REAL_DIV_);
        procUno(lexemes, i);
        procRestMult(lexemes, i);
    end
    else
    if lexemes[i].token_real = type_token_unit._MOD_ then
    begin
        eatToken(lexemes, i, type_token_unit._MOD_);
        procUno(lexemes, i);
        procRestMult(lexemes, i);
    end
    else
    if lexemes[i].token_real = type_token_unit._INTER_DIV_ then
    begin
        eatToken(lexemes, i, type_token_unit._INTER_DIV_);
        procUno(lexemes, i);
        procRestMult(lexemes, i);
    end;
end;

procedure procUno(lexemes: lexeme_array; var i: integer);
begin
    if lexemes[i].token_real in [type_token_unit._ADD_, type_token_unit._SUB_] then
    begin
        eatToken(lexemes, i, lexemes[i].token_real);
        procUno(lexemes, i);
    end
    else
    begin
        procFactor(lexemes, i);
    end;
end;

procedure procFactor(lexemes: lexeme_array; var i: integer);
const
    factorSet: set of typeToken = [_STRING_LITERAL_, _VARIABLE_, _DECIMAL_, _FLOAT_, _HEXADECIMAL_, _OCTAL_];
begin
    if lexemes[i].token_real = type_token_unit._LEFT_PAREN_ then
    begin
        eatToken(lexemes, i, type_token_unit._LEFT_PAREN_);
        procExpr(lexemes, i);
        eatToken(lexemes, i, type_token_unit._RIGHT_PAREN_);
    end
    else
    if lexemes[i].token_real in factorSet then
    begin
        eatToken(lexemes, i, lexemes[i].token_real);
    end;
end;

end.