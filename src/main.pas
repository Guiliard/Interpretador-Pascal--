program main;

uses
  reader_unit,      
  analyzer_unit,    
  lexeme_unit,    
  type_token_unit,  
  utils_unit;       

var
  fileContent: AnsiString;
  lexemes: array of lexeme;
  i: Integer;

begin
  fileContent := ReadFileToString;
  Writeln('Conteúdo do arquivo:');
  Writeln(fileContent);
  
  Writeln('Analisando o conteúdo do arquivo...');
  lexemes := analyzer(fileContent);
  Writeln('Análise concluída.');

  Writeln('--- Lista de lexemas ---');
  for i := 0 to High(lexemes) do
  begin
    Writeln('Texto: ', lexemes[i].lex_text, ' | Token: ', getTokenName(lexemes[i].token_real), ' | Linha: ', lexemes[i].line, ' | Coluna: ', lexemes[i].column);
  end;
end.