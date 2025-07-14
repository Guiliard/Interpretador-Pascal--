unit itm_analyzer;

interface

uses
  SysUtils, Classes, StrUtils;

type
  ItmInstruction = record
    op: string;
    arg1: string;
    arg2: string;
    arg3: string;
    arg_type: string;  // 'char', 'string', 'integer', 'float', or 'none'
  end;

  ItmArray = array of ItmInstruction;

var
  instructions: ItmArray;

function isAtt(op: string): boolean;
function isCwrite(op: string; op2: string): boolean;
procedure append(var arr: ItmArray; instr: ItmInstruction);
function analyzeItm(content: AnsiString): ItmArray;

implementation

procedure append(var arr: ItmArray; instr: ItmInstruction);
var
  n: integer;
begin
  n := Length(arr);
  SetLength(arr, n + 1);
  arr[n] := instr;
end;

function isAtt(op: string): boolean;
begin
  isAtt := (op = 'ASSIGN');
end;

function isCwrite(op: string; op2: string): boolean;
begin
  isCwrite := (op = 'CALL') and (op2 = 'WRITE');
end;

function isNumeric(s: string; var isFloat: boolean): boolean;
var
  i: integer;
  hasDecimal: boolean;
begin
  isNumeric := True;
  hasDecimal := False;
  isFloat := False;
  
  if s = '' then
  begin
    isNumeric := False;
    Exit;
  end;
    
  // Check for negative number
  if s[1] = '-' then
    s := Copy(s, 2, Length(s));
    
  for i := 1 to Length(s) do
  begin
    if s[i] = '.' then
    begin
      if hasDecimal then  // More than one decimal point
      begin
        isNumeric := False;
        Exit;
      end;
      hasDecimal := True;
      isFloat := True;
    end
    else if not (s[i] in ['0'..'9']) then
    begin
      isNumeric := False;
      Exit;
    end;
  end;
end;

type
  ItmSplitResult = record
    instr: ItmInstruction;
    arg_type: string;  // 'char', 'string', 'integer', 'float', or 'none'
  end;

function splitLine(line: string): ItmSplitResult;
var
  parts: array[1..4] of string;
  raw_parts: array[1..4] of string;
  i, p: integer;
  c: char;
  token: string;
  inSingleQuotes, inDoubleQuotes: boolean;
  isFloat: boolean;
begin
  // Inicialização
  for i := 1 to 4 do
  begin
    parts[i] := '';
    raw_parts[i] := '';
  end;

  // Limpeza da linha
  line := Trim(line);
  if (line <> '') and (line[1] = '(') then Delete(line, 1, 1);
  if (line <> '') and (line[Length(line)] = ')') then Delete(line, Length(line), 1);

  // Parsing da linha
  p := 1;
  token := '';
  inSingleQuotes := False;
  inDoubleQuotes := False;

  for i := 1 to Length(line) do
  begin
    c := line[i];

    if c = '''' then
    begin
      inSingleQuotes := not inSingleQuotes;
      token := token + c;
    end
    else if c = '"' then
    begin
      inDoubleQuotes := not inDoubleQuotes;
      token := token + c;
    end
    else if (c = ',') and (not inSingleQuotes) and (not inDoubleQuotes) then
    begin
      raw_parts[p] := Trim(token);
      token := '';
      Inc(p);
    end
    else
      token := token + c;
  end;

  // Último token
  if (p <= 4) and (token <> '') then
    raw_parts[p] := Trim(token);

  // Copia para parts
  for i := 1 to 4 do
    parts[i] := raw_parts[i];

  // Determinação do tipo
  splitLine.arg_type := 'none'; // padrão
  
  if (Length(parts[3]) >= 2) then
  begin
    if (parts[3][1] = '"') and (parts[3][Length(parts[3])] = '"') then
      splitLine.arg_type := 'string'
    else if (parts[3][1] = '''') and (parts[3][Length(parts[3])] = '''') then
      splitLine.arg_type := 'var';
  end
  else if isNumeric(parts[3], isFloat) then
  begin
    if isFloat then
      splitLine.arg_type := 'float'
    else
      splitLine.arg_type := 'integer';
  end;

  // Remove aspas mantendo conteúdo
  for i := 1 to 4 do
  begin
    if (Length(parts[i]) >= 2) then
    begin
      if (parts[i][1] in ['''', '"']) and (parts[i][Length(parts[i])] = parts[i][1]) then
        parts[i] := Copy(parts[i], 2, Length(parts[i]) - 2);
    end;
  end;

  // Preenche a estrutura de retorno
  splitLine.instr.op := UpperCase(parts[1]);
  splitLine.instr.arg1 := parts[2];
  splitLine.instr.arg2 := parts[3];
  splitLine.instr.arg3 := parts[4];
end;

function analyzeItm(content: AnsiString): ItmArray;
var
  lines: TStringList;
  i: integer;
  line: string;
  res: ItmSplitResult;
  instr: ItmInstruction;
  resultArray: ItmArray;
begin
  SetLength(resultArray, 0);

  lines := TStringList.Create;
  lines.Text := content;

  for i := 0 to lines.Count - 1 do
  begin
    line := Trim(lines[i]);
    if line = '' then
      Continue;

    res := splitLine(line);
    instr := res.instr;
    instr.arg_type := res.arg_type;

    append(resultArray, instr);
  end;
  
  lines.Free;
  Exit(resultArray);
end;


end.