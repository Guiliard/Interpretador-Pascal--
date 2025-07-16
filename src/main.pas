program main;

uses
  reader_unit, 
  lexeme_unit,     
  lexical_analyzer_unit,
  syntax_analyzer_unit,
  itm_reader,
  itm_analyzer,
  itm_runner;   

var
  fileContent: AnsiString;
  lexemes: lexeme_array;
  itmContent: AnsiString;
  itms: ItmArray;

begin
  fileContent := ReadFileToString;
  
  lexemes := lexicalAnalyzer(fileContent);

  syntaxAnalyzer(lexemes);

  itmContent := readItmFile;
  itms := analyzeItm(itmContent);

  RunInstructions(itms);

  writeln('Syntax analysis completed successfully. No errors found.');
end.