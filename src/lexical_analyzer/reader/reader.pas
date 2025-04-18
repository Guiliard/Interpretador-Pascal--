unit reader;

interface

function readFileToString: string;

implementation

function readFileToString: string;

var
  fileContent: string;
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