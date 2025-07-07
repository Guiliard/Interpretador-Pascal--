unit intermediate_utils_unit;

interface 

uses 
    intermediate_code_unit,
    type_token_unit,
    lexeme_unit,
    SysUtils;

const
    // Operation types
    OP_ASSIGN = 'ASSIGN';
    OP_ADD = 'ADD';
    OP_SUB = 'SUB';
    OP_MUL = 'MUL';
    OP_DIV = 'DIV';
    OP_IDIV = 'IDIV';
    OP_MOD = 'MOD';
    OP_AND = 'AND';
    OP_OR = 'OR';
    OP_NOT = 'NOT';
    OP_EQ = 'EQ';
    OP_NE = 'NEQ';
    OP_LT = 'LESS';
    OP_LE = 'LEQ';
    OP_GT = 'GRET';
    OP_GE = 'GEQ';
    OP_WRITE = 'WRITE';
    OP_READ = 'READ';
    OP_LABEL = 'LABEL';
    OP_IF = 'IF';
    OP_JUMP = 'JUMP';
    OP_FOR = 'FOR';
    OP_WHILE = 'WHILE';

type
    TIntermediateCodeArray = array of intermediate_code;

function buildOperationCode(opType: string; dest: string; op1: string; op2: string; operandType: string): intermediate_code;
function buildAssignCode(varName: string; value: string; varType: string): intermediate_code;
function buildWriteCode(value: string; valueType: string): intermediate_code;
function buildReadCode(varName: string): intermediate_code;
function buildLabelCode(labelName: string): intermediate_code;
function buildIfCode(condition: string; thenLabel: string; elseLabel: string): intermediate_code;
function buildJumpCode(labelName: string): intermediate_code;
procedure addIntermediateCode(var arrayIntermediateCode: TIntermediateCodeArray; const newCode: intermediate_code);
function newTemp(): string;
function newLabel(): string;
procedure printIntermediateCode(const codeArray: TIntermediateCodeArray);



implementation

var
  tempCount: Integer = 0;
  labelCount: Integer = 0;

function buildOperationCode(opType: string; dest: string; op1: string; op2: string; operandType: string): intermediate_code;
var
  code: intermediate_code;
begin
  code.code_type := opType;
  code.op1 := dest;
  code.op2 := op1;
  code.op3 := op2;
  code.op_type := operandType;
  buildOperationCode := code;
end;

function buildAssignCode(varName: string; value: string; varType: string): intermediate_code;
begin
  buildAssignCode := buildOperationCode(OP_ASSIGN, varName, value, '', varType);
end;

function buildWriteCode(value: string; valueType: string): intermediate_code;
begin
  buildWriteCode := buildOperationCode(OP_WRITE, '', value, '', valueType);
end;

function buildReadCode(varName: string): intermediate_code;
begin
  buildReadCode := buildOperationCode(OP_READ, varName, '', '', 'var');
end;

function buildLabelCode(labelName: string): intermediate_code;
begin
  buildLabelCode := buildOperationCode(OP_LABEL, labelName, '', '', 'none');
end;

function buildIfCode(condition: string; thenLabel: string; elseLabel: string): intermediate_code;
begin
  buildIfCode := buildOperationCode(OP_IF, condition, thenLabel, elseLabel, 'none');
end;

function buildJumpCode(labelName: string): intermediate_code;
begin
  buildJumpCode := buildOperationCode(OP_JUMP, labelName, '', '', 'none');
end;

procedure addIntermediateCode(var arrayIntermediateCode: TIntermediateCodeArray; const newCode: intermediate_code);
begin
  SetLength(arrayIntermediateCode, Length(arrayIntermediateCode) + 1);
  arrayIntermediateCode[High(arrayIntermediateCode)] := newCode;
end;

function newTemp(): string;
begin
  Inc(tempCount);
  newTemp := 't' + IntToStr(tempCount);
end;

function newLabel(): string;
begin
  Inc(labelCount);
  newLabel := 'L' + IntToStr(labelCount);
end;

procedure printIntermediateCode(const codeArray: TIntermediateCodeArray);
var
  i: Integer;
begin
  writeln(#10, '=== CÓDIGO INTERMEDIÁRIO GERADO ===');
  for i := 0 to High(codeArray) do
  begin
    with codeArray[i] do
    begin
      case code_type of
        OP_ASSIGN: writeln('ASSIGN ', op1, ' := ', op2, ' (Type: ', op_type, ')');
        OP_ADD:    writeln('ADD    ', op1, ', ', op2, ' -> ', op3);
        OP_SUB:    writeln('SUB    ', op1, ', ', op2, ' -> ', op3);
        OP_MUL:    writeln('MUL    ', op1, ', ', op2, ' -> ', op3);
        OP_LABEL:  writeln('LABEL  ', op1);
        OP_IF:     writeln('IF     ', op1, ' THEN GOTO ', op2, ' ELSE GOTO ', op3);
        OP_JUMP:   writeln('JUMP   ', op3);
        // Adicione outros casos conforme necessário (WRITE, READ, etc.)
        else       writeln(code_type, ' ', op1, ', ', op2, ', ', op3, ' (Type: ', op_type, ')');
      end;
    end;
  end;
  writeln('=================================', #10);
end;

end.