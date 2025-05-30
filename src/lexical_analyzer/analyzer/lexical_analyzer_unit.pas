unit lexical_analyzer_unit;

interface

uses
    lexeme_unit, 
    table_token_unit,
    type_token_unit,
    states_unit,
    lexical_utils_unit;

function lexicalAnalyzer(programPmm: AnsiString): lexeme_array;

implementation

function lexicalAnalyzer(programPmm: AnsiString): lexeme_array;

const
    finalVarset: set of char = ['+', '-', '*', '/', ';', ',', '.', ':', '(', ')'];
    logicSymbolset: set of char = ['=', '<', '>', ':'];
    initalset: set of char = [' ', #9, #13, #10];
    numericset: set of char = ['0'..'9', 'A'..'F', 'a'..'f', 'x', '.'];

var 
    textToken: AnsiString;
    currentLexeme: lexeme;
    currentLine: integer;
    currentColumn: integer;
    difference: integer;
    lengthProgram: integer;
    i: integer;
    state: states;
    lexemeList: lexeme_array;

begin
    lengthProgram := length(programPmm) + 1;
    state := states._INITIAL_;
    textToken := '';
    currentLine := 1;
    currentColumn := 1;
    i := 1;
    setLength(lexemeList, 0);

    while i <= lengthProgram do
    begin

        case state of

            states._INITIAL_:
            begin
                if (i = lengthProgram) then
                begin
                    currentLexeme := createLexeme('', type_token_unit._END_OF_FILE_, currentLine, currentColumn);
                    setLength(lexemeList, length(lexemeList) + 1);
                    lexemeList[length(lexemeList) - 1] := currentLexeme;
                    break;
                end

                else 
                if (programPmm[i] in initalset) then
                begin
                    if programPmm[i] = #10 then
                    begin
                        difference := i;
                        Inc(currentLine);
                    end;
                    Inc(i);
                    state := states._INITIAL_;
                end

                else 
                if (programPmm[i] = '/') and (programPmm[i+1] = '/') then    
                begin 
                    inc(i, 2);
                    state := states._SIMPLE_COMMENT_;
                end

                else 
                if (programPmm[i] = '{') then
                begin
                    inc(i);
                    state := states._BLOCK_COMMENT_;
                end

                else 
                if (programPmm[i] in logicSymbolset) then
                begin
                    textToken := textToken + programPmm[i];
                    currentColumn := i - difference;
                    inc(i);
                    state := states._LOGIC_SIMBOL_;
                end

                else 
                if (programPmm[i] in finalVarset) then
                begin
                    textToken := textToken + programPmm[i];
                    currentColumn := i - difference;
                    inc(i);
                    state := states._FINAL_VAR_;
                end

                else 
                if (isAlpha(programPmm[i])) then
                begin
                    textToken := textToken + programPmm[i];
                    currentColumn := i - difference;
                    inc(i);
                    state := states._ALPHABETIC_;
                end

                else 
                if (isDigit(programPmm[i])) then
                begin
                    textToken := textToken + programPmm[i];
                    currentColumn := i - difference;
                    inc(i);
                    state := states._NUMERIC_;
                end

                else 
                if (programPmm[i] = '"') then
                begin
                    textToken := textToken + programPmm[i];
                    currentColumn := i - difference;
                    inc(i);
                    state := states._STRING_;
                end;
            end;

            states._SIMPLE_COMMENT_:
            begin
                if (programPmm[i] <> #10) then
                begin
                    inc(i);
                    state := states._SIMPLE_COMMENT_;
                end

                else
                begin 
                    difference := i;
                    inc(i);
                    inc(currentLine);
                    state := states._INITIAL_;
                end;
            end;

            states._BLOCK_COMMENT_:
            begin
                if (i = lengthProgram) then
                begin
                    showErrorLexical(state, currentLine, currentColumn, textToken);
                    state := states._ERROR_;
                end 

                else 
                if (programPmm[i] <> '}') then
                begin
                    if (programPmm[i] = #10) then
                    begin
                        inc(currentLine);
                        difference := i;
                    end;
                    inc(i);
                    state := states._BLOCK_COMMENT_;
                end

                else 
                if (programPmm[i] = '}') then
                begin 
                    inc(i);
                    state := states._INITIAL_;
                end;
            end;

            states._LOGIC_SIMBOL_:
            begin
                if (programPmm[i] = '=') or ((textToken = '<') and (programPmm[i] = '>')) then
                begin
                    textToken := textToken + programPmm[i];
                    inc(i);
                    state := states._FINAL_VAR_;
                end

                else 
                begin 
                    state := states._FINAL_VAR_;
                end;
            end;

            states._ALPHABETIC_:
            begin
                if (isAlpha(programPmm[i]) or isDigit(programPmm[i])) then
                begin
                    textToken := textToken + programPmm[i];
                    inc(i);
                    state := states._ALPHABETIC_;
                end

                else
                begin
                    state := states._FINAL_VAR_;
                end;
            end;

            states._NUMERIC_:
            begin
                if (programPmm[i] in numericset) then
                begin
                    textToken := textToken + programPmm[i];
                    inc(i);
                    state := states._NUMERIC_;
                end

                else
                begin
                    state := states._FINAL_NUMBER_;
                end;
            end;

            states._STRING_:
            begin
                if (i = lengthProgram) then
                begin
                    showErrorLexical(state, currentLine, currentColumn, textToken);
                    state := states._ERROR_;
                end

                else 
                if (programPmm[i] <> '"') then
                begin
                    textToken := textToken + programPmm[i];
                    inc(i);
                    state := states._STRING_;
                end
                
                else 
                if (programPmm[i] = '"') then
                begin
                    textToken := textToken + programPmm[i];
                    inc(i);
                    state := states._FINAL_STRING_;
                end;
            end;

            states._FINAL_VAR_:
            begin
                currentLexeme := createLexeme(textToken, matchToken(textToken, True), currentLine, currentColumn);
                setLength(lexemeList, length(lexemeList) + 1);
                lexemeList[length(lexemeList) - 1] := currentLexeme;
                textToken := '';
                state := states._INITIAL_;
            end;

            states._FINAL_NUMBER_:
            begin
                currentLexeme := createLexeme(textToken, matchToken(textToken, False), currentLine, currentColumn);
                setLength(lexemeList, length(lexemeList) + 1);
                lexemeList[length(lexemeList) - 1] := currentLexeme;
                if (matchToken(textToken, False) = type_token_unit._INVALID_TOKEN_) then
                begin
                    showErrorLexical(state, currentLine, currentColumn, textToken);
                    state := states._ERROR_;
                end
                else 
                begin
                    textToken := '';
                    state := states._INITIAL_;
                end;
            end;

            states._FINAL_STRING_:
            begin
                currentLexeme := createLexeme(textToken, type_token_unit._STRING_LITERAL_, currentLine, currentColumn);
                setLength(lexemeList, length(lexemeList) + 1);
                lexemeList[length(lexemeList) - 1] := currentLexeme;
                textToken := '';
                state := states._INITIAL_;
            end;

            states._ERROR_:
            begin
                Halt(1);
            end;
        end;
    end;

    Exit(lexemeList);
end;

end.