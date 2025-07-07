unit proc_unit;

interface

uses 
    syntax_utils_unit,
    lexeme_unit, 
    type_token_unit,
    intermediate_code_unit,
    intermediate_utils_unit,
    SysUtils;

type
  TPendingVar = record
    name: string;
    line: integer;  // Opcional: para mensagens de erro
  end;

  TPendingVarList = array of TPendingVar;

  arrayCode = array of intermediate_code;

var
  arrayIntermediateCode: arrayCode;
  pendingVars: TPendingVarList;
  tempCount: SmallInt = 0;

function procMain(lexemes: lexeme_array; var i: integer) : arrayCode;
procedure procDeclarations(lexemes: lexeme_array; var i: integer); 
procedure procStmtList(lexemes: lexeme_array; var i: integer);
procedure procDeclaration(lexemes: lexeme_array; var i: integer);
procedure procRestDeclaration(lexemes: lexeme_array; var i: integer);
procedure procListIdent(lexemes: lexeme_array; var i: integer; var varType: string);
procedure procType(lexemes: lexeme_array; var i: integer; var varType: string);
procedure procRestListIdent(lexemes: lexeme_array; var i: integer; var varType: string);
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
procedure procRestAdd(lexemes: lexeme_array; var i: integer; leftTemp: string);
procedure procUno(lexemes: lexeme_array; var i: integer);
procedure procRestMult(lexemes: lexeme_array; var i: integer; leftTemp: string);
procedure procFactor(lexemes: lexeme_array; var i: integer);

implementation

