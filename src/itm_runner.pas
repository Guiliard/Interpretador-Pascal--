unit itm_runner;

interface

uses 
    SysUtils, itm_analyzer;

type
  LabelInst = record
    fname: string;
    line: LongInt;
  end;

  StringVal = record
    sname: string;
    sval: string;
  end;

  IntVal = record
    fname: string;
    fval: integer;
  end;

  FloatVal = record
    fname: string;
    fval: single;
  end;

  BinVal = record
    fname: string;
    fval: boolean;
  end;

  LinstArray = array of LabelInst;
  SvalArray = array of StringVal;
  IvalArray = array of IntVal;
  FvalArray = array of FloatVal;
  BvalArray = array of BinVal;

procedure appendl(var arr: LinstArray; novo: LabelInst);
procedure appends(var arr: SvalArray; novo: StringVal);
procedure appendi(var arr: IvalArray; novo: IntVal);
procedure appendf(var arr: FvalArray; novo: FloatVal);
procedure appendb(var arr: BvalArray; novo: BinVal);
procedure ErrorAndExit(const msg: string);
function UpdateOrAddString(var arr: SvalArray; const name, value: string): boolean;
function UpdateOrAddInt(var arr: IvalArray; const name: string; value: integer): boolean;
function UpdateOrAddFloat(var arr: FvalArray; const name: string; value: double): boolean;
function FindVariableType(const name: string; var sarr: SvalArray; var iarr: IvalArray; 
                         var farr: FvalArray; var barr: BvalArray): string;
procedure RunInstructions(arr: ItmArray);

implementation

procedure appendl(var arr: LinstArray; novo: LabelInst);
var
  n: Integer;
begin
  n := Length(arr);
  SetLength(arr, n + 1);
  arr[n] := novo;
end;

procedure appends(var arr: SvalArray; novo: StringVal);
var
  n: Integer;
begin
  n := Length(arr);
  SetLength(arr, n + 1);
  arr[n] := novo;
end;

procedure appendi(var arr: IvalArray; novo: IntVal);
var
  n: Integer;
begin
  n := Length(arr);
  SetLength(arr, n + 1);
  arr[n] := novo;
end;

procedure appendf(var arr: FvalArray; novo: FloatVal);
var
  n: Integer;
begin
  n := Length(arr);
  SetLength(arr, n + 1);
  arr[n] := novo;
end;

procedure appendb(var arr: BvalArray; novo: BinVal);
var
  n: Integer;
begin
  n := Length(arr);
  SetLength(arr, n + 1);
  arr[n] := novo;
end;

procedure ErrorAndExit(const msg: string);
begin
  WriteLn('ERRO: ', msg);
  Halt(1); // Encerra o programa com código de erro
end;

function UpdateOrAddString(var arr: SvalArray; const name, value: string): boolean;
var
  i: integer;
  novo: StringVal;
begin
  UpdateOrAddString := false;
  for i := 0 to High(arr) do
  begin
    if arr[i].sname = name then
    begin
      arr[i].sval := value;
      UpdateOrAddString := true;
      Exit;
    end;
  end;
  
  novo.sname := name;
  novo.sval := value;
  appends(arr, novo);
  UpdateOrAddString := true;
end;

function UpdateOrAddInt(var arr: IvalArray; const name: string; value: integer): boolean;
var
  i: integer;
  novo: IntVal;
begin
  UpdateOrAddInt := false;
  for i := 0 to High(arr) do
  begin
    if arr[i].fname = name then
    begin
      arr[i].fval := value;
      UpdateOrAddInt := true;
      Exit;
    end;
  end;

  novo.fname := name;
  novo.fval := value;
  appendi(arr, novo);
  UpdateOrAddInt := true;
end;

function UpdateOrAddFloat(var arr: FvalArray; const name: string; value: double): boolean;
var
  i: integer;
  novo: FloatVal;
begin
  UpdateOrAddFloat := false;
  for i := 0 to High(arr) do
  begin
    if arr[i].fname = name then
    begin
      arr[i].fval := value;
      UpdateOrAddFloat := true;
      Exit;
    end;
  end;
  
  novo.fname := name;
  novo.fval := value;
  appendf(arr, novo);
  UpdateOrAddFloat := true;
end;

function UpdateOrAddBool(var arr: BvalArray; const name: string; value: boolean): boolean;
var
  i: integer;
  novo: BinVal;
begin
  UpdateOrAddBool := false;
  for i := 0 to High(arr) do
  begin
    if arr[i].fname = name then
    begin
      arr[i].fval := value;
      UpdateOrAddBool := true;
      Exit;
    end;
  end;
  
  novo.fname := name;
  novo.fval := value;
  appendb(arr, novo);
  UpdateOrAddBool := true;
end;

function FindVariableType(const name: string; var sarr: SvalArray; var iarr: IvalArray; 
                         var farr: FvalArray; var barr: BvalArray): string;
var
  i: integer;
