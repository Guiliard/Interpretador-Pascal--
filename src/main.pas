program main;

uses
  reader_unit, 
	lexeme_unit,     
	lexical_analyzer_unit,
	syntax_analyzer_unit, 
	intermediate_code_unit,
	intermediate_utils_unit;
  itm_analyzer,
  itm_runner,
  itm_reader;

var
  fileContent: AnsiString;
  lexemes: lexeme_array;
  arrayCode: intermediate_code_array;
  itmContent: AnsiString;
  itms: ItmArray;

begin
	fileContent := ReadFileToString;

	lexemes := lexicalAnalyzer(fileContent);

  arrayCode := syntaxAnalyzer(lexemes);

	printArrayCode(arrayCode);

	writeln('Syntax analysis completed successfully. No errors found.');

  itmContent := readItmFile;
  itms := analyzeItm(itmContent);

  RunInstructions(itms);
end.