function procMain(lexemes: lexeme_array; var i: integer): arrayCode;
begin
    SetLength(arrayIntermediateCode, 0);
    SetLength(pendingVars, 0);
    eatToken(lexemes, i, type_token_unit._PROGRAM_);
    eatToken(lexemes, i, type_token_unit._VARIABLE_);
    eatToken(lexemes, i, type_token_unit._SEMICOLON_);
    procDeclarations(lexemes, i);
    eatToken(lexemes, i, type_token_unit._BEGIN_);
    procStmtList(lexemes, i);
    eatToken(lexemes, i, type_token_unit._END_);
    eatToken(lexemes, i, type_token_unit._DOT_);
    printIntermediateCode(arrayIntermediateCode);
    if (High(lexemes) > i) then
    begin 
        writeln(#10, 'Syntax Error: Unexpected tokens after ''end.'' (remaining tokens: ', High(lexemes) - i, ', expected: 0)', #10);
        Halt(1);
    end;
    Exit(arrayIntermediateCode);
end;

procedure procDeclarations(lexemes: lexeme_array; var i: integer);
begin
    eatToken(lexemes, i, type_token_unit._VAR_);
    procDeclaration(lexemes, i);
    procRestDeclaration(lexemes, i);
end;

procedure procDeclaration(lexemes: lexeme_array; var i: integer);
var
    varType: string;
begin
    procListIdent(lexemes, i, varType);
    eatToken(lexemes, i, type_token_unit._COLON_); 
    procType(lexemes, i, varType);
    eatToken(lexemes, i, type_token_unit._SEMICOLON_);
end;

procedure procListIdent(lexemes: lexeme_array; var i: integer; var varType: string);
var
  varName: string;
begin
  varName := lexemes[i].lex_text;
  eatToken(lexemes, i, type_token_unit._VARIABLE_);

  // Adiciona à lista de variáveis pendentes (sem tipo ainda)
  SetLength(pendingVars, Length(pendingVars) + 1);
  pendingVars[High(pendingVars)].name := varName;
  pendingVars[High(pendingVars)].line := lexemes[i].line;

  procRestListIdent(lexemes, i, varType);
end;

procedure procRestListIdent(lexemes: lexeme_array; var i: integer; var varType: string);
var
    varName: string;
begin
    if lexemes[i].token_real = type_token_unit._COMMA_ then
    begin
        eatToken(lexemes, i, type_token_unit._COMMA_);
        varName := lexemes[i].lex_text;
        eatToken(lexemes, i, type_token_unit._VARIABLE_);
        
        // Adiciona à lista de variáveis pendentes (assim como no procListIdent)
        SetLength(pendingVars, Length(pendingVars) + 1);
        pendingVars[High(pendingVars)].name := varName;
        pendingVars[High(pendingVars)].line := lexemes[i].line;
            
        procRestListIdent(lexemes, i, varType); // Chama recursivamente
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

procedure procType(lexemes: lexeme_array; var i: integer; var varType: string);
const 
  typeSet: set of typeToken = [_INTEGER_, _REAL_, _STRING_];
var
  j: integer;
  initialValue: string; // Valor inicial baseado no tipo
begin
  if lexemes[i].token_real in typeSet then
  begin
    case lexemes[i].token_real of
      _INTEGER_: 
      begin
        varType := 'integer';
        initialValue := '0'; // Valor padrão para inteiros
      end;
      _REAL_:    
      begin
        varType := 'float';
        initialValue := '0.0'; // Valor padrão para floats
      end;
      _STRING_:  
      begin
        varType := 'string';
        initialValue := ''''''; // String vazia (duas aspas simples)
      end;
    end;
    eatToken(lexemes, i, lexemes[i].token_real);

    // Gera código para todas as variáveis pendentes com valor inicial correto
    for j := 0 to High(pendingVars) do
    begin
      addIntermediateCode(arrayIntermediateCode,
        buildAssignCode(pendingVars[j].name, initialValue, varType));
    end;
    SetLength(pendingVars, 0);  // Limpa a lista
  end
  else
    // ... (manter o tratamento de erro atual)
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
var
  varName, startLabel, endLabel, loopLabel: string;
  tempFinal: string;
begin
  // 1. Obter o token FOR
  eatToken(lexemes, i, type_token_unit._FOR_); 
  
  // 2. Processar a atribuição inicial (ex: i := 1)
  // Isso vai gerar: ASSIGN i, 1, integer
  procAtrib(lexemes, i);
  varName := lexemes[i-2].lex_text; // Pega o nome da variável do FOR
  
  // 3. Criar labels para controle de fluxo
  startLabel := newLabel();
  endLabel := newLabel();
  loopLabel := newLabel();
  
  // 4. Adicionar label de início
  addIntermediateCode(arrayIntermediateCode, buildLabelCode(startLabel));
  
  // 5. Processar o valor final (TO <valor>)
  eatToken(lexemes, i, type_token_unit._TO_);
  
  // 6. Gerar código para o valor final
  tempFinal := newTemp(); // Cria um temporário para o valor final
  if lexemes[i].token_real = type_token_unit._VARIABLE_ then
  begin
    addIntermediateCode(arrayIntermediateCode, 
      buildAssignCode(tempFinal, lexemes[i].lex_text, 'integer'));
  end
  else // Número direto
  begin
    addIntermediateCode(arrayIntermediateCode,
      buildAssignCode(tempFinal, lexemes[i].lex_text, 'integer'));
  end;
  eatToken(lexemes, i, lexemes[i].token_real);
  
  // 7. Verificação da condição (i <= valor_final)
  addIntermediateCode(arrayIntermediateCode, buildLabelCode(loopLabel));
  addIntermediateCode(arrayIntermediateCode,
    buildOperationCode(OP_GT, 'tCond', varName, tempFinal, 'integer'));
  addIntermediateCode(arrayIntermediateCode,
    buildIfCode('tCond', endLabel, ''));
  
  // 8. Processar o comando DO
  eatToken(lexemes, i, type_token_unit._DO_);
  procStmt(lexemes, i);
  
  // 9. Incremento da variável
  addIntermediateCode(arrayIntermediateCode,
    buildOperationCode(OP_ADD, varName, varName, '1', 'integer'));
  
  // 10. Voltar para o início do loop
  addIntermediateCode(arrayIntermediateCode, buildJumpCode(loopLabel));
  
  // 11. Label de saída
  addIntermediateCode(arrayIntermediateCode, buildLabelCode(endLabel));
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
var
  ioType: string;
begin
  if lexemes[i].token_real in [type_token_unit._READ_, type_token_unit._READLN_] then
  begin
    ioType := UpperCase(lexemes[i].lex_text);
    eatToken(lexemes, i, lexemes[i].token_real);
    eatToken(lexemes, i, type_token_unit._LEFT_PAREN_);
    
    // Processa lista de variáveis para leitura
    while lexemes[i].token_real = type_token_unit._VARIABLE_ do
    begin
      addIntermediateCode(arrayIntermediateCode, 
        buildOperationCode('CALL', 'READ', lexemes[i].lex_text, '', 'var'));
      eatToken(lexemes, i, type_token_unit._VARIABLE_);
      
      if lexemes[i].token_real = type_token_unit._COMMA_ then
        eatToken(lexemes, i, type_token_unit._COMMA_)
      else
        break;
    end;
    
    eatToken(lexemes, i, type_token_unit._RIGHT_PAREN_);
    eatToken(lexemes, i, type_token_unit._SEMICOLON_);
    
    if ioType = 'READLN' then
      addIntermediateCode(arrayIntermediateCode, 
        buildOperationCode('CALL', 'WRITE', '\n', '', 'none'));
  end
  
  else if lexemes[i].token_real in [type_token_unit._WRITE_, type_token_unit._WRITELN_] then
  begin
    ioType := UpperCase(lexemes[i].lex_text);
    eatToken(lexemes, i, lexemes[i].token_real);
    eatToken(lexemes, i, type_token_unit._LEFT_PAREN_);
    
    procOutList(lexemes, i);
    
    eatToken(lexemes, i, type_token_unit._RIGHT_PAREN_);
    eatToken(lexemes, i, type_token_unit._SEMICOLON_);
    
    if ioType = 'WRITELN' then
      addIntermediateCode(arrayIntermediateCode, 
        buildOperationCode('CALL', 'WRITE', '\n', '', 'none'));
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
  if lexemes[i].token_real = type_token_unit._STRING_LITERAL_ then
  begin
    addIntermediateCode(arrayIntermediateCode, 
      buildOperationCode('CALL', 'WRITE', lexemes[i].lex_text, '', 'string'));
    eatToken(lexemes, i, type_token_unit._STRING_LITERAL_);
  end
  else if lexemes[i].token_real = type_token_unit._VARIABLE_ then
  begin
    addIntermediateCode(arrayIntermediateCode, 
      buildOperationCode('CALL', 'WRITE', lexemes[i].lex_text, '', 'var'));
    eatToken(lexemes, i, type_token_unit._VARIABLE_);
  end
  else if lexemes[i].token_real in [type_token_unit._DECIMAL_, type_token_unit._FLOAT_] then
  begin
    addIntermediateCode(arrayIntermediateCode, 
      buildOperationCode('CALL', 'WRITE', lexemes[i].lex_text, '', 'none'));
    eatToken(lexemes, i, lexemes[i].token_real);
  end;
end;

procedure procWhileStmt(lexemes: lexeme_array; var i: integer);
var
  startLabel, endLabel: string;
begin
  // Cria labels para controle de fluxo
  startLabel := newLabel();
  endLabel := newLabel();
  
  // Label de início do loop
  addIntermediateCode(arrayIntermediateCode, buildLabelCode(startLabel));
  
  eatToken(lexemes, i, type_token_unit._WHILE_);
  
  // Processa a condição (deixa resultado no último temp)
  procExpr(lexemes, i);
  
  // Gera condição de saída (se falso, pula para endLabel)
  addIntermediateCode(arrayIntermediateCode,
    buildIfCode('t' + IntToStr(tempCount), endLabel, ''));

  Inc(tempCount);
  
  eatToken(lexemes, i, type_token_unit._DO_);
  
  // Processa o corpo do WHILE
  procStmt(lexemes, i);
  
  // Volta para o início do loop
  addIntermediateCode(arrayIntermediateCode, buildJumpCode(startLabel));
  
  // Label de saída
  addIntermediateCode(arrayIntermediateCode, buildLabelCode(endLabel));
end;

procedure procIfStmt(lexemes: lexeme_array; var i: integer);
var
  elseLabel, endLabel: string;
begin
  // Cria labels para controle de fluxo
  elseLabel := newLabel();
  endLabel := newLabel();
  
  eatToken(lexemes, i, type_token_unit._IF_);
  
  // Processa a condição (deixa resultado no último temp)
  procExpr(lexemes, i);
  
  // Gera condição (se falso, pula para elseLabel)
  addIntermediateCode(arrayIntermediateCode,
    buildIfCode('t' + IntToStr(tempCount), elseLabel, ''));
  
  Inc(tempCount);
  
  eatToken(lexemes, i, type_token_unit._THEN_);
  
  // Processa o bloco THEN
  procStmt(lexemes, i);
  
  // Pula para o fim (para não executar o ELSE)
  addIntermediateCode(arrayIntermediateCode, buildJumpCode(endLabel));
  
  // Label do ELSE (se existir)
  addIntermediateCode(arrayIntermediateCode, buildLabelCode(elseLabel));
  
  // Processa o ELSE (se existir)
  procElsePart(lexemes, i);
  
  // Label de fim
  addIntermediateCode(arrayIntermediateCode, buildLabelCode(endLabel));
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
var
  varName, value, varType: string;
  isInteger, isFloat: Boolean;
  dummyInt: LongInt;
  dummyFloat: Double;
  tempResult: string;
begin
  // 1. Obter nome da variável
  varName := lexemes[i].lex_text;
  eatToken(lexemes, i, type_token_unit._VARIABLE_);
  eatToken(lexemes, i, type_token_unit._ASSIGN_);

  // 2. Detecção automática do tipo do valor
  value := lexemes[i].lex_text;
  
  // Verifica se é integer
  isInteger := TryStrToInt(value, dummyInt);
  
  // Se não for integer, verifica se é float
  if not isInteger then
    isFloat := TryStrToFloat(value, dummyFloat)
  else
    isFloat := False;

  // Determina o tipo
  if isInteger then
    varType := 'integer'
  else if isFloat then
    varType := 'real'
  else if lexemes[i].token_real = _STRING_LITERAL_ then
    varType := 'string'
  else
    varType := 'integer'; // Caso padrão (será tratado como string)

  // 3. Processa a expressão (versão simplificada sem procExpr)
  if lexemes[i].token_real in [_VARIABLE_, _DECIMAL_, _FLOAT_, _STRING_LITERAL_] then
  begin
    addIntermediateCode(arrayIntermediateCode, 
      buildAssignCode(varName, value, varType));
    eatToken(lexemes, i, lexemes[i].token_real);
  end
  else
  begin
    // Caso de expressões complexas (operações aritméticas)
    procExpr(lexemes, i);
    tempResult := 't' + IntToStr(tempCount);
    Inc(tempCount);
    addIntermediateCode(arrayIntermediateCode,
      buildAssignCode(varName, tempResult, 'integer')); // Assume integer para expressões
  end;
end;

procedure procExpr(lexemes: lexeme_array; var i: integer);
begin
    procOr(lexemes, i);
end;

procedure procOr(lexemes: lexeme_array; var i: integer);
var
  temp1, temp2: string;
begin
  procAnd(lexemes, i);  // Processa o primeiro operando (deixa resultado em tX)
  temp1 := 't' + IntToStr(tempCount); // Pega o temp do primeiro operando
  Inc(tempCount);
  
  procRestOr(lexemes, i);
  
  // Se encontrou um OR, gera código
  if (i < Length(lexemes)) and (lexemes[i].token_real = type_token_unit._OR_) then
  begin
    temp2 := 't' + IntToStr(tempCount); // Pega o temp do segundo operando
    Inc(tempCount);
    addIntermediateCode(arrayIntermediateCode,
      buildOperationCode(OP_OR, newTemp(), temp1, temp2, 'boolean'));
  end;
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
var
  temp1, temp2: string;
begin
  procNot(lexemes, i);
  temp1 := 't' + IntToStr(tempCount);
  Inc(tempCount);
  
  procRestAnd(lexemes, i);
  
  if (i < Length(lexemes)) and (lexemes[i].token_real = type_token_unit._AND_) then
  begin
    temp2 := 't' + IntToStr(tempCount);
    Inc(tempCount);
    addIntermediateCode(arrayIntermediateCode,
      buildOperationCode(OP_AND, newTemp(), temp1, temp2, 'boolean'));
  end;
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
var
  temp: string;
begin
  if lexemes[i].token_real = type_token_unit._NOT_ then
  begin
    eatToken(lexemes, i, type_token_unit._NOT_);
    procNot(lexemes, i);
    temp := 't' + IntToStr(tempCount);
    Inc(tempCount);
    addIntermediateCode(arrayIntermediateCode,
      buildOperationCode(OP_NOT, newTemp(), temp, '', 'boolean'));
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
var
  tempLeft: string;
begin
  procMult(lexemes, i);  // Processa o lado esquerdo
  tempLeft := 't' + IntToStr(tempCount); // Pega o temp do resultado
  Inc(tempCount);
  procRestAdd(lexemes, i, tempLeft); // Passa o temp como parâmetro
end;

procedure procRestAdd(lexemes: lexeme_array; var i: integer; leftTemp: string);
var
  op, tempRight, resultTemp: string;
begin
  if (i < Length(lexemes)) and 
     (lexemes[i].token_real in [type_token_unit._ADD_, type_token_unit._SUB_]) then
  begin
    // Determina a operação
    if lexemes[i].token_real = type_token_unit._ADD_ then
      op := OP_ADD
    else
      op := OP_SUB;
    
    eatToken(lexemes, i, lexemes[i].token_real);
    
    procMult(lexemes, i); // Processa o lado direito
    tempRight := 't' + IntToStr(tempCount);
    Inc(tempCount);
    
    // Gera código intermediário
    resultTemp := newTemp();
    addIntermediateCode(arrayIntermediateCode,
      buildOperationCode(op, resultTemp, leftTemp, tempRight, 'integer'));
    
    // Processa mais operações (+ ou -) na mesma precedência
    procRestAdd(lexemes, i, resultTemp);
  end;
end;

procedure procMult(lexemes: lexeme_array; var i: integer);
var
  tempLeft: string;
begin
  procUno(lexemes, i);  // Processa o lado esquerdo
  tempLeft := 't' + IntToStr(tempCount);
  Inc(tempCount);
  procRestMult(lexemes, i, tempLeft); // Passa o temp como parâmetro
end;

procedure procRestMult(lexemes: lexeme_array; var i: integer; leftTemp: string);
var
  op, tempRight, resultTemp: string;
begin
  if (i < Length(lexemes)) and 
     (lexemes[i].token_real in [type_token_unit._MUL_, type_token_unit._REAL_DIV_, 
                               type_token_unit._MOD_, type_token_unit._INTER_DIV_]) then
  begin
    // Determina a operação
    case lexemes[i].token_real of
      type_token_unit._MUL_: op := OP_MUL;
      type_token_unit._REAL_DIV_: op := OP_DIV;
      type_token_unit._INTER_DIV_: op := OP_IDIV;
      type_token_unit._MOD_: op := OP_MOD;
    end;
    
    eatToken(lexemes, i, lexemes[i].token_real);
    
    procUno(lexemes, i); // Processa o lado direito
    tempRight := 't' + IntToStr(tempCount);
    Inc(tempCount);
    
    // Gera código intermediário
    resultTemp := newTemp();
    addIntermediateCode(arrayIntermediateCode,
      buildOperationCode(op, resultTemp, leftTemp, tempRight, 'integer'));
    
    // Processa mais operações (*, /, etc) na mesma precedência
    procRestMult(lexemes, i, resultTemp);
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
var
  tempName, varType: string;
begin
  if lexemes[i].token_real = type_token_unit._LEFT_PAREN_ then
  begin
    eatToken(lexemes, i, type_token_unit._LEFT_PAREN_);
    procExpr(lexemes, i);  // Processa a expressão dentro dos parênteses
    eatToken(lexemes, i, type_token_unit._RIGHT_PAREN_);
    // O resultado já está no último temporário (tX)
  end
  else if lexemes[i].token_real in [_VARIABLE_, _DECIMAL_, _FLOAT_, _HEXADECIMAL_, _OCTAL_, _STRING_LITERAL_] then
  begin
    tempName := newTemp(); // Cria um novo temporário
    
    case lexemes[i].token_real of
      _VARIABLE_:
      begin
        varType := 'var';
        addIntermediateCode(arrayIntermediateCode,
          buildAssignCode(tempName, lexemes[i].lex_text, varType));
      end;
      
      _DECIMAL_, _HEXADECIMAL_, _OCTAL_:
      begin
        addIntermediateCode(arrayIntermediateCode,
          buildAssignCode(tempName, lexemes[i].lex_text, 'integer'));
      end;
      
      _FLOAT_:
      begin
        addIntermediateCode(arrayIntermediateCode,
          buildAssignCode(tempName, lexemes[i].lex_text, 'real'));
      end;
      
      _STRING_LITERAL_:
      begin
        addIntermediateCode(arrayIntermediateCode,
          buildAssignCode(tempName, lexemes[i].lex_text, 'string'));
      end;
    end;
    
    eatToken(lexemes, i, lexemes[i].token_real);
  end
  else
  begin
    // Tratamento de erro (mantido do seu código original)
    writeln(#10, 'Syntax Error: Unexpected token at line ', lexemes[i].line, ', column ', lexemes[i].column, '. The token: "', lexemes[i].lex_text, '" is not appropriate.');
    writeln('The token: "', lexemes[i].lex_text, '" is a ', lexemes[i].token_real, ' type.', ' It should be a _STRING_LITERAL_, _VARIABLE_, _DECIMAL_, _FLOAT_, _HEXADECIMAL_ or _OCTAL_ type.', #10);
    Halt(1);
  end;
end;

end.