begin
  // Verifica em todos os arrays e retorna o tipo da variável
  for i := 0 to High(sarr) do
    if sarr[i].sname = name then Exit('string');
  
  for i := 0 to High(iarr) do
    if iarr[i].fname = name then Exit('int');
  
  for i := 0 to High(farr) do
    if farr[i].fname = name then Exit('float');
  
  for i := 0 to High(barr) do
    if barr[i].fname = name then Exit('bool');
  
  FindVariableType := ''; // Não encontrado
end;

function FindInStringArray(const arr: SvalArray; const name: string; var value: string): boolean;
var
  i: integer;
begin
  for i := 0 to High(arr) do
    if arr[i].sname = name then
    begin
      value := arr[i].sval;
      Exit(true);
    end;
  FindInStringArray := false;
end;

function FindInLabelArray(const arr: LinstArray; const name: string): LongInt;
var
  i: integer;
begin
  for i := 0 to High(arr) do
    if arr[i].fname = name then
    begin
      Exit(arr[i].line);
    end;
  FindInLabelArray := -1;
end;

function FindLabelAfter(const arr: ItmArray; const name: string; var j: LongInt): LongInt;
var
  i: LongInt;
begin
  for i := j to High(arr) do
    if (arr[i].op = 'LABEL') and (arr[i].arg1 = name) then
    begin
      Exit(i);
    end;
  FindLabelAfter := -1;
end;

function FindInIntArray(const arr: IvalArray; const name: string; var value: integer): boolean;
var
  i: integer;
begin
  for i := 0 to High(arr) do
    if arr[i].fname = name then
    begin
      value := arr[i].fval;
      Exit(true);
    end;
  FindInIntArray := false;
end;

function FindInBoolArray(const arr: BvalArray; const name: string; var value: boolean): boolean;
var
  i: integer;
begin
  for i := 0 to High(arr) do
    if arr[i].fname = name then
    begin
      value := arr[i].fval;
      Exit(true);
    end;
  FindInBoolArray := false;
end;

function FindInFloatArray(const arr: FvalArray; const name: string; var value: Double): boolean;
var
  i: integer;
begin
  for i := 0 to High(arr) do
    if arr[i].fname = name then
    begin
      value := arr[i].fval;
      Exit(true);
    end;
  FindInFloatArray := false;
end;

function VariableExists(varName: string; const sarr: SvalArray; const iarr: IvalArray; const farr: FvalArray): Boolean;
var
  dummyStr: string;
  dummyInt: SmallInt;
  dummyFloat: Double;
begin
  VariableExists := (FindInStringArray(sarr, varName, dummyStr) or 
             FindInIntArray(iarr, varName, dummyInt) or
             FindInFloatArray(farr, varName, dummyFloat));
end;

procedure RunInstructions(arr: ItmArray);
var
  i: LongInt;
  instr: ItmInstruction;
  larr: LinstArray;
  sarr: SvalArray;
  iarr: IvalArray;
  farr: FvalArray;
  barr: BvalArray;
  lnovo: LabelInst;
  varType: string;
  floatValue: Double = 0.0;
  sourceType: string;
  strVal: string;
  intVal: SmallInt = 0;  // Alterado para SmallInt
  tempInt: LongInt = 0; // Variável temporária para conversão
  op1Value: Double;
  op2Value: Double;
  op1IsFloat: Boolean;
  op2IsFloat: Boolean;
  op1Type: string;
  op2Type: string;
  resultIsFloat: Boolean;
  resultInt: integer;
  resultFloat: Double;
  tempStr: string;
  boolVal: boolean;
  intVal1, intVal2: integer;
  floatVal1, floatVal2: Double;
  isFloatOp: Boolean;
  tempFloat: Double;
