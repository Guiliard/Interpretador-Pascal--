unit reader_unit;

interface

function readFileToString: AnsiString;

implementation

function readFileToString: AnsiString;

var
  fileContent: AnsiString;
  line: string;

begin 
  fileContent := '';
  while not eof(input) do
  begin
    readln(input, line);
    fileContent := fileContent + line + LineEnding;
  end;
  readFileToString := fileContent;
end;

end.