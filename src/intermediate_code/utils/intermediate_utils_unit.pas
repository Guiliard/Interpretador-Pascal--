unit intermediate_utils_unit;

interface 

uses 
    intermediate_code_unit,
    SysUtils;

function genATT(salvo, valor: string): intermediate_code;
function genSUB(salvo, op1, op2: string): intermediate_code;
function genADD(salvo, op1, op2: string): intermediate_code;
function genIF(cond, labelVdd, labelFalso: string): intermediate_code;
function genJUMP(label_: string): intermediate_code;
function genLABEL(nomeLabel: string): intermediate_code;

function genEQ(salvo, op1, op2: string): intermediate_code;
function genNEQ(salvo, op1, op2: string): intermediate_code;
function genLEQ(salvo, op1, op2: string): intermediate_code;
function genLESS(salvo, op1, op2: string): intermediate_code;
function genGEQ(salvo, op1, op2: string): intermediate_code;
function genGRET(salvo, op1, op2: string): intermediate_code;

function genMULT(salvo, op1, op2: string): intermediate_code;
function genRDIV(salvo, op1, op2: string): intermediate_code;
function genIDIV(salvo, op1, op2: string): intermediate_code;
function genMOD(salvo, op1, op2: string): intermediate_code;

function genCALL_READ(salvo: string): intermediate_code;
function genCALL_WRITE(escrito: string): intermediate_code;

function genOR(salvo, op1, op2: string): intermediate_code;
function genAND(salvo, op1, op2: string): intermediate_code;
function genNOT(salvo, op1: string): intermediate_code;

procedure printArrayCode(arrayCode: intermediate_code_array);
procedure addIntermediateCode(var arrayCode: intermediate_code_array; code: intermediate_code);
procedure updateIntermediateCode(var arrayCode: intermediate_code_array; i: Integer; valor: string; opType: string);

function genNewTemp(var flagNewTemp: Integer): string;

implementation

function newCode(code_type, op1, op2, op3, op_type: string): intermediate_code;
var 
    code: intermediate_code;
begin
    code.code_type := code_type;
    code.op1 := op1;
    code.op2 := op2;
    code.op3 := op3;
    code.op_type := op_type;
    Exit(code);
end;

function genATT(salvo, valor: string): intermediate_code;
var 
    code: intermediate_code;
begin
    code := newCode('ATT', salvo, valor, 'NONE', '');
    Exit(code);
end;

function genSUB(salvo, op1, op2: string): intermediate_code;
var 
    code: intermediate_code;
begin
    code := newCode('SUB', salvo, op1, op2, '');
    Exit(code);
end;

function genADD(salvo, op1, op2: string): intermediate_code;
var 
    code: intermediate_code;
begin
    code := newCode('ADD', salvo, op1, op2, '');
    Exit(code);
end;

function genIF(cond, labelVdd, labelFalso: string): intermediate_code;
var 
    code: intermediate_code;
begin
    code := newCode('IF', cond, labelVdd, labelFalso, '');
    Exit(code);
end;

function genJUMP(label_: string): intermediate_code;
var 
    code: intermediate_code;
begin
    code := newCode('JUMP', label_, 'NONE', 'NONE', '');
    Exit(code);
end;

function genLABEL(nomeLabel: string): intermediate_code;
var 
    code: intermediate_code;
begin
    code := newCode('LABEL', nomeLabel, 'NONE', 'NONE', '');
    Exit(code);
end;

function genEQ(salvo, op1, op2: string): intermediate_code;
var 
    code: intermediate_code;
begin
    code := newCode('EQ', salvo, op1, op2, '');
    Exit(code);
end;

function genNEQ(salvo, op1, op2: string): intermediate_code;
var 
    code: intermediate_code;
begin
    code := newCode('NEQ', salvo, op1, op2, '');
    Exit(code);
end;

function genLEQ(salvo, op1, op2: string): intermediate_code;
var 
    code: intermediate_code;
begin
    code := newCode('LEQ', salvo, op1, op2, '');
    Exit(code);
end;

function genLESS(salvo, op1, op2: string): intermediate_code;
var 
    code: intermediate_code;
begin
    code := newCode('LESS', salvo, op1, op2, '');
    Exit(code);
end;

function genGEQ(salvo, op1, op2: string): intermediate_code;
var 
    code: intermediate_code;
begin
    code := newCode('GEQ', salvo, op1, op2, '');
    Exit(code);
end;

function genGRET(salvo, op1, op2: string): intermediate_code;
var 
    code: intermediate_code;
begin
    code := newCode('GRET', salvo, op1, op2, '');
    Exit(code);
end;

function genMULT(salvo, op1, op2: string): intermediate_code;
var 
    code: intermediate_code;
begin
    code := newCode('MULT', salvo, op1, op2, '');
    Exit(code);
end;

function genRDIV(salvo, op1, op2: string): intermediate_code;
var 
    code: intermediate_code;
begin
    code := newCode('REAL_DIV', salvo, op1, op2, '');
    Exit(code);
end;

function genIDIV(salvo, op1, op2: string): intermediate_code;
var 
    code: intermediate_code;
begin
    code := newCode('INTER_DIV', salvo, op1, op2, '');
    Exit(code);
end;

function genMOD(salvo, op1, op2: string): intermediate_code;
var 
    code: intermediate_code;
begin
    code := newCode('MOD', salvo, op1, op2, '');
    Exit(code);
end;

function genCALL_READ(salvo: string): intermediate_code;
var 
    code: intermediate_code;
begin
    code := newCode('CALL', 'READ', salvo, 'NONE', '');
    Exit(code);
end;

function genCALL_WRITE(escrito: string): intermediate_code;
var 
    code: intermediate_code;
begin
    code := newCode('CALL', 'WRITE', escrito, 'NONE', '');
    Exit(code);
end;

function genOR(salvo, op1, op2: string): intermediate_code;
var 
    code: intermediate_code;
begin
    code := newCode('OR', salvo, op1, op2, '');
    Exit(code);
end;

function genAND(salvo, op1, op2: string): intermediate_code;
var 
    code: intermediate_code;
begin
    code := newCode('AND', salvo, op1, op2, '');
    Exit(code);
end;

function genNOT(salvo, op1: string): intermediate_code;
var 
    code: intermediate_code;
begin
    code := newCode('NOT', salvo, op1, 'NONE', '');
    Exit(code);
end;

procedure printArrayCode(arrayCode: intermediate_code_array);
var 
    i: Integer;
begin
    for i := 0 to High(arrayCode) do
    begin
        write('Code Type: ', arrayCode[i].code_type, ' | ');
        write('Op1: ', arrayCode[i].op1, ' | ');
        write('Op2: ', arrayCode[i].op2, ' | ');
        write('Op3: ', arrayCode[i].op3, ' | ');
        writeln('Op Type: ', arrayCode[i].op_type); 
    end;
end;

procedure addIntermediateCode(var arrayCode: intermediate_code_array; code: intermediate_code);
begin
    SetLength(arrayCode, Length(arrayCode) + 1);
    arrayCode[High(arrayCode)] := code;
end;

procedure updateIntermediateCode(var arrayCode: intermediate_code_array; i: Integer; valor: string; opType: string);
begin
    if (i >= 0) and (i < Length(arrayCode)) then
    begin
        arrayCode[i].op2 := valor;
        arrayCode[i].op_type := opType;
    end
end;

function genNewTemp(var flagNewTemp: Integer): string;
var
    str: string;
begin
    Inc(flagNewTemp);
    str := 'TEMP' + IntToStr(flagNewTemp);
    Exit(str);
end;

end.