begin
  SetLength(sarr, 0);
  SetLength(iarr, 0);
  SetLength(farr, 0);
  SetLength(larr, 0);
  i := 0;
  while i <= High(arr) do
  begin
    instr := arr[i];
    WriteLn('Running Instruction ', i, ': ', instr.op);
    
    if instr.op = 'ASSIGN' then
    begin
      if VariableExists(instr.arg1, sarr, iarr, farr) then
        ErrorAndExit('Variável já existe: ' + instr.arg1);

      varType := FindVariableType(instr.arg1, sarr, iarr, farr, barr);
      
      if instr.arg_type = 'var' then
      begin
        // Atribuição de variável para variável
        sourceType := FindVariableType(instr.arg2, sarr, iarr, farr, barr);
        
        if sourceType = '' then
          ErrorAndExit('Variável fonte não encontrada: ' + instr.arg2);
        
        if sourceType = 'string' then
        begin
          if not FindInStringArray(sarr, instr.arg2, strVal) then
            ErrorAndExit('Erro interno: string não encontrada');
            
          if varType = '' then
            UpdateOrAddString(sarr, instr.arg1, strVal)
          else if varType = 'string' then
            UpdateOrAddString(sarr, instr.arg1, strVal)
          else
            ErrorAndExit('Tipo incompatível: não pode atribuir string para ' + varType);
        end
        else if sourceType = 'int' then
        begin
          if not FindInIntArray(iarr, instr.arg2, intVal) then
            ErrorAndExit('Erro interno: int não encontrado');
          
          if varType = '' then
            UpdateOrAddInt(iarr, instr.arg1, intVal)
          else if varType = 'int' then
            UpdateOrAddInt(iarr, instr.arg1, intVal)
          else if varType = 'float' then
            UpdateOrAddFloat(farr, instr.arg1, intVal)
          else
            ErrorAndExit('Tipo incompatível: não pode atribuir int para ' + varType);
        end
        else if sourceType = 'float' then
        begin
          if not FindInFloatArray(farr, instr.arg2, floatValue) then
            ErrorAndExit('Erro interno: float não encontrado');
          
          if varType = '' then
            UpdateOrAddFloat(farr, instr.arg1, floatValue)
          else if varType = 'int' then
            UpdateOrAddInt(iarr, instr.arg1, Round(floatValue))
          else if varType = 'float' then
            UpdateOrAddFloat(farr, instr.arg1, floatValue)
          else
            ErrorAndExit('Tipo incompatível: não pode atribuir int para ' + varType);
        end;
      end
      else if instr.arg_type = 'string' then
      begin
        if (varType <> '') and (varType <> 'string') then
          ErrorAndExit('Tipo incompatível: não pode atribuir string para ' + varType);
          
        UpdateOrAddString(sarr, instr.arg1, instr.arg2);
      end
      else if TryStrToInt(instr.arg2, tempInt) then
      begin
        intVal := SmallInt(tempInt); // Conversão explícita
        
        if (varType <> '') and (varType <> 'int') then
          ErrorAndExit('Tipo incompatível: não pode atribuir int para ' + varType);
          
        UpdateOrAddInt(iarr, instr.arg1, tempInt);
      end
      else if TryStrToFloat(instr.arg2, floatValue) then
      begin
        if (varType <> '') and (varType <> 'float') then
          ErrorAndExit('Tipo incompatível: não pode atribuir float para ' + varType);
          
        UpdateOrAddFloat(farr, instr.arg1, floatValue);
      end
      else
        ErrorAndExit('Tipo de valor não reconhecido: ' + instr.arg2);
    end
    else if instr.op = 'ADD' then
    begin
      // Verifica se o destino (arg1) é uma variável válida (deve começar com letra)
      if (instr.arg1 = '') or (instr.arg1[1] in ['0'..'9']) then
        ErrorAndExit('Nome de variável inválido para destino da ADD: ' + instr.arg1);

      op1IsFloat := False;
      op2IsFloat := False;

      // Processa o primeiro operando (arg2)
      if TryStrToInt(instr.arg2, tempInt) then
      begin
        op1Value := tempInt;
      end
      else if TryStrToFloat(instr.arg2, floatValue) then
      begin
        op1Value := floatValue;
        op1IsFloat := True;
      end
      else
      begin
        // É uma variável - verifica o tipo
        op1Type := FindVariableType(instr.arg2, sarr, iarr, farr, barr);
        if op1Type = 'int' then
        begin
          intVal := tempInt;
          if not FindInIntArray(iarr, instr.arg2, intVal) then
            ErrorAndExit('Variável inteira não encontrada: ' + instr.arg2);
          op1Value := intVal;
        end
        else if op1Type = 'float' then
        begin
          if not FindInFloatArray(farr, instr.arg2, floatValue) then
            ErrorAndExit('Variável float não encontrada: ' + instr.arg2);
          op1Value := floatValue;
          op1IsFloat := True;
        end
        else
          ErrorAndExit('Operando 1 inválido para ADD: ' + instr.arg2);
      end;

      // Processa o segundo operando (arg3)
      if TryStrToInt(instr.arg3, tempInt) then
      begin
        op2Value := tempInt;
      end
      else if TryStrToFloat(instr.arg3, floatValue) then
      begin
        op2Value := floatValue;
        op2IsFloat := True;
      end
      else
      begin
        // É uma variável - verifica o tipo
        op2Type := FindVariableType(instr.arg3, sarr, iarr, farr, barr);
        if op2Type = 'int' then
        begin
          intVal := tempInt;
          if not FindInIntArray(iarr, instr.arg3, intVal) then
            ErrorAndExit('Variável inteira não encontrada: ' + instr.arg3);
          op2Value := intVal;
        end
        else if op2Type = 'float' then
        begin
          if not FindInFloatArray(farr, instr.arg3, floatValue) then
            ErrorAndExit('Variável float não encontrada: ' + instr.arg3);
          op2Value := floatValue;
          op2IsFloat := True;
        end
        else
          ErrorAndExit('Operando 2 inválido para ADD: ' + instr.arg3);
      end;

      // Determina o tipo do resultado
      resultIsFloat := op1IsFloat or op2IsFloat;

      // Realiza a operação e armazena o resultado
      if resultIsFloat then
      begin
        resultFloat := op1Value + op2Value;
        UpdateOrAddFloat(farr, instr.arg1, resultFloat);
        WriteLn('ADD: ', op1Value:0:2, ' + ', op2Value:0:2, ' = ', resultFloat:0:2, ' (float)');
      end
      else
      begin
        resultInt := Round(op1Value + op2Value);
        UpdateOrAddInt(iarr, instr.arg1, resultInt);
        WriteLn('ADD: ', Round(op1Value), ' + ', Round(op2Value), ' = ', resultInt, ' (int)');
      end;
    end
    else if instr.op = 'SUB' then
    begin
      // Verifica se o destino (arg1) é uma variável válida (deve começar com letra)
      if (instr.arg1 = '') or (instr.arg1[1] in ['0'..'9']) then
        ErrorAndExit('Nome de variável inválido para destino da SUB: ' + instr.arg1);

      op1IsFloat := False;
      op2IsFloat := False;

      // Processa o primeiro operando (arg2)
      if TryStrToInt(instr.arg2, tempInt) then
      begin
        op1Value := tempInt;
      end
      else if TryStrToFloat(instr.arg2, floatValue) then
      begin
        op1Value := floatValue;
        op1IsFloat := True;
      end
      else
      begin
        // É uma variável - verifica o tipo
        op1Type := FindVariableType(instr.arg2, sarr, iarr, farr, barr);
        if op1Type = 'int' then
        begin
          intVal := tempInt;
          if not FindInIntArray(iarr, instr.arg2, intVal) then
            ErrorAndExit('Variável inteira não encontrada: ' + instr.arg2);
          op1Value := intVal;
        end
        else if op1Type = 'float' then
        begin
          if not FindInFloatArray(farr, instr.arg2, floatValue) then
            ErrorAndExit('Variável float não encontrada: ' + instr.arg2);
          op1Value := floatValue;
          op1IsFloat := True;
        end
        else
          ErrorAndExit('Operando 1 inválido para SUB: ' + instr.arg2);
      end;

      // Processa o segundo operando (arg3)
      if TryStrToInt(instr.arg3, tempInt) then
      begin
        op2Value := tempInt;
      end
      else if TryStrToFloat(instr.arg3, floatValue) then
      begin
        op2Value := floatValue;
        op2IsFloat := True;
      end
      else
      begin
        // É uma variável - verifica o tipo
        op2Type := FindVariableType(instr.arg3, sarr, iarr, farr, barr);
        if op2Type = 'int' then
        begin
          intVal := tempInt;
          if not FindInIntArray(iarr, instr.arg3, intVal) then
            ErrorAndExit('Variável inteira não encontrada: ' + instr.arg3);
          op2Value := intVal;
        end
        else if op2Type = 'float' then
        begin
          if not FindInFloatArray(farr, instr.arg3, floatValue) then
            ErrorAndExit('Variável float não encontrada: ' + instr.arg3);
          op2Value := floatValue;
          op2IsFloat := True;
        end
        else
          ErrorAndExit('Operando 2 inválido para SUB: ' + instr.arg3);
      end;

      // Determina o tipo do resultado
      resultIsFloat := op1IsFloat or op2IsFloat;

      // Realiza a operação e armazena o resultado
      if resultIsFloat then
      begin
        resultFloat := op1Value - op2Value;
        UpdateOrAddFloat(farr, instr.arg1, resultFloat);
        WriteLn('SUB: ', op1Value:0:2, ' + ', op2Value:0:2, ' = ', resultFloat:0:2, ' (float)');
      end
      else
      begin
        resultInt := Round(op1Value - op2Value);
        UpdateOrAddInt(iarr, instr.arg1, resultInt);
        WriteLn('SUB: ', Round(op1Value), ' + ', Round(op2Value), ' = ', resultInt, ' (int)');
      end;
    end
    else if instr.op = 'MULT' then
    begin
      // Verifica se o destino (arg1) é uma variável válida (deve começar com letra)
      if (instr.arg1 = '') or (instr.arg1[1] in ['0'..'9']) then
        ErrorAndExit('Nome de variável inválido para destino da MULT: ' + instr.arg1);

      op1IsFloat := False;
      op2IsFloat := False;

      // Processa o primeiro operando (arg2)
      if TryStrToInt(instr.arg2, tempInt) then
      begin
        op1Value := tempInt;
      end
      else if TryStrToFloat(instr.arg2, floatValue) then
      begin
        op1Value := floatValue;
        op1IsFloat := True;
      end
      else
      begin
        // É uma variável - verifica o tipo
        op1Type := FindVariableType(instr.arg2, sarr, iarr, farr, barr);
        if op1Type = 'int' then
        begin
          intVal := tempInt;
          if not FindInIntArray(iarr, instr.arg2, intVal) then
            ErrorAndExit('Variável inteira não encontrada: ' + instr.arg2);
          op1Value := intVal;
        end
        else if op1Type = 'float' then
        begin
          if not FindInFloatArray(farr, instr.arg2, floatValue) then
            ErrorAndExit('Variável float não encontrada: ' + instr.arg2);
          op1Value := floatValue;
          op1IsFloat := True;
        end
        else
          ErrorAndExit('Operando 1 inválido para MULT: ' + instr.arg2);
      end;

      // Processa o segundo operando (arg3)
      if TryStrToInt(instr.arg3, tempInt) then
      begin
        op2Value := tempInt;
      end
      else if TryStrToFloat(instr.arg3, floatValue) then
      begin
        op2Value := floatValue;
        op2IsFloat := True;
      end
      else
      begin
        // É uma variável - verifica o tipo
        op2Type := FindVariableType(instr.arg3, sarr, iarr, farr, barr);
        if op2Type = 'int' then
        begin
          intVal := tempInt;
          if not FindInIntArray(iarr, instr.arg3, intVal) then
            ErrorAndExit('Variável inteira não encontrada: ' + instr.arg3);
          op2Value := intVal;
        end
        else if op2Type = 'float' then
        begin
          if not FindInFloatArray(farr, instr.arg3, floatValue) then
            ErrorAndExit('Variável float não encontrada: ' + instr.arg3);
          op2Value := floatValue;
          op2IsFloat := True;
        end
        else
          ErrorAndExit('Operando 2 inválido para MULT: ' + instr.arg3);
      end;

      // Determina o tipo do resultado
      resultIsFloat := op1IsFloat or op2IsFloat;

      // Realiza a operação e armazena o resultado
      if resultIsFloat then
      begin
        resultFloat := op1Value * op2Value;
        UpdateOrAddFloat(farr, instr.arg1, resultFloat);
        WriteLn('MULT: ', op1Value:0:2, ' + ', op2Value:0:2, ' = ', resultFloat:0:2, ' (float)');
      end
      else
      begin
        resultInt := Round(op1Value * op2Value);
        UpdateOrAddInt(iarr, instr.arg1, resultInt);
        WriteLn('MULT: ', Round(op1Value), ' + ', Round(op2Value), ' = ', resultInt, ' (int)');
      end;
    end
    else if instr.op = 'DIV' then
    begin
      // Verifica se o destino (arg1) é uma variável válida (deve começar com letra)
      if (instr.arg1 = '') or (instr.arg1[1] in ['0'..'9']) then
        ErrorAndExit('Nome de variável inválido para destino da DIV: ' + instr.arg1);

      op1IsFloat := False;
      op2IsFloat := False;

      // Processa o primeiro operando (arg2)
      if TryStrToInt(instr.arg2, tempInt) then
      begin
        op1Value := tempInt;
      end
      else if TryStrToFloat(instr.arg2, floatValue) then
      begin
        op1Value := floatValue;
        op1IsFloat := True;
      end
      else
      begin
        // É uma variável - verifica o tipo
        op1Type := FindVariableType(instr.arg2, sarr, iarr, farr, barr);
        if op1Type = 'int' then
        begin
          intVal := tempInt;
          if not FindInIntArray(iarr, instr.arg2, intVal) then
            ErrorAndExit('Variável inteira não encontrada: ' + instr.arg2);
          op1Value := intVal;
        end
        else if op1Type = 'float' then
        begin
          if not FindInFloatArray(farr, instr.arg2, floatValue) then
            ErrorAndExit('Variável float não encontrada: ' + instr.arg2);
          op1Value := floatValue;
          op1IsFloat := True;
        end
        else
          ErrorAndExit('Operando 1 inválido para DIV: ' + instr.arg2);
      end;

      // Processa o segundo operando (arg3)
      if TryStrToInt(instr.arg3, tempInt) then
      begin
        op2Value := tempInt;
        if (op2Value = 0) then
          ErrorAndExit('Divisão por zero não é permitido.');
      end
      else if TryStrToFloat(instr.arg3, floatValue) then
      begin
        op2Value := floatValue;
        op2IsFloat := True;
      end
      else
      begin
        // É uma variável - verifica o tipo
        op2Type := FindVariableType(instr.arg3, sarr, iarr, farr, barr);
        if op2Type = 'int' then
        begin
          intVal := tempInt;
          if not FindInIntArray(iarr, instr.arg3, intVal) then
            ErrorAndExit('Variável inteira não encontrada: ' + instr.arg3);
          op2Value := intVal;
        end
        else if op2Type = 'float' then
        begin
          if not FindInFloatArray(farr, instr.arg3, floatValue) then
            ErrorAndExit('Variável float não encontrada: ' + instr.arg3);
          op2Value := floatValue;
          op2IsFloat := True;
        end
        else
          ErrorAndExit('Operando 2 inválido para DIV: ' + instr.arg3);
      end;

      // Determina o tipo do resultado
      resultIsFloat := op1IsFloat or op2IsFloat;

      // Realiza a operação e armazena o resultado
      if resultIsFloat then
      begin
        resultFloat := op1Value / op2Value;
        UpdateOrAddFloat(farr, instr.arg1, resultFloat);
        WriteLn('DIV: ', op1Value:0:2, ' + ', op2Value:0:2, ' = ', resultFloat:0:2, ' (float)');
      end
      else
      begin
        resultInt := Round(op1Value / op2Value);
        UpdateOrAddInt(iarr, instr.arg1, resultInt);
        WriteLn('ADD: ', Round(op1Value), ' + ', Round(op2Value), ' = ', resultInt, ' (int)');
      end;
    end
    else if instr.op = 'IDIV' then
    begin
      // Verifica se o destino (arg1) é uma variável válida (deve começar com letra)
      if (instr.arg1 = '') or (instr.arg1[1] in ['0'..'9']) then
        ErrorAndExit('Nome de variável inválido para destino da IDIV: ' + instr.arg1);

      op1IsFloat := False;
      op2IsFloat := False;

      // Processa o primeiro operando (arg2)
      if TryStrToInt(instr.arg2, tempInt) then
      begin
        op1Value := tempInt;
      end
      else if TryStrToFloat(instr.arg2, floatValue) then
      begin
        op1Value := floatValue;
        op1IsFloat := True;
      end
      else
      begin
        // É uma variável - verifica o tipo
        op1Type := FindVariableType(instr.arg2, sarr, iarr, farr, barr);
        if op1Type = 'int' then
        begin
          intVal := tempInt;
          if not FindInIntArray(iarr, instr.arg2, intVal) then
            ErrorAndExit('Variável inteira não encontrada: ' + instr.arg2);
          op1Value := intVal;
        end
        else if op1Type = 'float' then
        begin
          if not FindInFloatArray(farr, instr.arg2, floatValue) then
            ErrorAndExit('Variável float não encontrada: ' + instr.arg2);
          op1Value := floatValue;
          op1IsFloat := True;
        end
        else
          ErrorAndExit('Operando 1 inválido para IDIV: ' + instr.arg2);
      end;

      // Processa o segundo operando (arg3)
      if TryStrToInt(instr.arg3, tempInt) then
      begin
        op2Value := tempInt;
        if (op2Value = 0) then
          ErrorAndExit('Divisão por zero não é permitido.');
      end
      else if TryStrToFloat(instr.arg3, floatValue) then
      begin
        op2Value := floatValue;
        op2IsFloat := True;
      end
      else
      begin
        // É uma variável - verifica o tipo
        op2Type := FindVariableType(instr.arg3, sarr, iarr, farr, barr);
        if op2Type = 'int' then
        begin
          intVal := tempInt;
          if not FindInIntArray(iarr, instr.arg3, intVal) then
            ErrorAndExit('Variável inteira não encontrada: ' + instr.arg3);
          op2Value := intVal;
        end
        else if op2Type = 'float' then
        begin
          if not FindInFloatArray(farr, instr.arg3, floatValue) then
            ErrorAndExit('Variável float não encontrada: ' + instr.arg3);
          op2Value := floatValue;
          op2IsFloat := True;
        end
        else
          ErrorAndExit('Operando 2 inválido para IDIV: ' + instr.arg3);
      end;

      if (Round(op2Value) = 0) then
          ErrorAndExit('Divisão por zero não é permitido.');

      resultInt := Round(op1Value) div Round(op2Value);
      UpdateOrAddInt(iarr, instr.arg1, resultInt);
      WriteLn('IDIV: ', Round(op1Value), ' + ', Round(op2Value), ' = ', resultInt, ' (int)');
    end
    else if instr.op = 'MOD' then
    begin
      // Verifica se o destino (arg1) é uma variável válida (deve começar com letra)
      if (instr.arg1 = '') or (instr.arg1[1] in ['0'..'9']) then
        ErrorAndExit('Nome de variável inválido para destino da MOD: ' + instr.arg1);

      op1IsFloat := False;
      op2IsFloat := False;

      // Processa o primeiro operando (arg2)
      if TryStrToInt(instr.arg2, tempInt) then
      begin
        op1Value := tempInt;
      end
      else if TryStrToFloat(instr.arg2, floatValue) then
      begin
        op1Value := floatValue;
        op1IsFloat := True;
      end
      else
      begin
        // É uma variável - verifica o tipo
        op1Type := FindVariableType(instr.arg2, sarr, iarr, farr, barr);
        if op1Type = 'int' then
        begin
          intVal := tempInt;
          if not FindInIntArray(iarr, instr.arg2, intVal) then
            ErrorAndExit('Variável inteira não encontrada: ' + instr.arg2);
          op1Value := intVal;
        end
        else if op1Type = 'float' then
        begin
          if not FindInFloatArray(farr, instr.arg2, floatValue) then
            ErrorAndExit('Variável float não encontrada: ' + instr.arg2);
          op1Value := floatValue;
          op1IsFloat := True;
        end
        else
          ErrorAndExit('Operando 1 inválido para MOD: ' + instr.arg2);
      end;

      // Processa o segundo operando (arg3)
      if TryStrToInt(instr.arg3, tempInt) then
      begin
        op2Value := tempInt;
        if (op2Value = 0) then
          ErrorAndExit('Divisão por zero não é permitido.');
      end
      else if TryStrToFloat(instr.arg3, floatValue) then
      begin
        op2Value := floatValue;
        op2IsFloat := True;
      end
      else
      begin
        // É uma variável - verifica o tipo
        op2Type := FindVariableType(instr.arg3, sarr, iarr, farr, barr);
        if op2Type = 'int' then
        begin
          intVal := tempInt;
          if not FindInIntArray(iarr, instr.arg3, intVal) then
            ErrorAndExit('Variável inteira não encontrada: ' + instr.arg3);
          op2Value := intVal;
        end
        else if op2Type = 'float' then
        begin
          if not FindInFloatArray(farr, instr.arg3, floatValue) then
            ErrorAndExit('Variável float não encontrada: ' + instr.arg3);
          op2Value := floatValue;
          op2IsFloat := True;
        end
        else
          ErrorAndExit('Operando 2 inválido para MOD: ' + instr.arg3);
      end;

      if (Round(op2Value) = 0) then
          ErrorAndExit('Divisão por zero não é permitido.');

      resultInt := Round(op1Value) div Round(op2Value);
      UpdateOrAddInt(iarr, instr.arg1, resultInt);
      WriteLn('MOD: ', Round(op1Value), ' + ', Round(op2Value), ' = ', resultInt, ' (int)');
    end
    else if instr.op = 'LABEL' then
    begin
      if FindInLabelArray(larr, instr.arg1) = -1 then
        begin
          lnovo.fname := instr.arg1;
          lnovo.line := i;
          appendl(larr, lnovo);
        end;
    end
    else if instr.op = 'JUMP' then
    begin
      if FindInLabelArray(larr, instr.arg1) <> -1 then
          i := FindInLabelArray(larr, instr.arg1) - 1
      else
      begin
          i := FindLabelAfter(arr, instr.arg1, i) - 1;
      end;
    end
    else if instr.op = 'CALL' then
    begin
      if instr.arg1 = 'WRITE' then
      begin
        if instr.arg_type = 'string' then
          write(instr.arg2)
        else if instr.arg_type = 'var' then
        begin
          varType := FindVariableType(instr.arg2, sarr, iarr, farr, barr);
          
          // Verifica o tipo da variável e imprime seu valor
          if varType = 'string' then
          begin
            if not FindInStringArray(sarr, instr.arg2, strVal) then
              ErrorAndExit('Variável string não encontrada: ' + instr.arg2);
            write(strVal); // Imprime o valor da string
          end
          else if varType = 'int' then
          begin
            if not FindInIntArray(iarr, instr.arg2, intVal) then
              ErrorAndExit('Variável int não encontrada: ' + instr.arg2);
            write(intVal); // Imprime o valor do inteiro
          end
          else if varType = 'float' then
          begin
            if not FindInFloatArray(farr, instr.arg2, floatValue) then
              ErrorAndExit('Variável float não encontrada: ' + instr.arg2);
            write(floatValue:0:6); // Imprime o float com 2 casas decimais
          end
          else if varType = 'bool' then
          begin
            if not FindInBoolArray(barr, instr.arg2, boolVal) then
              ErrorAndExit('Variável bool não encontrada: ' + instr.arg2);
            if boolVal then
              write('true')
            else
              write('false');
          end
          else
            ErrorAndExit('Tipo de variável desconhecido: ' + varType);
        end
      end
      else if instr.arg1 = 'WRITELN' then
      begin
        if instr.arg_type = 'string' then
          writeln(instr.arg2)
        else if instr.arg_type = 'var' then
        begin
          varType := FindVariableType(instr.arg2, sarr, iarr, farr, barr);
          
          // Verifica o tipo da variável e imprime seu valor
          if varType = 'string' then
          begin
            if not FindInStringArray(sarr, instr.arg2, strVal) then
              ErrorAndExit('Variável string não encontrada: ' + instr.arg2);
            writeln(strVal); // Imprime o valor da string
          end
          else if varType = 'int' then
          begin
            if not FindInIntArray(iarr, instr.arg2, intVal) then
              ErrorAndExit('Variável int não encontrada: ' + instr.arg2);
            writeln(intVal); // Imprime o valor do inteiro
          end
          else if varType = 'float' then
          begin
            if not FindInFloatArray(farr, instr.arg2, floatValue) then
              ErrorAndExit('Variável float não encontrada: ' + instr.arg2);
            writeln(floatValue:0:6); // Imprime o float com 2 casas decimais
          end
          else if varType = 'bool' then
          begin
            if not FindInBoolArray(barr, instr.arg2, boolVal) then
              ErrorAndExit('Variável bool não encontrada: ' + instr.arg2);
            if boolVal then
              writeln('true')
            else
              writeln('false');
          end
          else
            ErrorAndExit('Tipo de variável desconhecido: ' + varType);
        end
      end
      else if instr.arg1 = 'READ' then
      begin
        varType := FindVariableType(instr.arg2, sarr, iarr, farr, barr);
        tempStr := ''; // Variável temporária para leitura
          
        // Ler a entrada do usuário
        ReadLn(tempStr);
          
        if varType = 'string' then
        begin
          UpdateOrAddString(sarr, instr.arg2, tempStr);
        end
        else if varType = 'int' then
        begin
          if TryStrToInt(tempStr, tempInt) then
            UpdateOrAddInt(iarr, instr.arg2, tempInt)
          else
            ErrorAndExit('Valor inválido para inteiro: ' + tempStr);
        end
        else if varType = 'float' then
        begin
          if TryStrToFloat(tempStr, floatValue) then
            UpdateOrAddFloat(farr, instr.arg2, floatValue)
          else
            ErrorAndExit('Valor inválido para float: ' + tempStr);
        end
        else if varType = 'bool' then
        begin
          tempStr := LowerCase(tempStr);
          if (tempStr = 'true') or (tempStr = '1') then
            UpdateOrAddBool(barr, instr.arg2, true)
          else if (tempStr = 'false') or (tempStr = '0') then
            UpdateOrAddBool(barr, instr.arg2, false)
          else
            ErrorAndExit('Valor inválido para booleano: ' + tempStr);
        end
        else
          ErrorAndExit('Tipo de variável desconhecido para READ: ' + varType);
      end
    end
    else if (instr.op = 'GRET') or (instr.op = 'GEQ') or 
        (instr.op = 'LESS') or (instr.op = 'LEQ') or
        (instr.op = 'EQ') or (instr.op = 'NEQ') then
    begin  
      // Inicializa flag
      isFloatOp := False;

      // Processa o primeiro argumento (arg2)
      if TryStrToInt(instr.arg2, tempInt) then
        intVal1 := tempInt
      else if TryStrToFloat(instr.arg2, tempFloat) then
      begin
        floatVal1 := tempFloat;
        isFloatOp := True;
      end
      else if FindInIntArray(iarr, instr.arg2, intVal1) then
        // Já atribuiu intVal1
      else if FindInFloatArray(farr, instr.arg2, floatVal1) then
        isFloatOp := True
      else
        ErrorAndExit('Valor numérico não encontrado: ' + instr.arg2);

      // Processa o segundo argumento (arg3)
      if TryStrToInt(instr.arg3, tempInt) then
        intVal2 := tempInt
      else if TryStrToFloat(instr.arg3, tempFloat) then
      begin
        floatVal2 := tempFloat;
        isFloatOp := True;
      end
      else if FindInIntArray(iarr, instr.arg3, intVal2) then
        // Já atribuiu intVal2
      else if FindInFloatArray(farr, instr.arg3, floatVal2) then
        isFloatOp := True
      else
        ErrorAndExit('Valor numérico não encontrado: ' + instr.arg3);

      // Faz a comparação
      if isFloatOp then
      begin
        // Converte tudo para float se houver pelo menos um float
        if not isFloatOp then
        begin
          floatVal1 := intVal1;
          floatVal2 := intVal2;
        end;
        if instr.op = 'LESS' then
          UpdateOrAddBool(barr, instr.arg1, floatVal1 < floatVal2)
        else if instr.op = 'LEQ' then
          UpdateOrAddBool(barr, instr.arg1, floatVal1 <= floatVal2)
        else if instr.op = 'GRET' then
          UpdateOrAddBool(barr, instr.arg1, floatVal1 > floatVal2)
        else if instr.op = 'GEQ' then
          UpdateOrAddBool(barr, instr.arg1, floatVal1 >= floatVal2)
        else if instr.op = 'EQ' then
          UpdateOrAddBool(barr, instr.arg1, floatVal1 = floatVal2)
        else
          UpdateOrAddBool(barr, instr.arg1, floatVal1 <> floatVal2)
      end
      else
      begin
        if instr.op = 'LESS' then
          UpdateOrAddBool(barr, instr.arg1, intVal1 < intVal2)
        else if instr.op = 'LEQ' then
          UpdateOrAddBool(barr, instr.arg1, intVal1 <= intVal2)
        else if instr.op = 'GRET' then
          UpdateOrAddBool(barr, instr.arg1, intVal1 > intVal2)
        else if instr.op = 'GEQ' then
          UpdateOrAddBool(barr, instr.arg1, intVal1 >= intVal2)
        else if instr.op = 'EQ' then
          UpdateOrAddBool(barr, instr.arg1, intVal1 = intVal2)
        else
          UpdateOrAddBool(barr, instr.arg1, intVal1 <> intVal2)
      end
    end
    else if instr.op = 'IF' then
    begin
      if not FindInBoolArray(barr, instr.arg1, boolVal) then
        ErrorAndExit('Variável bool não encontrada: ' + instr.arg2);

      if (not boolVal) then
      begin
        i := FindLabelAfter(arr, instr.arg3, i) - 1;

        if (i = -2) then
          ErrorAndExit('Erro de codigo intermediario: ' + instr.arg2);
      end;
    end;
    
    Inc(i);
  end;
end;

end.