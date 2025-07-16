unit proc_unit;

interface

uses 
    syntax_utils_unit,
    lexeme_unit, 
    type_token_unit,
    intermediate_code_unit,
    intermediate_utils_unit;

function procMain(lexemes: lexeme_array; var i: integer): intermediate_code_array;
procedure procDeclarations(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array); 
procedure procStmtList(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
procedure procDeclaration(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
procedure procRestDeclaration(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
procedure procListIdent(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
procedure procType(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
procedure procRestListIdent(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
procedure procStmt(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
procedure procForStmt(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
procedure procIoStmt(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
procedure procWhileStmt(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
procedure procAtrib(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
procedure procIfStmt(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
procedure procEndFor(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
procedure procOutList(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
procedure procOut(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
procedure procRestOutList(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
procedure procExpr(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
procedure procElsePart(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
procedure procOr(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
function procAnd(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array): string;
procedure procRestOr(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array; token: string);
function procNot(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array): string;
procedure procRestAnd(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array; token: string);
function procRel(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array): string;
function procAdd(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array): string;
procedure procRestRel(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array; token: string);
function procMult(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array): string;
procedure procRestAdd(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array; token: string);
function procUno(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array): string;
procedure procRestMult(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array; token: string);
function procFactor(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array): string;

implementation

var
    flagAttVar: Integer = 0;
    flagNewTemp: Integer = 0;
    exprArrayCode: intermediate_code_array;

function procMain(lexemes: lexeme_array; var i: integer): intermediate_code_array;
var 
    arrayCode: intermediate_code_array;
begin
    eatToken(lexemes, i, type_token_unit._PROGRAM_);
    eatToken(lexemes, i, type_token_unit._VARIABLE_);
    eatToken(lexemes, i, type_token_unit._SEMICOLON_);
    procDeclarations(lexemes, i, arrayCode);
    eatToken(lexemes, i, type_token_unit._BEGIN_);
    procStmtList(lexemes, i, arrayCode);
    eatToken(lexemes, i, type_token_unit._END_);
    eatToken(lexemes, i, type_token_unit._DOT_);
    if (High(lexemes) > i) then
    begin 
        writeln(#10, 'Syntax Error: Unexpected tokens after ''end.'' (remaining tokens: ', High(lexemes) - i, ', expected: 0)', #10);
        Halt(1);
    end;
    Exit(arrayCode);
end;

procedure procDeclarations(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
begin
    eatToken(lexemes, i, type_token_unit._VAR_);
    procDeclaration(lexemes, i, arrayCode);
    procRestDeclaration(lexemes, i, arrayCode);
end;

procedure procDeclaration(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
begin
    procListIdent(lexemes, i, arrayCode);
    eatToken(lexemes, i, type_token_unit._COLON_); 
    procType(lexemes, i, arrayCode);
    eatToken(lexemes, i, type_token_unit._SEMICOLON_);
end;

procedure procListIdent(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
var 
    code: intermediate_code;
begin
    eatToken(lexemes, i, type_token_unit._VARIABLE_);
    code := genATT(lexemes[i-1].lex_text, '');
    addIntermediateCode(arrayCode, code);
    procRestListIdent(lexemes, i, arrayCode);
end;

procedure procRestListIdent(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
var
    code: intermediate_code;
begin
    if lexemes[i].token_real = type_token_unit._COMMA_ then
    begin
        eatToken(lexemes, i, type_token_unit._COMMA_);    
        eatToken(lexemes, i, type_token_unit._VARIABLE_); 
        code := genATT(lexemes[i-1].lex_text, '');
        addIntermediateCode(arrayCode, code);
        procRestListIdent(lexemes, i, arrayCode);                    
    end;
end;

procedure procRestDeclaration(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
begin
    if lexemes[i].token_real = type_token_unit._VARIABLE_ then
    begin
        procDeclaration(lexemes, i, arrayCode);   
        procRestDeclaration(lexemes, i, arrayCode);
    end;
end;

procedure procType(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
const 
    typeSet: set of typeToken = [_INTEGER_, _REAL_, _STRING_];
var
    idx: Integer;
begin
    if lexemes[i].token_real in typeSet then
    begin
        eatToken(lexemes, i, lexemes[i].token_real);
        for idx := flagAttVar to High(arrayCode) do
        begin
            if (lexemes[i-1].token_real = _INTEGER_) then
            begin
                updateIntermediateCode(arrayCode, flagAttVar, '0','INTEGER');
                flagAttVar := idx + 1;
            end

            else 
            if (lexemes[i-1].token_real = _REAL_) then
            begin
                updateIntermediateCode(arrayCode, flagAttVar, '0.0','REAL');
                flagAttVar := idx + 1;
            end

            else 
            if (lexemes[i-1].token_real = _STRING_) then
            begin
                updateIntermediateCode(arrayCode, flagAttVar, '""','STRING');
                flagAttVar := idx + 1;
            end
        end
    end
    else
    begin
        writeln(#10, 'Syntax Error: Unexpected token at line ', lexemes[i].line, ', column ', lexemes[i].column, '. The token: "', lexemes[i].lex_text, '" is not appropriate.');
        writeln('The token: "', lexemes[i].lex_text, '" is a ', lexemes[i].token_real, ' type.', ' It should be a _INTEGER_, _REAL_ or _STRING_ type.', #10);
        Halt(1);
    end;
end;

procedure procBlock(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
begin
    eatToken(lexemes, i, type_token_unit._BEGIN_);
    procStmtList(lexemes, i, arrayCode);
    eatToken(lexemes, i, type_token_unit._END_);
    if (lexemes[i].token_real <> type_token_unit._ELSE_) then
        eatToken(lexemes, i, type_token_unit._SEMICOLON_);
end;

procedure procStmtList(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
const
    stmtSet: set of typeToken = [_FOR_, _READ_, _WRITE_, _READLN_, _WRITELN_,
    _WHILE_, _VARIABLE_, _IF_, _BEGIN_, _BREAK_, _CONTINUE_, _SEMICOLON_];
begin
    if lexemes[i].token_real in stmtSet then
    begin
        procStmt(lexemes, i, arrayCode);   
        procStmtList(lexemes, i, arrayCode);
    end;
end;

procedure procStmt(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
begin
    if lexemes[i].token_real = type_token_unit._FOR_ then
    begin
        procForStmt(lexemes, i, arrayCode);
    end

    else 
    if lexemes[i].token_real in [type_token_unit._READ_, type_token_unit._WRITE_, type_token_unit._READLN_, type_token_unit._WRITELN_] then
    begin
        procIoStmt(lexemes, i, arrayCode);
    end

    else 
    if lexemes[i].token_real = type_token_unit._WHILE_ then
    begin
        procWhileStmt(lexemes, i, arrayCode);
    end

    else 
    if lexemes[i].token_real = type_token_unit._VARIABLE_ then
    begin
        procAtrib(lexemes, i, arrayCode);
        eatToken(lexemes, i, type_token_unit._SEMICOLON_);
    end

    else 
    if lexemes[i].token_real = type_token_unit._IF_ then
    begin
        procIfStmt(lexemes, i, arrayCode);
    end

    else 
    if lexemes[i].token_real = type_token_unit._BEGIN_ then
    begin
        procBlock(lexemes, i, arrayCode);
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

procedure procForStmt(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
begin
    eatToken(lexemes, i, type_token_unit._FOR_);
    procAtrib(lexemes, i, arrayCode);
    eatToken(lexemes, i, type_token_unit._TO_);
    procEndFor(lexemes, i, arrayCode);
    eatToken(lexemes, i, type_token_unit._DO_);
    procStmt(lexemes, i, arrayCode);
end;

procedure procEndFor(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
begin
    if lexemes[i].token_real in [type_token_unit._VARIABLE_, type_token_unit._DECIMAL_,
    type_token_unit._HEXADECIMAL_, type_token_unit._OCTAL_] then
    begin
        eatToken(lexemes, i, lexemes[i].token_real);
    end;
end;

procedure procIoStmt(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
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
        procOutList(lexemes, i, arrayCode);
        eatToken(lexemes, i, type_token_unit._RIGHT_PAREN_);
        eatToken(lexemes, i, type_token_unit._SEMICOLON_);
    end;
end;

procedure procOutList(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
begin
    procOut(lexemes, i, arrayCode);
    procRestOutList(lexemes, i, arrayCode);
end;

procedure procRestOutList(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
var 
    code: intermediate_code;
begin
    if lexemes[i].token_real = type_token_unit._COMMA_ then
    begin
        eatToken(lexemes, i, type_token_unit._COMMA_);
        procOutList(lexemes, i, arrayCode);                    
    end;
end;

procedure procOut(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
begin
    if lexemes[i].token_real in [type_token_unit._STRING_LITERAL_, type_token_unit._VARIABLE_, type_token_unit._DECIMAL_, type_token_unit._FLOAT_] then
    begin
        eatToken(lexemes, i, lexemes[i].token_real);
    end;
end;

procedure procWhileStmt(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
begin
    eatToken(lexemes, i, type_token_unit._WHILE_);
    procExpr(lexemes, i, arrayCode);
    eatToken(lexemes, i, type_token_unit._DO_);
    procStmt(lexemes, i, arrayCode);
end;

procedure procIfStmt(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
begin
    eatToken(lexemes, i, type_token_unit._IF_);
    procExpr(lexemes, i, arrayCode);
    eatToken(lexemes, i, type_token_unit._THEN_);
    procStmt(lexemes, i, arrayCode);
    procElsePart(lexemes, i, arrayCode);
end;

procedure procElsePart(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
begin
    if lexemes[i].token_real = type_token_unit._ELSE_ then
    begin
        eatToken(lexemes, i, type_token_unit._ELSE_);
        procStmt(lexemes, i, arrayCode);                  
    end;
end;

procedure procAtrib(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
var
    code: intermediate_code;
begin
    eatToken(lexemes, i, type_token_unit._VARIABLE_);
    eatToken(lexemes, i, type_token_unit._ASSIGN_);
    procExpr(lexemes, i, arrayCode);
    code := genATT(lexemes[i-2].lex_text, 'VALOR DO PROCEXPR');
end;

procedure procExpr(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
begin
    procOr(lexemes, i, arrayCode);
end;

procedure procOr(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array);
var 
    token: string;
begin
    token := procAnd(lexemes, i, arrayCode);
    procRestOr(lexemes, i, arrayCode, token);
end;

procedure procRestOr(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array; token: string);
var 
    code: intermediate_code;
    otherToken: string;
begin
    if lexemes[i].token_real = type_token_unit._OR_ then
    begin
        eatToken(lexemes, i, type_token_unit._OR_);
        otherToken := procAnd(lexemes, i, arrayCode);
        code := genOR(genNewTemp(flagNewTemp), token, otherToken);
        addIntermediateCode(arrayCode, code);
        procRestOr(lexemes, i, arrayCode, token);
    end;
end;

function procAnd(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array): string;
var 
    token: string;
begin
    token := procNot(lexemes, i, arrayCode);
    procRestAnd(lexemes, i, arrayCode, token);
    Exit(token);
end;

procedure procRestAnd(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array; token: string);
var
    code: intermediate_code;
    otherToken: string;
begin
    if lexemes[i].token_real = type_token_unit._AND_ then
    begin
        eatToken(lexemes, i, type_token_unit._AND_);
        otherToken := procNot(lexemes, i, arrayCode);
        code := genAND(genNewTemp(flagNewTemp), token, otherToken);
        addIntermediateCode(arrayCode, code);
        procRestAnd(lexemes, i, arrayCode, token);
    end;
end;

function procNot(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array): string;
var 
    token: string;
begin
    if lexemes[i].token_real = type_token_unit._NOT_ then
    begin
        eatToken(lexemes, i, type_token_unit._NOT_);
        procNot(lexemes, i, arrayCode);
    end

    else
    begin
        token := procRel(lexemes, i, arrayCode);
        Exit(token);
    end;
end;

function procRel(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array): string;
var 
    token: string;
begin
    token := procAdd(lexemes, i, arrayCode);
    procRestRel(lexemes, i, arrayCode, token);
    Exit(token);
end;

procedure procRestRel(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array; token: string);
var 
    code: intermediate_code;
    otherToken: string;
begin
    if lexemes[i].token_real = type_token_unit._EQUAL_ then
    begin
        eatToken(lexemes, i, type_token_unit._EQUAL_);
        otherToken := procAdd(lexemes, i, arrayCode);
        code := genEQ(genNewTemp(flagNewTemp), token, otherToken);
        addIntermediateCode(arrayCode, code);
    end

    else 
    if lexemes[i].token_real = type_token_unit._NOT_EQUAL_ then
    begin
        eatToken(lexemes, i, type_token_unit._NOT_EQUAL_);
        otherToken := procAdd(lexemes, i, arrayCode);
        code := genNEQ(genNewTemp(flagNewTemp), token, otherToken);
        addIntermediateCode(arrayCode, code);
    end

    else 
    if lexemes[i].token_real = type_token_unit._LOWER_ then
    begin
        eatToken(lexemes, i, type_token_unit._LOWER_);
        otherToken := procAdd(lexemes, i, arrayCode);
        code := genLESS(genNewTemp(flagNewTemp), token, otherToken);
        addIntermediateCode(arrayCode, code);
    end

    else if lexemes[i].token_real = type_token_unit._LOWER_EQUAL_ then
    begin
        eatToken(lexemes, i, type_token_unit._LOWER_EQUAL_);
        otherToken := procAdd(lexemes, i, arrayCode);
        code := genLEQ(genNewTemp(flagNewTemp), token, otherToken);
        addIntermediateCode(arrayCode, code);
    end
    else if lexemes[i].token_real = type_token_unit._GREATER_ then
    begin
        eatToken(lexemes, i, type_token_unit._GREATER_);
        otherToken := procAdd(lexemes, i, arrayCode);
        code := genGRET(genNewTemp(flagNewTemp), token, otherToken);
        addIntermediateCode(arrayCode, code);
    end
    else if lexemes[i].token_real = type_token_unit._GREATER_EQUAL_ then
    begin
        eatToken(lexemes, i, type_token_unit._GREATER_EQUAL_);
        otherToken := procAdd(lexemes, i, arrayCode);
        code := genGEQ(genNewTemp(flagNewTemp), token, otherToken);
        addIntermediateCode(arrayCode, code);
    end;
end;

function procAdd(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array): string;
var 
    token: string;
begin
    token := procMult(lexemes, i, arrayCode);
    procRestAdd(lexemes, i, arrayCode, token);
    Exit(token);
end;

procedure procRestAdd(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array; token: string);
var 
    code: intermediate_code;
    otherToken: string;
begin
    if lexemes[i].token_real = type_token_unit._ADD_ then
    begin
        eatToken(lexemes, i, type_token_unit._ADD_);
        otherToken := procMult(lexemes, i, arrayCode);
        code := genADD(genNewTemp(flagNewTemp), token, otherToken);
        addIntermediateCode(arrayCode, code);
        procRestAdd(lexemes, i, arrayCode, token);
    end
    else
    if lexemes[i].token_real = type_token_unit._SUB_ then
    begin
        eatToken(lexemes, i, type_token_unit._SUB_);
        otherToken := procMult(lexemes, i, arrayCode);
        code := genSUB(genNewTemp(flagNewTemp), token, otherToken);
        addIntermediateCode(arrayCode, code);
        procRestAdd(lexemes, i, arrayCode, token);
    end;
end;

function procMult(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array): string;
var 
    token: string;
begin
    token := procUno(lexemes, i, arrayCode);
    procRestMult(lexemes, i, arrayCode, token);
    Exit(token);
end;

procedure procRestMult(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array; token: string);
var 
    code: intermediate_code;
    otherToken: string;
begin
    if lexemes[i].token_real = type_token_unit._MUL_ then
    begin
        eatToken(lexemes, i, type_token_unit._MUL_);
        otherToken := procUno(lexemes, i, arrayCode);
        code := genMULT(genNewTemp(flagNewTemp), token, otherToken);
        addIntermediateCode(arrayCode, code);
        procRestMult(lexemes, i, arrayCode, token);
    end
    else
    if lexemes[i].token_real = type_token_unit._REAL_DIV_ then
    begin
        eatToken(lexemes, i, type_token_unit._REAL_DIV_);
        otherToken := procUno(lexemes, i, arrayCode);
        code := genRDIV(genNewTemp(flagNewTemp), token, otherToken);
        addIntermediateCode(arrayCode, code);
        procRestMult(lexemes, i, arrayCode, token);
    end
    else
    if lexemes[i].token_real = type_token_unit._MOD_ then
    begin
        eatToken(lexemes, i, type_token_unit._MOD_);
        otherToken := procUno(lexemes, i, arrayCode);
        code := genMOD(genNewTemp(flagNewTemp), token, otherToken);
        addIntermediateCode(arrayCode, code);
        procRestMult(lexemes, i, arrayCode, token);
    end
    else
    if lexemes[i].token_real = type_token_unit._INTER_DIV_ then
    begin
        eatToken(lexemes, i, type_token_unit._INTER_DIV_);
        otherToken := procUno(lexemes, i, arrayCode);
        code := genIDIV(genNewTemp(flagNewTemp), token, otherToken);
        addIntermediateCode(arrayCode, code);
        procRestMult(lexemes, i, arrayCode, token);
    end;
end;

function procUno(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array): string;
var
    token: string;
begin
    if lexemes[i].token_real in [type_token_unit._ADD_, type_token_unit._SUB_] then
    begin
        eatToken(lexemes, i, lexemes[i].token_real);
        procUno(lexemes, i, arrayCode);
    end
    else
    begin
        token := procFactor(lexemes, i, arrayCode);
    end;
    Exit(token);
end;

function procFactor(lexemes: lexeme_array; var i: integer; var arrayCode: intermediate_code_array): string;
const
    factorSet: set of typeToken = [_STRING_LITERAL_, _VARIABLE_, _DECIMAL_, _FLOAT_, _HEXADECIMAL_, _OCTAL_];
var
    token: string;
begin
    if lexemes[i].token_real = type_token_unit._LEFT_PAREN_ then
    begin
        eatToken(lexemes, i, type_token_unit._LEFT_PAREN_);
        procExpr(lexemes, i, arrayCode);
        eatToken(lexemes, i, type_token_unit._RIGHT_PAREN_);
    end
    else
    if lexemes[i].token_real in factorSet then
    begin
        token := lexemes[i].lex_text;
        eatToken(lexemes, i, lexemes[i].token_real);
    end
    else
    begin
        writeln(#10, 'Syntax Error: Unexpected token at line ', lexemes[i].line, ', column ', lexemes[i].column, '. The token: "', lexemes[i].lex_text, '" is not appropriate.');
        writeln('The token: "', lexemes[i].lex_text, '" is a ', lexemes[i].token_real, ' type.', ' It should be a _STRING_LITERAL_, _VARIABLE_, _DECIMAL_, _FLOAT_, _HEXADECIMAL_ or _OCTAL_ type.', #10);
        Halt(1);
    end;
    Exit(token);
end;

end.