type
  l_token = record
    token_word : string;
    t_line : integer;
    t_column: integer;
    prox : ^l_token;
  end;
  
var
  arq: Text;
  new_token: string;
  c: char;
  next_c: char;
  p_line : integer; // incrementador de linha
  p_column : integer; // incrementador de coluna
  tk_column : integer;
  novo, start : ^l_token;

begin
  Assign(arq, 'test01.pmm');
  Reset(arq);

  new(start);
  novo := start;
  p_column := 1;
  tk_column := 1;
  p_line := 1;
  
  while not Eof(arq) do
  begin
    new_token := '';
    while not Eoln(arq) do
    begin
      Read(arq, c);

      // Se for separador ou operador
      if (c in [' ', ';', ':', '=', '(', ')', '+', '-', '*', '/', ',', '>', '"']) then
      begin
        // Se tinha token acumulado, salva ele
        if new_token <> '' then
        begin
          novo^.token_word := new_token;
          novo^.t_line := p_line;
          novo^.t_column := tk_column;
          new(novo^.prox);
          novo := novo^.prox;
          new_token := '';
        end;

        // Se for dois caracteres := 
        if c = ':' then
        begin
          Read(arq, next_c);
          p_column := p_column + 1;
          if next_c = '=' then
          begin
            novo^.token_word := ':=';
            novo^.t_line := p_line;
            novo^.t_column := p_column;
            new(novo^.prox);
            novo := novo^.prox;
          end
          else
          begin
            novo^.token_word := c;
            novo^.t_line := p_line;
            novo^.t_column := p_column;
            new(novo^.prox);
            novo := novo^.prox;

            // Próximo caractere volta para o fluxo normal
            new_token := next_c;
            tk_column := p_column + 1;
          end;
        end
        else if c <> ' ' then
        begin
          novo^.token_word := c;
          novo^.t_line := p_line;
          novo^.t_column := p_column;
          new(novo^.prox);
          novo := novo^.prox;
        end;

        // Incrementa coluna depois de processar separador
        p_column := p_column + 1;
      end
      else
      begin
        // Se for início de novo token, salva coluna
        if new_token = '' then
          tk_column := p_column;
        new_token := new_token + c;
        p_column := p_column + 1;
      end;
    end;

    // Se sobrou token no final da linha
    if new_token <> '' then
    begin
      novo^.token_word := new_token;
      novo^.t_line := p_line;
      novo^.t_column := tk_column;
      new(novo^.prox);
      novo := novo^.prox;
    end;

    p_line := p_line + 1;
    p_column := 1;
    Readln(arq); // Pula pra próxima linha
  end;

  Close(arq);

	novo^.prox := nil;
	novo := start;
	
	while novo^.prox <> nil do
	begin
		writeln;
		writeln('token: ', novo^.token_word, ' /linha: ', novo^.t_line, ' /coluna: ', novo^.t_column);
		novo := novo^.prox;
	end;  
end.

{ while not Eof(arq) do
  begin
  new_token := '';
    while not Eoln(arq) do
    begin
      Read(arq, c);
      if (c in [' ', ';', ':', '=', '(', ')', '+', '-', '*', '/', ',']) then
      begin
        if new_token <> '' then
        begin
          novo^.token_word := new_token;
          novo^.t_line := p_line;
          novo^.t_column := tk_column;
          new(novo^.prox);
          novo := novo^.prox;
          new_token := '';
        end;
        if c <> ' ' then
        begin
          if c = ':' then
          begin
            Read(arq, next_c);
            if next_c = '=' then
            begin
              novo^.token_word := ':=';
              novo^.t_line := p_line;
              novo^.t_column := p_column;
              new(novo^.prox);
              novo := novo^.prox;
              p_column := p_column + 1;
            end
            else
            begin
              novo^.token_word := c;
              novo^.t_line := p_line;
              novo^.t_column := p_column;
              new(novo^.prox);
              novo := novo^.prox;
              p_column := p_column + 1;
              // tk_column := p_column + 1;
            end
          end
          else
          begin
            novo^.token_word := c;
            novo^.t_line := p_line;
            novo^.t_column := p_column;
            new(novo^.prox);
            novo := novo^.prox;
          end
        end;
        new_token := '';
      end
      else
      begin
        if new_token = '' then
          tk_column := p_column;
        new_token := new_token + c;
      end;
      p_column := p_column + 1;
      if c = ' ' then
          tk_column := p_column;
      Writeln('Caractere: ', c);
    end;
    if new_token <> '' then
    begin
      novo^.token_word := new_token;
      novo^.t_line := p_line;
      novo^.t_column := tk_column;
      new(novo^.prox);
      novo := novo^.prox;
      new_token := '';
    end;
    p_line := p_line + 1;
    p_column := 1;
    tk_column := 1;
    Readln(arq); // Pula pra próxima linha
  end; }