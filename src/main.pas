program main;

uses
  reader_unit,      
  lexical_analyzer_unit,    
  lexeme_unit,    
  lexical_utils_unit;       

var
  fileContent: AnsiString;
  lexemes: array of lexeme;
  i: Integer;

begin
  fileContent := ReadFileToString;
  Writeln('--- Conteúdo do arquivo ---');
  Writeln(fileContent);
  
  lexemes := lexical_analyzer(fileContent);

  Writeln('--- Lista de lexemas ---');
  for i := 0 to High(lexemes) do
  begin
    Writeln('Texto: ', lexemes[i].lex_text, ' | Token: ', getTokenName(lexemes[i].token_real), ' | Linha: ', lexemes[i].line, ' | Coluna: ', lexemes[i].column);
  end;
end.