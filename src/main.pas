program main;

uses
  reader_unit, 
  lexeme_unit,     
  lexical_analyzer_unit,
  syntax_analyzer_unit;   

var
  fileContent: AnsiString;
  lexemes: lexeme_array;

begin
  fileContent := ReadFileToString;
  
  lexemes := lexicalAnalyzer(fileContent);

  syntaxAnalyzer(lexemes);
end.