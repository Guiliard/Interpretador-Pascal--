unit itm_reader;

interface

function readItmFile: AnsiString;

implementation

uses
  SysUtils;

function readItmFile: AnsiString;
var
  fileContent: AnsiString;
  line: string;
  arq: Text;
  filename: string;
begin
  fileContent := '';
  filename := 'itm.txt';

  if not FileExists(filename) then
  begin
    writeln('Erro: Arquivo "', filename, '" não encontrado no diretório atual!');
    Halt(1);
  end;

  Assign(arq, filename);
  Reset(arq);
  while not eof(arq) do
  begin
    readln(arq, line);
    writeln(line);  // opcional: pode remover se não quiser ecoar no console
    fileContent := fileContent + line + LineEnding;
  end;
  Close(arq);

  readItmFile := fileContent;
end;

end.
