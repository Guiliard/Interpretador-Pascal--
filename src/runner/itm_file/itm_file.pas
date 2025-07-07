unit itm_file_unit;

interface

uses 
    intermediate_code_unit,
    SysUtils,
    StrUtils,
    proc_unit;

procedure saveIntermediateCodeAsTupleFormat(const filename: string; const codeArray: arrayCode);
function isNumeric(const s: string): Boolean;

implementation

procedure saveIntermediateCodeAsTupleFormat(const filename: string; const codeArray: arrayCode);
var
  f: Text;
  i: Integer;
  code_type_, op1_, op2_, op3_, op_type_: string;
begin
  Assign(f, filename);
  Rewrite(f);

  for i := 0 to High(codeArray) do
  begin
    with codeArray[i] do
    begin
      code_type_ := code_type;
      op1_ := op1; if op1_ = '' then op1_ := 'none';
      op2_ := op2; if op2_ = '' then op2_ := 'none';
      op3_ := op3; if op3_ = '' then op3_ := 'none';
      op_type_ := op_type;

      if (code_type_ = 'ASSIGN') and ((op_type_ = 'integer') or (op_type_ = 'float')) then
      begin
        WriteLn(f, '(', 
          '''', code_type, '''', ',',
          '''', op1_, '''', ',',
          '', op2_, '', ',',
          '''', op3_, '''', ')'
        );    
      end
      else 
      if (code_type = 'ASSIGN') and (op_type_ = 'string') then
      begin
        WriteLn(f, '(', 
          '''', code_type, '''', ',',
          '''', op1_, '''', ',',
          '"', op2_, '"', ',',
          '''', op3_, '''', ')'
        );    
      end
      else 
      begin
        // For other types of operations, we can use the same format
        WriteLn(f, '(', 
          '''', code_type_, '''', ',',
          '''', op1_, '''', ',',
          '''', op2_, '''', ',',
          '''', op3_, '''', ')'
        );
      end;
    end;
  end;

  Close(f);
end;

function isNumeric(const s: string): Boolean;
var
  dummy: Double;
begin
  Exit(TryStrToFloat(s, dummy));
end;

end.
