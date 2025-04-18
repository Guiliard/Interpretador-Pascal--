unit analyzer;

interface

uses
    lexeme, 
    table_token,
    states,
    match;

type 
    lexeme_array = array of lexeme;

function analyzer(programPmm: string): lexeme_array;

implementation

function analyzer(programPmm: string): lexeme_array;

var 
    textToken: string;
    currentLexeme: lexeme;
    currentLine: integer;
    currentColumn: integer;
    lenghtProgram: integer;
    i: integer;
    state: integer;
    lexemeList: lexeme_array;

begin
    lenghtProgram = length(programPmm);
    state = states._INITIAL_;
    textToken = '';
    currentLine = 1;
    currentColumn = 1;
    i = 1;
    setLength(lexemeList, 0);

    while i <= lenghtProgram do

        case state of

            states._INITIAL_:
            begin

                if (i == lenghtProgram) then
                begin
                    currentLexeme := createLexeme('', type_token._END_OF_FILE_, currentLine, currentColumn);
                    setLength(lexemeList, length(lexemeList) + 1);
                    lexemeList[length(lexemeList) - 1] := currentLexeme;
                    break;
                end;

                else if (programPmm[i] = '\t') or (programPmm[i] = '\r') or (programPmm[i] = '\n') or (programPmm[i] = ' ') then
                begin
                    if (programPmm[i] = '\n') then
                    begin
                        inc(currentLine);
                        currentColumn := 1;
                    end;
                    inc(i);
                    inc(currentColumn);
                    state := states._INITIAL_;
                end;

                else if (programPmm[i] = '/') and (programPmm[i+1] = '/') then    
                begin 
                    inc(i, 2);
                    inc (currentColumn, 2);
                    state := states._SIMPLE_COMMENT_;
                end;

                else if (programPmm[i] = '{') then
                begin
                    inc(i);
                    inc(currentColumn);
                    state := states._BLOCK_COMMENT_;
                end;

                else if (programPmm[i] = '=') or (programPmm[i] = '<') or (programPmm[i] = '>') or (programPmm[i] = ':') then
                begin
                    textToken = textToken + programPmm[i];
                    inc(i);
                    inc(currentColumn);
                    state := states._LOGIC_SIMBOL_;
                end;

            end;

            states._SIMPLE_COMMENT_:
            begin
                if (programPmm[i] <> '\n') then
                begin
                    inc(i);
                    inc(currentColumn);
                    state := states._SIMPLE_COMMENT_;
                end;

                else if (programPmm[i] = '\n') then
                begin 
                    inc(i);
                    inc(currentLine);
                    currentColumn := 1;
                    state := states._INITIAL_;
                end;
            end;

            states._BLOCK_COMMENT_:
            begin 
                if (programPmm[i] <> '}') then
                begin
                    if (programPmm[i] = '\n') then
                    begin
                        inc(currentLine);
                        currentColumn := 1;
                    end;
                    inc(i);
                    inc(currentColumn);
                    state := states._BLOCK_COMMENT_;
                end;

                else if (programPmm[i] = '}') then
                begin 
                    inc(i);
                    inc(currentColumn);
                    state := states._INITIAL_;
                end;

                else if (i == lenghtProgram) then
                begin
                    writeln('Error: Unexpected end of file at line ', currentLine, ', column ', currentColumn. ' The block comment is not closed.');
                    state := states._ERROR_;
                end;
            end;

            states._LOGIC_SIMBOL_:
            begin
                if (programPmm[i] = '=') or ((textToken = '<') and (programPmm[i] = '>')) then
                begin
                    textToken := textToken + programPmm[i];
                    inc(i);
                    inc(currentColumn);
                    state := states._FINAL;
                end;

                else if (programPmm[i] <> '=') and (programPmm[i] <> '>') then
                begin 
                    state := states._FINAL;
                end; 

                else if (textToken <> '<') and (programPmm[i] = '>') then
                begin
                    textToken := textToken + programPmm[i];
                    currentLexeme := createLexeme(textToken, type_token._INVALID_TOKEN_, currentLine, currentColumn);
                    setLength(lexemeList, length(lexemeList) + 1);
                    lexemeList[length(lexemeList) - 1] := currentLexeme;
                    writeln('Error: Unexpected character at line ', currentLine, ', column ', currentColumn. ' The token ', textToken, 'is not valid.');
                    state := states._ERROR_;
                end;
            end;

            states._FINAL:
            begin
                currentLexeme := createLexeme(textToken, matchToken(textToken), currentLine, currentColumn);
                setLength(lexemeList, length(lexemeList) + 1);
                lexemeList[length(lexemeList) - 1] := currentLexeme;
                textToken := '';
                state := states._INITIAL_;
            end;

            states._ERROR_:
            begin
                Halt;
            end;

        end;
    end;

    Exit(lexemeList);
end;

end.