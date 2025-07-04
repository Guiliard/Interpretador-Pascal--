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
  isAtt := (op = 'ATT');
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
  line := Trim(line);
  if (line <> '') and (line[1] = '(') then Delete(line, 1, 1);
  if (line <> '') and (line[Length(line)] = ')') then Delete(line, Length(line), 1);

  p := 1;
  token := '';
  inSingleQuotes := False;
  inDoubleQuotes := False;

  i := 1;
  while i <= Length(line) do
  begin
    c := line[i];

    if c = '''' then
      inSingleQuotes := not inSingleQuotes
    else if c = '"' then
      inDoubleQuotes := not inDoubleQuotes
    else if (c = ',') and (not inSingleQuotes) and (not inDoubleQuotes) then
    begin
      raw_parts[p] := Trim(token);
      token := '';
      Inc(p);
    end
    else
      token := token + c;

    Inc(i);
  end;

  if p <= 4 then
    raw_parts[p] := Trim(token);

  for i := 1 to 4 do
    parts[i] := raw_parts[i];

  // Determine argument type for ATT instructions
  if isAtt(UpperCase(parts[1])) then
  begin
    if (Length(raw_parts[3]) > 1) and (raw_parts[3][1] = '''') and (raw_parts[3][Length(raw_parts[3])] = '''') then
    begin
      // Case 4: ('att','na','2',none) - char
      splitLine.arg_type := 'char';
    end
    else if (Length(raw_parts[3]) > 1) and (raw_parts[3][1] = '"') and (raw_parts[3][Length(raw_parts[3])] = '"') then
    begin
      // Case 1 and 5: ("abcdefghi none , , ahgshgsh") or ("265") - string
      splitLine.arg_type := 'string';
    end
    else if isNumeric(raw_parts[3], isFloat) then
    begin
      if isFloat then
        // Case 2: 26.7 - float
        splitLine.arg_type := 'float'
      else
        // Case 3: 2 - integer
        splitLine.arg_type := 'integer';
    end
    else
      splitLine.arg_type := 'none';
  end
  else
    splitLine.arg_type := 'none';

  // Remove quotes from values but keep the content
  for i := 1 to 4 do
  begin
    if (Length(parts[i]) > 1) and ((parts[i][1] = '''') and (parts[i][Length(parts[i])] = '''')) then
      parts[i] := Copy(parts[i], 2, Length(parts[i]) - 2)
    else if (Length(parts[i]) > 1) and ((parts[i][1] = '"') and (parts[i][Length(parts[i])] = '"')) then
      parts[i] := Copy(parts[i], 2, Length(parts[i]) - 2);
  end;

  splitLine.instr.op := UpperCase(parts[1]);
  splitLine.instr.arg1 := parts[2];
  splitLine.instr.arg2 := parts[3];
  splitLine.instr.arg3 := parts[4];
  splitLine.instr.arg_type := splitLine.arg_type;
end;

function analyzeItm(content: AnsiString): ItmArray;
var
  lines: TStringList;
  i: integer;
  line: string;
  res: ItmSplitResult;
  instr: ItmInstruction;
begin
  SetLength(analyzeItm, 0);

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

    append(analyzeItm, instr);
  end;
  
  lines.Free;
end;

end.