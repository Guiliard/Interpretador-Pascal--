unit lexical_utils_unit;

interface

uses
    type_token_unit,
    table_token_unit,
    states_unit;

function matchToken(textToken: string; finalVar: boolean): typeToken;
function isAlpha(c: char): boolean;
function isDigit(c: char): boolean;
function isOctal(s: string): boolean;
function isDecimal(s: string): boolean;
function isHexadecimal(s: string): boolean;
function isFloat(s: string): boolean;
procedure showError(state: states; currentLine, currentColumn: Integer; textToken: String);

implementation

function matchToken(textToken: string; finalVar: boolean): typeToken;
var
    i: integer;
    match: typeToken;

begin
    for i := 0 to High(tableToken) do
    begin
        if tableToken[i].text = textToken then
        begin
            match := tableToken[i].token;
            Exit(match);
        end;
    end;

    if finalVar then
    begin
        Exit(_VARIABLE_);
    end

    else 
    begin
        if (isOctal(textToken)) then
        begin
            Exit(_OCTAL_);
        end

        else 
        if (isDecimal(textToken)) then
        begin
            Exit(_DECIMAL_);
        end

        else 
        if (isHexadecimal(textToken)) then
        begin
            Exit(_HEXADECIMAL_);
        end

        else 
        if (isFloat(textToken)) then
        begin
            Exit(_FLOAT_);
        end
        
        else 
        begin
            Exit(_INVALID_TOKEN_);
        end;
    end;
end;

function IsAlpha(c: char): boolean;
var
    alpha: boolean;

begin
    alpha := ((c >= 'A') and (c <= 'Z')) or ((c >= 'a') and (c <= 'z'));
    Exit(alpha);
end;

function isDigit(c: char): boolean;
var 
    digit: boolean;

begin
    digit := (c >= '0') and (c <= '9');
    Exit(digit);
end;

function IsOctal(s: string): boolean;
var
    i: Integer;
    octal: boolean;

begin
    octal := False;
    if (Length(s) < 2) or (s[1] <> '0') then 
    begin
        Exit;
    end;

    for i := 2 to Length(s) do
    if not (s[i] in ['0'..'7']) then 
    begin
        Exit;
    end;
    octal := True;
    Exit(octal);
end;

function IsDecimal(s: string): boolean;
var
    i: Integer;
    decimal: boolean;

begin
    decimal := False;
    if (Length(s) < 1) or not (s[1] in ['1'..'9']) then 
    begin
        Exit;
    end;

    for i := 2 to Length(s) do
    if not (s[i] in ['0'..'9']) then 
    begin
        Exit;
    end;
    decimal := True;
    Exit(decimal);
end;

function IsHexadecimal(s: string): boolean;
var
    i: Integer;
    hexadecimal: boolean;

begin
    hexadecimal := False;
    if (Length(s) < 3) or (s[1] <> '0') or (s[2] <> 'x') then 
    begin
        Exit;
    end;

    for i := 3 to Length(s) do
    if not (s[i] in ['0'..'9', 'A'..'F', 'a'..'f']) then 
    begin
        Exit;
    end;
    hexadecimal := True;
    Exit(hexadecimal);
end;

function IsFloat(s: string): boolean;
var
    i, dotCount: Integer;
    hasDigitBeforeDot, hasDigitAfterDot: Boolean;

begin
    dotCount := 0;
    hasDigitBeforeDot := False;
    hasDigitAfterDot := False;

    if Length(s) < 3 then
    begin
        Exit(False);
    end;

    for i := 1 to Length(s) do
    begin
        if s[i] = '.' then
        begin
            Inc(dotCount);
            if dotCount > 1 then
                Exit(False);
        end
        else if s[i] in ['0'..'9'] then
        begin
            if dotCount = 0 then
                hasDigitBeforeDot := True
            else
                hasDigitAfterDot := True;
        end
        else
        begin
            Exit(False);
        end;
    end;

    if (dotCount = 1) and hasDigitBeforeDot and hasDigitAfterDot then
        Exit(True)
    else
        Exit(False);
end;

procedure showError(state: states; currentLine, currentColumn: Integer; textToken: String);
begin
    case state of
        _BLOCK_COMMENT_:
            writeln(#10, 'Lexical Error: Unexpected end of file at line ', currentLine, ', column ', currentColumn, '. The block comment is not closed.', #10);

        _STRING_:
            writeln(#10, 'Lexical Error: Unexpected end of file at line ', currentLine, ', column ', currentColumn, '. The string is not closed.', #10);

        _FINAL_NUMBER_:
            writeln(#10, 'Lexical Error: Unexpected token at line ', currentLine, ', column ', currentColumn, '. The number "', textToken, '" is not valid.', #10);
    end;
end;

end.