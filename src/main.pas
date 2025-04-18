program main;

uses
  reader;

var
  fileContent: string;

begin
  fileContent := ReadFileToString;
  Writeln('Conteúdo do arquivo:');
  Writeln(fileContent);
end.