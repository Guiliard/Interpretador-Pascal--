program main;

uses
  reader_unit, 
  lexeme_unit,     
  lexical_analyzer_unit,
  syntax_analyzer_unit,
  itm_reader,
  itm_analyzer;   

var
  fileContent: AnsiString;
  itmContent: AnsiString;
  lexemes: lexeme_array;
  itms: ItmArray;
  i: integer;

begin
  fileContent := ReadFileToString;
  
  lexemes := lexicalAnalyzer(fileContent);

  syntaxAnalyzer(lexemes);

  writeln('Syntax analysis completed successfully. No errors found.');

  itmContent := readItmFile;
  itms := analyzeItm(itmContent);

  for i := 0 to High(itms) do
  begin
    Writeln('Instrução ', i+1, ':');
    Writeln('  OP: ', itms[i].op);
    Writeln('  ARG1: ', itms[i].arg1);
    Writeln('  ARG2: ', itms[i].arg2);
    Writeln('  ARG3: ', itms[i].arg3);
    if itms[i].op = 'ATT' then
      Writeln('  TIPO: ', itms[i].arg_type);
    Writeln('---------------------');
  end;

end.