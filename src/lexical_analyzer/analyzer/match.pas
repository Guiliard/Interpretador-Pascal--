unit match;

interface

uses
    type_token,
    table_token;

function matchToken(textToken: string): typeToken;

implementation

function matchToken(textToken: string): typeToken;
var
    i: integer;
    match: typeToken;

begin
    for i := 0 to High(tableToken) do
    begin
        if tableToken[i].text = textToken then
        begin
            match := tableToken[i].token;
            Exit(match);
        end;
    end;
    Exit(_VARIABLE_);
end;

end.